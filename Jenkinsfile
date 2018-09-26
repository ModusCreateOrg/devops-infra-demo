#!/usr/bin/env groovy
/*
 * Jenkinsfile
 *
 * Use the Scripted style of Jenkinsfile in order to
 * write more Groovy functions and use variables to
 * control the workflow.
 */ 

import java.util.Random

// Set default variables
final default_timeout_minutes = 20

/** Set up CAPTCHA*/
def get_captcha() {
    final int MAX = 10
    final Long XOR_CONST = 3735928559 // 0xdeadbeef
    Random rand = new Random()
    def op1 = rand.nextInt(MAX+1)
    def op2 = rand.nextInt(MAX+1) + MAX
    def op3 = rand.nextInt(MAX+1) 
    def captcha_problem = "CAPTCHA problem: What is the answer to this problem: ${op1} + ${op2} - ${op3}"
    Long captcha_answer = op1 + op2 - op3
    Long captcha_hash = captcha_answer ^ XOR_CONST
    return [captcha_problem, captcha_hash.toString()]
}

def prepEnv = {
    sh ("""
        cp env.sh.sample env.sh
        rm -rf build
        mkdir build
    """)
}


(captcha_problem, captcha_hash) = get_captcha()

/** Gather properties from user parameters */
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
        booleanParam(
            name: 'Rotate_Servers', 
            defaultValue: false, 
            description: """Rotate server instances in Auto Scaling Group?
                            You should do this if you changed ASG size or baked a new AMI.
                         """
        ),
        string(
            name: 'CAPTCHA_Guess', 
            defaultValue: '', 
            description: captcha_problem
        ),
        string(
            name: 'CAPTCHA_Hash',
            defaultValue: captcha_hash,
            description: 'Hash for CAPTCHA answer (DO NOT modify)'
        ),
    ])
])

stage('Preflight') {
       
    // Check CAPTCHA
    def should_validate_captcha = params.Run_Packer || params.Run_Terraform;

    if (should_validate_captcha) {
        if (params.CAPTCHA_Guess == null || params.CAPTCHA_Guess == "") {
            throw new Exception("No CAPTCHA guess detected, try again!")
        }
        def guess = params.CAPTCHA_Guess as Long
        def hash = params.CAPTCHA_Hash as Long
        if ((guess ^ XOR_CONST) != hash) {
            throw new Exception("CAPTCHA incorrect, try again")
        }
        echo "CAPTCHA validated OK"
    } else {
        echo "No CAPTCHA required, continuing"
    }
}

stage('Checkout') {
    node {
        timeout(time:default_timeout_minutes, unit:'MINUTES') {
            checkout scm
            // sh ('git clean -fdx')
            sh ('''#!/usr/bin/env bash
                   . bin/common.sh
                   clean_root_owned_docker_files
                   git clean -fdx
                ''')
            stash includes: "**", excludes: ".git/", name: 'src'
        }
    }
}

stage('Validate') {
    node {
        unstash 'src'
        ansiColor('xterm') {
            // Validate packer templates, check branch
            sh ("./bin/validate.sh")
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

if (params.Rotate_Servers) {
    stage('Rotate Servers') {
        node {
            unstash 'src'
            ansiColor('xterm') {
                prepEnv()
                sh ("./bin/rotate-asg.sh infra-demo-asg")
            }
        }
    }
}

