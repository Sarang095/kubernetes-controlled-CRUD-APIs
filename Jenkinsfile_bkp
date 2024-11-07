pipeline {
    agent { label 'jenkins-slave' }

    tools {
        maven 'MAVEN3' 
    }

    environment {
        DOCKER_COMPOSE_FILE = 'docker-compose-product-dev.yml'
        DOCKER_IMAGE_NAME = 'csag095/product-service'
        DOCKER_CREDENTIALS_ID = 'docker-registry-creds'
    }

    stages {
        
        stage('Check Docker Permissions') {
            steps {
                script {
                    sh 'whoami'
                    sh 'groups'
                    sh 'ls -l /var/run/docker.sock'
                    sh 'docker --version'
                }
            }
        }
        
        
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Sarang095/kubernetes-controlled-CRUD-APIs.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def buildNumber = currentBuild.number
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${buildNumber} ."
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

        stage('Run Docker Compose') {
            steps {
                sh "docker-compose -f docker-compose-product-dev.yml up --build -d"
            }
        }
    }
}
