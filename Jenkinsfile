pipeline {
    agent any

    environment {
        SCAN_DIR    = 'application'
        TRIVY_IMAGE = 'aquasec/trivy:0.58.0'
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

        stage('Artifact Compilation & Build Verification') {
            steps {
                echo 'Validating application composition matrices...'
            }
        }
    }

    post {
        success { echo 'Pipeline succeeded. Security gate passed.' }
        failure { echo 'Pipeline failed. Check console logs for scan errors or vulnerabilities.' }
    }
}
