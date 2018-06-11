#!/usr/bin/env groovy

def default_timeout_minutes = 10

stage('Checkout') {
    node {
        timeout(time:default_timeout_minutes, unit:'MINUTES') {
            checkout scm
            sh ('git clean -fdx')
            stash includes: "**", excludes: ".git/", name: 'src'
        }
    }
}

stage('Build') {
    node {
        unstash 'src'
        ansiColor('xterm') {
            sh ("""
                cp env.sh.sample env.sh
                cd packer
                rm -rf build
                mkdir build
                ./pack.sh
            """)
            archive (includes: 'packer/build/**')
            publishHTML (target: [
                allowMissing: true,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'packer/build',
                reportFiles: 'scan-xccdf-report.html',
                reportName: "OpenSCAP Report"
    ])
        }
    }
}

