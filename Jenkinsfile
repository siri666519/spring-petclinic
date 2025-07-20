pipeline {
    agent any
    tools {
        maven 'Maven3'
    }
    environment {
        DOCKER_IMAGE = 'sirikaku/spring-petclinic'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/siri666519/spring-petclinic.git'
            }
        }

        stage('Build Maven Project') {
            steps {
                dir('spring-petclinic') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('spring-petclinic') {
                    sh 'docker build -t $DOCKER_IMAGE:latest .'
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push $DOCKER_IMAGE:latest
                    '''
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image $DOCKER_IMAGE:latest > trivyimage.txt"
            }
        }

        stage('Deploy Container') {
            steps {
                sh 'docker rm -f petclinic4 || true'
                sh 'docker run -d --name petclinic4 -p 8083:8080 $DOCKER_IMAGE:latest'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'docker rmi $DOCKER_IMAGE:latest || true'
            archiveArtifacts artifacts: 'trivyimage.txt', fingerprint: true
        }
    }
}

