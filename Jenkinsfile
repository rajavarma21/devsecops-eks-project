
pipeline { 
    agent any

    environment { 
        SCAN_DIR      = 'application' 
        TRIVY_VERSION  = '0.48.3' 
        TRIVY_ARCHIVE  = 'trivy_0.48.3_Linux-64bit.tar.gz' 
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
                    // Utilizing double-quoted string literals (""") to allow native Groovy variable pass-through
                    sh """ 
                    set -eu
                    rm -f trivy trivy_*.tar.gz

                    echo "Downloading Trivy v\${TRIVY_VERSION}..."
                    curl -fL --retry 3 \
                      -o "\${TRIVY_ARCHIVE}" \
                      "https://github.com/aquasecurity/trivy/releases/download/v\${TRIVY_VERSION}/\${TRIVY_ARCHIVE}"

                    echo "Validating downloaded archive..." 
                    tar -tzf "\${TRIVY_ARCHIVE}" >/dev/null

                    echo "Extracting Trivy..." 
                    tar -xzf "\${TRIVY_ARCHIVE}" trivy
                    chmod +x trivy

                    ./trivy --version

                    if [ ! -d "\${SCAN_DIR}" ]; then
                        echo "ERROR: Target scan directory '\${SCAN_DIR}' does not exist inside workspace context."
                        exit 1
                    fi

                    echo "Scanning target perimeter path: \${SCAN_DIR}..." 
                    ./trivy fs \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      "\${SCAN_DIR}" 
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
            echo 'Pipeline completed successfully! Security quality gate conditions matched.' 
        }
        failure { 
            echo 'Pipeline execution termination encountered. Inspect the Jenkins console logs for details.' 
        } 
    } 
}

