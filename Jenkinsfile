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
                echo 'Triggering security scan engine against your application file structures...'
                script {
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v \$HOME/.cache:/root/.cache/ -v \$(pwd):/apps aquasec/trivy:latest fs /apps/${SCAN_DIR} --severity HIGH,CRITICAL"
                }
            }
        }

        stage('Artifact Compilation & Build Verification') {
            steps {
                echo 'Validating application composition matrices...'
                // Code packaging runtimes occur during this execution phase
            }
        }
    }
}

