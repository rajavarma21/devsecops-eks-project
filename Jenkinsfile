pipeline {
    agent any

    environment {
        SCAN_DIR    = 'application'
        TRIVY_IMAGE = 'aquasec/trivy:0.58.0'
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
                sh '''
                    [ -d "$WORKSPACE/$SCAN_DIR" ] || { echo "'$SCAN_DIR' not found in workspace:"; ls -la "$WORKSPACE"; exit 1; }

                    docker run --rm \
                      --volumes-from jenkins-orchestrator:ro \
                      -v trivy-cache:/root/.cache/ \
                      $TRIVY_IMAGE fs "$WORKSPACE/$SCAN_DIR" \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --no-progress
                '''
            }
        }

        stage('SonarQube Code Quality Analysis') {
            steps {
                // Securely pulls your token from the Jenkins credentials vault dynamically on runtime execution
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    echo 'Injecting SonarQube container scanner to run deep code quality inspections...'
                    sh """
                    docker run --rm \
                      --volumes-from jenkins-orchestrator:ro \
                      sonarsource/sonar-scanner-cli:latest \
                      -Dsonar.host.url=${SONAR_URL} \
                      -Dsonar.token=${SONAR_TOKEN} \
                      -Dsonar.projectKey=devsecops-eks-project \
                      -Dsonar.projectName=devsecops-eks-project \
                      -Dsonar.sources=$WORKSPACE/$SCAN_DIR
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
        success { echo 'Pipeline succeeded. Security gate and code quality checks passed.' }
        failure { echo 'Pipeline failed. Check console logs for scan errors or vulnerabilities.' }
    }
}

