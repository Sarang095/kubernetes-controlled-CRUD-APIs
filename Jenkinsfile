pipeline {
    agent any
    tools {
        maven 'MAVEN3'
    }
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKER_IMAGE_NAME = 'csag095/java-crud-main'
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "54.166.222.209:8081"
        NEXUS_REPOSITORY = "crud-main-app"
        NEXUS_CREDENTIAL_ID = "nexuslogin"
        scannerHome = tool 'sonar4'
        HELM_VALUES_REPO = 'https://github.com/Sarang095/kube-manifests.git'
        HELM_CREDENTIALS_ID = 'helm-repo-credentials'
        HELM_REPO_NAME = 'kube-manifests'
        HELM_REPO_BRANCH = 'master'
        HELM_CHART_PATH = 'values-repo/helm-kube'
        PATH = "${env.WORKSPACE}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Sarang095/kubernetes-controlled-CRUD-APIs.git'
            }
        }

        stage('UNIT TEST') {
            steps {
                sh 'mvn test'
            }
        }

        stage('INTEGRATION TEST') {
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }

        stage('CODE ANALYSIS WITH CHECKSTYLE') {
            steps {
                sh 'mvn -s $WORKSPACE/settings.xml checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage('CODE ANALYSIS with SONARQUBE') {
            steps {
                withSonarQubeEnv('sonar-pro') {
                    sh '''${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=java-crud-app \
                        -Dsonar.projectName=java-crud-repo \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/test-classes/com/joesalt/tutorial/ \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }

                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Install Trivy') {
            steps {
                script {
                    def trivyInstalled = sh(script: 'which trivy', returnStatus: true) == 0
                    if (!trivyInstalled) {
                        sh '''
                            mkdir -p ${WORKSPACE}/bin
                            curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ${WORKSPACE}/bin
                        '''
                    } else {
                        echo 'Trivy is already installed'
                    }
                }
            }
        }

        stage('Vulnerability Scan - Source') {
            steps {
                sh 'trivy fs --exit-code 1 --severity HIGH src/'
            }
        }

        stage('Maven Build Package') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage("Publish to Nexus Repository Manager") {
            steps {
                script {
                    def artifactPath = "target/crud-v1.jar"
                    def version = "${env.BUILD_ID}.${env.BUILD_TIMESTAMP.replaceAll('[^\\d]', '')}"
                    
                    echo "*** Nexus URL: ${NEXUS_PROTOCOL}://${NEXUS_URL}/repository/${NEXUS_REPOSITORY}/"
                    echo "*** Version to be uploaded: ${version}"
                    echo "*** Artifact Path: ${artifactPath}"

                    if (fileExists(artifactPath)) {
                        echo "*** Uploading ${artifactPath} to Nexus Repository ${NEXUS_REPOSITORY} with version ${version}"
                        
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: "${NEXUS_URL}",
                            groupId: "com.joesalt",
                            version: version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: "tutorial", file: artifactPath, type: "jar"],
                                [artifactId: "tutorial", file: "pom.xml", type: "pom"]
                            ]
                        )
                    } else {
                        error "*** File: ${artifactPath} could not be found"
                    }
                }
            }
        }

        stage('Docker Build Image') {
            steps {
                script {
                    def buildNumber = currentBuild.number
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${buildNumber} ."
                }
            }
        }

        stage('Docker Image Scan') {
            steps {
                script {
                    def buildNumber = currentBuild.number
                    sh "trivy image --severity HIGH ${DOCKER_IMAGE_NAME}:${buildNumber}"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def buildNumber = currentBuild.number
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                    }
                    sh "docker push ${DOCKER_IMAGE_NAME}:${buildNumber}"
                }
            }
        }

        stage('Update Image in Helm Chart') {
            steps {
                script {
                    def buildNumber = currentBuild.number
                    withCredentials([string(credentialsId: 'GITHUB_OAUTH_TOKEN', variable: 'OAUTH_TOKEN')]) {
                        sh '''
                            git clone https://${OAUTH_TOKEN}@github.com/Sarang095/kube-manifests.git values-repo
                        '''
                    }
                    dir("${HELM_CHART_PATH}") {
                        sh "sed -i 's/replicas: .*/replicas: 2/' values.yaml"
                        sh "sed -i 's|repository: .*|repository: ${DOCKER_IMAGE_NAME}|' values.yaml"
                        sh "sed -i 's/tag: .*/tag: ${buildNumber}/' values.yaml"
                    }
                    stash name: 'values-repo', includes: 'values-repo/**'
                }
            }
        }

        stage('Trivy Config Scan - Helm Manifests') {
            steps {
                unstash 'values-repo'
                sh 'trivy config --severity HIGH values-repo/helm-kube/templates/'
            }
        }

        stage('Commit and Push Updated Helm Chart') {
            steps {
                script {
                    def buildNumber = currentBuild.number
                    dir("${HELM_CHART_PATH}") {
                        sh "git commit -am 'Updating image tag to ${buildNumber}'"
                        sh "git push origin ${HELM_REPO_BRANCH}"
                    }
                }
            }
        }

        stage('Deploy with kubectl') {
            agent {
                label 'KOPS'
            }
            steps {
                // Clone the kube-manifests repository into /home/jenkins
                withCredentials([string(credentialsId: 'GITHUB_OAUTH_TOKEN', variable: 'OAUTH_TOKEN')]) {
                    sh '''
                        echo "Cloning kube-manifests repository into /home/jenkins..."
                        cd /home/jenkins
                        git clone https://${OAUTH_TOKEN}@github.com/Sarang095/kube-manifests.git
                        ls -l /home/jenkins/kube-manifests  # Debugging: List files in the cloned repo
                    '''
                }

                // Apply Kubernetes Manifests with correct filename and debug info
                script {
                    echo "Applying Kubernetes manifests..."
                    sh '''
                        cd /home/jenkins/kube-manifests
                        echo "Current directory:"
                        pwd  # Debugging: Print current directory
                        ls -l  # Debugging: List files in the current directory
                        kubectl apply -f application.yml  # Correct file path and name
                    '''
                }
            }
        }

        stage('Slack Notification') {
            steps {
                script {
                    slackSend channel: '#ci-cd', color: 'good', message: "Build ${env.BUILD_ID} succeeded for java-crud-app"
                }
            }
            post {
                failure {
                    script {
                        slackSend channel: '#ci-cd', color: 'danger', message: "Build ${env.BUILD_ID} failed for java-crud-app"
                    }
                }
            }
        }
    }
}
