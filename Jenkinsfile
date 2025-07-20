pipeline {
    agent any

    tools {
        maven 'Maven3'   // Matches Jenkins Maven tool name
    }

    stages {
        stage('Build Maven Project') {
            steps {
                echo 'Building the project using Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t sirikaku/spring-petclinic:latest .'
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                echo 'Pushing Docker image to DockerHub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push sirikaku/spring-petclinic:latest
                    '''
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                echo 'Running Trivy security scan...'
                sh 'trivy image sirikaku/spring-petclinic:latest || true'
            }
        }

        stage('Deploy Container') {
            steps {
                echo 'Deploying application using kubectl...'
                sh 'kubectl apply -f k8s/'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker image (optional)...'
            sh 'docker rmi sirikaku/spring-petclinic:latest || true'
        }
        failure {
            echo 'Pipeline failed. Please check logs.'
        }
    }
}

