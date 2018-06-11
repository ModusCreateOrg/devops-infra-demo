#!/usr/bin/env groovy

stage('Checkout') {
    node {
        timeout(time:default_timeout_minutes, unit:'MINUTES') {
            checkout scm
            sh ('git clean -fdx')
            stash includes: "./**", excludes: "./.git/", name: 'src'
        }
    }
}

stage('Build') {
    node {
        unstash 'src'
        // TODO: We should be getting a built image from the Docker registry.
        sh ("""
            cd packer
            make
        """)
    }
}

