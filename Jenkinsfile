pipeline { 
    agent any

    environment { 
        SCAN_DIR = 'application' 
    }

    stages { 
        stage('Checkout Codebase') { 
            steps { 
                echo 'Pulling the latest codebase from the portfolio repository...' 
                checkout scm 
            } 
        }

        stage('Static Application Security Testing (SAST)') { 
            steps { 
                echo 'Executing Aqua Security Trivy filesystem scan...'
                script { 
                    sh """ 
                    set -e
                    rm -f trivy_*.tar.gz trivy
                    
                    # Corrected absolute release endpoint URLs mapping structural hyphens
                    curl -fL --retry 3 \
                      -o trivy_0.48.3_Linux-64bit.tar.gz \
                      https://github.com
                    
                    tar -xzf trivy_0.48.3_Linux-64bit.tar.gz trivy
                    chmod +x trivy
                    ./trivy --version
                    
                    ./trivy fs \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      "${SCAN_DIR}"
                    
                    rm -f trivy_*.tar.gz trivy 
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
        success { 
            echo 'Pipeline completed successfully!' 
        }
        failure { 
            echo 'Pipeline failed. Check the Jenkins console output.' 
        } 
    } 
}

