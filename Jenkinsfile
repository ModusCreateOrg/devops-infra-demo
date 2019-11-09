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
final codedeploy_target_skip = -1
// See generally safe key names from https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html
//final s3_safe_branch_name = env.BRANCH_NAME.replaceAll(/[^0-9a-zA-Z\!\-_\.\*\'\(\)], "_")
final s3_safe_branch_name = env.BRANCH_NAME.replaceAll(/[^0-9a-zA-Z\!\-_\.\*\'\(\)]/ , "_")

/** Set up CAPTCHA*/
def get_captcha(Long hash_const) {
    final int MAX = 10
    Random rand = new Random()
    def op1 = rand.nextInt(MAX+1)
    def op2 = rand.nextInt(MAX+1) + MAX
    def op3 = rand.nextInt(MAX+1)
    def captcha_problem = "CAPTCHA problem: What is the answer to this problem: ${op1} + ${op2} - ${op3}"
    Long captcha_answer = op1 + op2 - op3
    Long captcha_hash = captcha_answer ^ hash_const
    return [captcha_problem, captcha_hash.toString()]
}

def wrap = { fn->
    ansiColor('xterm') {
        withCredentials(
            [
                file(credentialsId: 'terraform-demo.json',
                     variable: 'GOOGLE_APPLICATION_CREDENTIALS_OVERRIDE'),
                string(credentialsId: 'newrelic.license.key',
                       variable: 'NEWRELIC_LICENSE_KEY_OVERRIDE'),
                string(credentialsId: 'newrelic.api.key',
                       variable: 'NEWRELIC_API_KEY_OVERRIDE'),
                string(credentialsId: 'newrelic.alert.email',
                       variable: 'NEWRELIC_ALERT_EMAIL_OVERRIDE'),
            ]) {
                sh ("bin/clean-workspace.sh")
                fn()
            }
    }
}

final Long XOR_CONST = 4919 // 0x1337 see https://en.wikipedia.org/wiki/Leet
(captcha_problem, captcha_hash) = get_captcha(XOR_CONST)

/** Gather properties from user parameters */
properties([
    parameters([
        booleanParam(
            name: 'Run_Packer',
            defaultValue: false,
            description: 'Run Packer for this build?'
        ),
        booleanParam(
            name: 'Package_CodeDeploy',
            defaultValue: false,
            description: 'Package CodeDeploy application on this build?'
        ),
        string(
            name: 'CodeDeploy_Target',
            defaultValue: '',
            description: '''Deploy a CodeDeploy archive.
                            Specify one of the following:
                            1. "latest" - deploy the latest build from this branch
                            2. a build number - deploy that build number from this branch
                            3. a full S3 URL'''
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
            name: 'Terraform_Targets',
            defaultValue: '',
            description: '''Specific Terraform resource or resource names to target
                            (Use this to modify or delete less than the full set of resources'''
        ),
        text(
            name: 'Extra_Variables',
            defaultValue: '',
            description: '''Terraform Variables to define for this run.
                            Allows you to override declared variables.
                            Put one variable per line, in JSON or HCL like this:
                            associate_public_ip_address = "true"'''
        ),
        booleanParam(
            name: 'Rotate_Servers',
            defaultValue: false,
            description: """Rotate server instances in Auto Scaling Group?
                            You should do this if you changed ASG size or baked a new AMI.
                        """
        ),
        booleanParam(
            name: 'Run_JMeter',
            defaultValue: false,
            description: "Execute a JMeter load test against the stack"
        ),
        string(
            name: 'JMETER_num_threads',
            defaultValue: '2',
            description: "number of jmeter threads."
        ),
        string(
            name: 'JMETER_ramp_time',
            defaultValue: '900',
            description: 'period in seconds of ramp-up time.'
        ),
        string(
            name: 'JMETER_duration',
            defaultValue: '1800',
            description: 'time in seconds to the whole Jmeter test'
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
    def should_validate_captcha = params.Run_Packer || params.Apply_Terraform || params.Destroy_Terraform || params.Run_JMeter || params.CodeDeploy_Target

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

    def build_number = env.BUILD_NUMBER as Long
    Long codedeploy_target

    switch (params.CodeDeploy_Target.toLowerCase()) {
        case "": 
            echo "CodeDeploy target is blank, skipping codedeploy step"
            codedeploy_target = codedeploy_target_skip
            break
        case "latest": 
            // when codedeploy_target > build number, count backwards
            codedeploy_target = build_number + 1 
            echo """CodeDeploy: targeting latest build
                    CodeDeploy: Will look for build <= ${build_number}
                    CodeDeploy: Will use prefix ${s3_safe_branch_name}"""
            break
        case 1..build_number:
            echo """CodeDeploy: targeting build ${build_number} for ${env.BRANCH_NAME}
                    CodeDeploy: Will use name ${s3_safe_build_number}-${build_number}"""
            codedeploy_target = build_number
            break
        default:
            currentBuild.result = 'ABORTED'
            error "CodeDeploy build_number ${build_number} is not understood"
            break
    }
}

stage('Checkout') {
    node {
        timeout(time:default_timeout_minutes, unit:'MINUTES') {
            checkout scm
            sh ('bin/prep.sh') // Clean and prepare environment
            stash includes: "**", excludes: ".git/", name: 'src'
        }
    }
}

stage('Validate') {
    node {
        wrap.call({
            unstash 'src'
            // Validate packer templates, check branch
            sh ("./bin/validate.sh")
        })
    }
}


if (params.Run_Packer) {
    stage('Pack') {
        node {
            wrap.call({
                unstash 'src'
                try {
                    sh ("./bin/pack.sh")
                } finally {
                    archiveArtifacts artifacts: 'build/**', fingerprint: true
                    publishHTML (target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'build',
                        reportFiles: 'scan-xccdf-results.html',
                        reportName: "OpenSCAP Report"
                    ])
                    publishHTML (target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'build',
                        reportFiles: 'gauntlt-results.html',
                        reportName: "Gauntlt Report"
                    ])
                }
            })
        }
    }
}

if (params.Package_CodeDeploy) {
    stage('Package CodeDeploy Archive') {
        node {
            wrap.call({
                unstash 'src'
                sh ("./bin/build-codedeploy.sh ${s3_safe_branch_name}")
            })
        }
    }
}

def terraform_prompt = 'Should we apply the Terraform plan?'


stage('Plan Terraform') {
    node {
        wrap.call({
            unstash 'src'
            def verb = "plan"
            if (params.Destroy_Terraform) {
                verb += '-destroy';
                terraform_prompt += ' WARNING: will DESTROY resources';
            }
            sh ("""
                ./bin/terraform.sh ${verb}
                """)
        })
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
                wrap.call({
                    unstash 'plan'
                    sh ("./bin/terraform.sh apply")
                })
            }
        }
    } catch(err) { // timeout reached or other error
        echo err.toString()
        currentBuild.result = 'ABORTED'
    }
}

if (params.Rotate_Servers) {
    stage('Rotate Servers') {
        node {
            wrap.call({
                unstash 'src'
                sh ("./bin/rotate-asg.sh infra-demo-asg")
            })
        }
    }
}

if (params.Rotate_Servers) {
    stage('Rotate Servers') {
        node {
            wrap.call({
                unstash 'src'
                sh ("./bin/rotate-asg.sh infra-demo-asg")
            })
        }
    }
}

if (params.Run_JMeter) {
    stage('Run JMeter') {
        node {
            wrap.call({
                unstash 'src'
                sh ("""
                    HOST=\$(./bin/terraform.sh output route53-dns)
                    ./bin/jmeter.sh -Jnum_threads=${params.JMETER_num_threads} -Jramp_time=${params.JMETER_ramp_time} -Jduration=${params.JMETER_duration} -Jhost=\$HOST
                    ls -l build
                    """)
                archiveArtifacts artifacts: 'build/*.jtl, build/*.xml, build/*.csv, build/*.html', fingerprint: true
            })
        }
    }
}
