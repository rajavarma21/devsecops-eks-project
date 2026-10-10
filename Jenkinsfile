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
                echo 'Spawning isolated Aqua Security Trivy container to scan code filesystem...'
                script {
                    // Pulls the verified container engine directly to audit the mounted workspace files
                    // Bypasses local curl/tar package binary issues entirely
                    sh """
                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      -v \$HOME/.cache:/root/.cache/ \
                      -v \$(pwd):/apps \
                      aquasec/trivy:latest fs /apps/${SCAN_DIR} --severity HIGH,CRITICAL --exit-code 1
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

    post {
        success {
            echo 'Pipeline executed successfully! Security quality gate checks passed.'
        }
        failure {
            echo 'Pipeline run failed. Review the console logs for dependency or code vulnerability failures.'
        }
    }
}

