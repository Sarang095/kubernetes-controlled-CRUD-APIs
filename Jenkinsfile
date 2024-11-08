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
        NEXUS_URL = "172.31.18.140:8081"
        NEXUS_REPOSITORY = "crud-main-app"
        NEXUS_CREDENTIAL_ID = "nexuslogin"
        scannerHome = tool 'sonar4'
        HELM_VALUES_REPO = 'https://github.com/Sarang095/kube-manifests.git'
        HELM_CREDENTIALS_ID = 'helm-repo-credentials'
        HELM_REPO_NAME = 'kube-manifests'  
        HELM_REPO_BRANCH = 'master'          
        HELM_CHART_PATH = 'values-repo/helm-kube'  
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage ('CODE ANALYSIS WITH CHECKSTYLE') {
            steps {
                sh 'mvn checkstyle:checkstyle'
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
                        -Dsonar.java.binaries=target/test-classes/ \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }

                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
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
                    pom = readMavenPom file: "pom.xml"
                    filesByGlob = findFiles(glob: "target/crud-v1.jar")
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path}"
                    artifactPath = filesByGlob[0].path
                    artifactExists = fileExists artifactPath
                    if (artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}"
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId, file: artifactPath, type: pom.packaging],
                                [artifactId: pom.artifactId, file: "pom.xml", type: "pom"]
                            ]
                        )
                    } else {
                        error "*** File: ${artifactPath}, could not be found"
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
                    sh "trivy image --exit-code 1 --severity HIGH ${DOCKER_IMAGE_NAME}:${buildNumber}"
                }
            }
        }

        stage('Trivy Config Scan - Kubernetes Manifests') {
            steps {
                sh 'trivy config --exit-code 1 --severity HIGH kube-manifests/'
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
                        sh "git clone https://${OAUTH_TOKEN}@github.com/${HELM_REPO_NAME}.git values-repo"
                    }
                    dir("${HELM_CHART_PATH}") {
                        sh "sed -i 's/replicas: .*/replicas: 2/' values.yaml"
                        sh "sed -i 's|repository: .*|repository: ${DOCKER_IMAGE_NAME}|' values.yaml"
                        sh "sed -i 's/tag: .*/tag: ${buildNumber}/' values.yaml"
                        sh "git commit -am 'Updating image tag to ${buildNumber}'"
                        sh "git push origin ${HELM_REPO_BRANCH}"
                    }
                }
            }
        }

        stage('Deploy with ArgoCD') {
            steps {
                script {
                    sh 'argocd app sync crud-app'
                }
            }
        }

        stage('Slack Notification') {
            steps {
                slackSend channel: '#ci-cd', color: 'good', message: "Build ${env.BUILD_ID} succeeded for java-crud-app"
            }
        }
    }
}


