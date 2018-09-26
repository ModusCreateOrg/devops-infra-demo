#!/usr/bin/env groovy

def default_timeout_minutes = 10


// Set up CAPTCHA
import java.util.Random
Random rand = new Random()
int max = 10

def op1 = rand.nextInt(max+1)
def op2 = rand.nextInt(max+1) + 10
def op3 = rand.nextInt(max+1) 

def captcha_problem = "CAPTCHA problem: What is the answer to this problem: ${op1} + ${op2} - ${op3}"
Long captcha_answer = op1 + op2 - op3
Long captcha_constant = 3735928559 // 0xdeadbeef
Long captcha_hash = captcha_answer ^ captcha_constant

// Gather properties from user parameters
properties([
    parameters([
        booleanParam(
            name: 'Run_Packer', 
            defaultValue: false, 
            description: 'Run Packer for this build?'
        ),
        booleanParam(
            name: 'Apply_Terraform', 
            defaultValue: false, 
            description: 'Apply Terraform plan on this build?'
        ),
        booleanParam(
            name: 'Destroy_Terraform', 
            defaultValue: false, 
            description: 'Destroy Terraform resources?'
        ),
        string(
            name: 'CAPTCHA_Guess', 
            defaultValue: '', 
            description: captcha_problem
        ),
        string(
            name: 'CAPTCHA_Hash',
            defaultValue: captcha_hash.toString(),
            description: 'Hash for CAPTCHA answer (DO NOT modify)'
        ),
    ])
])

stage('Validate') {
    // Validate packer templates
       
    // Check CAPTCHA
    def should_validate_captcha = params.Run_Packer || params.Run_Terraform;

    if (should_validate_captcha) {
        if (params.CAPTCHA_Guess == null || params.CAPTCHA_Guess == "") {
            throw new Exception("No CAPTCHA guess detected, try again!")
        }
        def guess = params.CAPTCHA_Guess as Long
        def hash = params.CAPTCHA_Hash as Long
        if ((guess ^ captcha_constant) != hash) {
            throw new Exception("CAPTCHA incorrect, try again")
        }
        echo "CAPTCHA validated OK"
    } else {
        echo "No CAPTCHA required, continuing"
    }

    // Check branch
}

def prepEnv = {
    sh ("""
        cp env.sh.sample env.sh
        rm -rf build
        mkdir build
    """)
}

stage('Checkout') {
    node {
        timeout(time:default_timeout_minutes, unit:'MINUTES') {
            checkout scm
            sh ('git clean -fdx')
            stash includes: "**", excludes: ".git/", name: 'src'
        }
    }
}

if (params.Run_Packer) {
    stage('Pack') {
        node {
            unstash 'src'
            ansiColor('xterm') {
                prepEnv()
                sh ("./bin/pack.sh")
                archive (includes: 'build/**')
                publishHTML (target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'build',
                    reportFiles: 'scan-xccdf-results.html',
                    reportName: "OpenSCAP Report"
                ]) }
        }
    }
}

def terraform_prompt = 'Should we apply the Terraform plan?'

stage('Plan Terraform') {
    node {
        unstash 'src'
        ansiColor('xterm') {
            prepEnv()
            def verb = "plan"
            if (params.Destroy_Terraform) {
                verb += '-destroy';
                terraform_prompt += ' WARNING: will DESTROY resources';
            }
            sh ("./bin/terraform.sh ${verb}")
        }
        stash includes: "**", excludes: ".git/", name: 'plan'
    }
}

if (params.Apply_Terraform || params.Destroy_Terraform) {
    // See https://support.cloudbees.com/hc/en-us/articles/226554067-Pipeline-How-to-add-an-input-step-with-timeout-that-continues-if-timeout-is-reached-using-a-default-value
    def userInput = false
    try {
        timeout(time: default_timeout_minutes, unit: 'MINUTES') {
            userInput = input(message: terraform_prompt)
        }
        stage('Apply Terraform') {
            node {
                unstash 'plan'
                ansiColor('xterm') {
                    prepEnv()
                    sh ("./bin/terraform.sh apply")
                }
                stash includes: "**", excludes: ".git/", name: 'apply'
            }
        }
    } catch(err) { // timeout reached or other error
        currentBuild.result = 'ABORTED'
    }
}
