pipeline {
    agent any

    environment {
        // Points our scans and Docker build targets to your backend microservices directory
        SCAN_DIR     = 'application'
        BACKEND_DIR  = 'application/backend'
        TRIVY_IMAGE  = 'aquasec/trivy:0.58.0'
        SONAR_URL    = 'http://3.106.210.243:9000'
        AWS_REGION   = 'ap-southeast-2'
        AWS_ACCOUNT  = '821224640841' 
        ECR_REGISTRY = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        DOCKER_IMAGE = "devsecops-app"
    }

    stages {
        stage('Checkout Codebase') {
            steps {
                checkout scm
            }
        }

        stage('SAST - Trivy FS Scan') {
            steps {
                sh """
                    [ -d "\$WORKSPACE/$SCAN_DIR" ] || { echo "'$SCAN_DIR' not found in workspace:"; ls -la "\$WORKSPACE"; exit 1; }
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
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    echo 'Spawning SonarQube container scanner using native workspace volume attachments...'
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

        stage('OWASP Dependency-Check Audit') {
            steps {
                echo 'Triggering deep open-source dependency validation scan (SCA)...'
                dependencyCheck additionalArguments: "--scan '$WORKSPACE/$SCAN_DIR' --format XML --format HTML", odcInstallation: 'OWASP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Docker Image Construction & AWS ECR Push') {
            steps {
                echo 'Authenticating with AWS ECR and building production container image tags...'
                sh """
                    # Running the AWS CLI login loop securely inside a temporary host container to bypass internal image limits
                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      amazon/aws-cli:latest ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    
                    # FIX: Mapped the direct, case-sensitive build path to your backend subfolder context containing the Dockerfile
                    docker build -t ${DOCKER_IMAGE}:latest ./$BACKEND_DIR
                    
                    # Tag the image matching your explicit AWS repository parameters
                    docker tag ${DOCKER_IMAGE}:latest ${ECR_REGISTRY}/${DOCKER_IMAGE}:latest
                    docker tag ${DOCKER_IMAGE}:latest ${ECR_REGISTRY}/${DOCKER_IMAGE}:\${BUILD_NUMBER}
                    
                    # Push the finalized artifacts securely to AWS ECR
                    docker push ${ECR_REGISTRY}/${DOCKER_IMAGE}:latest
                    docker push ${ECR_REGISTRY}/${DOCKER_IMAGE}:\${BUILD_NUMBER}
                    
                    # Clean up local image cache references to keep storage light
                    docker rmi ${ECR_REGISTRY}/${DOCKER_IMAGE}:latest ${ECR_REGISTRY}/${DOCKER_IMAGE}:\${BUILD_NUMBER}
                """
            }
        }
    }

    post {
        success { 
            echo 'Pipeline succeeded. Security gate, quality checks, and AWS ECR image delivery completed cleanly!' 
        }
        failure { 
            echo 'Pipeline execution failure encountered. Inspect the Jenkins console logs for details.' 
        }
    }
}

