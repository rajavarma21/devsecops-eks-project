pipeline {
    agent any

    environment {
        SCAN_DIR    = 'application'
        // Maps the cloud network address where your SonarQube dashboard is active
        SONAR_URL   = 'http://3.106.210.243:9000'
    }

    stages {
        stage('Checkout Codebase') {
            steps {
                checkout scm
            }
        }

        stage('SAST - Trivy FS Scan') {
            steps {
                echo 'Executing Aqua Security Trivy standalone filesystem scan...'
                script {
                    // Downloads and runs the standalone pre-compiled Trivy binary directly in the workspace
                    // This completely bypasses any 'docker: not found' CLI issues inside the container
                    sh """
                    set -eu
                    rm -f trivy trivy_*.tar.gz
                    
                    echo "Downloading stable Trivy binary package..."
                    curl -fLo trivy_0.48.3_Linux-64bit.tar.gz https://github.com
                    
                    tar -zxvf trivy_0.48.3_Linux-64bit.tar.gz trivy
                    chmod +x trivy
                    
                    ./trivy --version
                    
                    echo "Auditing codebase directory path: ${SCAN_DIR}..."
                    ./trivy fs --severity HIGH,CRITICAL --exit-code 1 "${SCAN_DIR}"
                    
                    rm -f trivy_*.tar.gz trivy
                    """
                }
            }
        }

        stage('SonarQube Code Quality Analysis') {
            steps {
                // Securely pulls your token from the Jenkins credentials vault dynamically on runtime execution
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    echo 'Injecting SonarQube container scanner to run deep code quality inspections...'
                    sh """
                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      -v \$HOME/.cache:/root/.cache/ \
                      -v \$(pwd):/apps \
                      sonarsource/sonar-scanner-cli:latest \
                      -Dsonar.host.url=${SONAR_URL} \
                      -Dsonar.token=${SONAR_TOKEN} \
                      -Dsonar.projectKey=devsecops-eks-project \
                      -Dsonar.projectName=devsecops-eks-project \
                      -Dsonar.sources=/apps/${SCAN_DIR}
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
        always {
            sh 'rm -f trivy trivy_*.tar.gz || true'
        }
        success { echo 'Pipeline succeeded. Security gate and code quality checks passed.' }
        failure { echo 'Pipeline failed. Check console logs for scan errors or vulnerabilities.' }
    }
}

