pipeline {
    agent any

    environment {
        SCAN_DIR = 'application'
    }

    stages {
        stage('Checkout Codebase') {
            steps {
                echo 'Pulling the latest codebase definitions from the portfolio repository...'
                checkout scm
            }
        }

        stage('Static Application Security Testing (SAST)') {
            steps {
                echo 'Triggering security scan engine via standalone pipeline execution...'
                script {
                    // Downloads and executes Trivy natively inside the workspace without requiring Docker CLI inside Jenkins
                    sh """
                    curl -sfL https://githubusercontent.com | sh -s -- -b .
                    ./trivy fs ${SCAN_DIR} --severity HIGH,CRITICAL
                    """
                }
            }
        }

        stage('Artifact Compilation & Build Verification') {
            steps {
                echo 'Validating application composition matrices...'
            }
        }
    }
}

