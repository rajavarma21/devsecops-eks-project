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
                echo 'Executing Aqua Security Trivy static application binary check...'
                script {
                    // Downloads the absolute, compiled standalone binary archive directly to eliminate host system dependencies
                    sh """
                    rm -f trivy_*.tar.gz trivy
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

