pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sirikaku/spring-petclinic:latest"
        DOCKER_CREDENTIALS_ID = "dockerhub-creds" // 🔁 Replace this if your actual credentials ID is different
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/siri666519/spring-petclinic.git', branch: 'main'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'

            }
        }

        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        dockerImage.push()
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker image (optional)...'
            sh '''
                if docker image inspect ${DOCKER_IMAGE} > /dev/null 2>&1; then
                    docker rmi ${DOCKER_IMAGE}
                else
                    echo "Image not found, skipping cleanup."
                fi
            '''
        }

        failure {
            echo 'Pipeline failed. Please check logs.'
        }

        success {
            echo 'Pipeline completed successfully.'
        }
    }
}

