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
                ./pack.sh
            """)
        }
    }
}

