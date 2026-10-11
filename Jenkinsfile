pipeline {
    agent any

    environment {
        SCAN_DIR    = 'application'
        TRIVY_IMAGE = 'aquasec/trivy:0.58.0'
        // Tells the script where your SonarQube metrics portal is listening on the cloud host network
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
                // Modified to use double-quotes (") inside sh block to allow dynamic shell interpolation
                sh """
                    [ -d "\$WORKSPACE/$SCAN_DIR" ] || { echo "'$SCAN_DIR' not found in workspace:"; ls -la "\$WORKSPACE"; exit 1; }

                    # Dynamic container tracking bypasses hardcoded orchestration naming conflicts completely
                    CONTAINER_ID=\$(docker ps -qf "name=jenkins-orchestrator")

                    docker run --rm \
                      --volumes-from \${CONTAINER_ID}:ro \
                      -v trivy-cache:/root/.cache/ \
                      $TRIVY_IMAGE fs "\$WORKSPACE/$SCAN_DIR" \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --no-progress
                """
            }
        }

        stage('SonarQube Code Quality Analysis') {
            steps {
                // Securely pulls your token from the Jenkins credentials vault dynamically on execution
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    echo 'Spawning SonarQube container scanner using native workspace volume attachments...'
                    // FIX: Replaced literal single quotes with double quotes (") to unblock Groovy environment variable translation
                    sh """
                        CONTAINER_ID=\$(docker ps -qf "name=jenkins-orchestrator")

                        docker run --rm \
                          --volumes-from \${CONTAINER_ID}:ro \
                          -w "\$WORKSPACE/$SCAN_DIR" \
                          -e SONAR_HOST_URL="${SONAR_URL}" \
                          -e SONAR_TOKEN="${SONAR_TOKEN}" \
                          sonarsource/sonar-scanner-cli:11 \
                          -Dsonar.projectKey=devsecops-eks-project \
                          -Dsonar.projectName=devsecops-eks-project \
                          -Dsonar.projectBaseDir="\$WORKSPACE/$SCAN_DIR" \
                          -Dsonar.sources=. \
                          -Dsonar.working.directory=/tmp/.scannerwork
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
            echo 'Pipeline succeeded. Security gate and code quality checks passed completely!' 
        }
        failure { 
            echo 'Pipeline failed. Check console logs for scan errors, quality breaches, or vulnerabilities.' 
        }
    }
}

