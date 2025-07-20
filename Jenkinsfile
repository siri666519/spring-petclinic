pipeline {
    agent any

    tools {
        maven 'Maven3' // Match this with Jenkins global config name
    }

    environment {
        DOCKER_IMAGE = 'sirikaku/spring-petclinic:latest'
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
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                echo 'Pushing image to DockerHub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                echo 'Running Trivy security scan...'
                sh '''
                    if ! command -v trivy &> /dev/null
                    then
                        echo "Installing Trivy..."
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
                    fi
                    trivy image $DOCKER_IMAGE > trivy-report.txt || true
                '''
                archiveArtifacts artifacts: 'trivy-report.txt', onlyIfSuccessful: false
            }
        }

        stage('Deploy Container') {
            steps {
                echo 'Deploying application to Kubernetes...'
                sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker image (optional)...'
            sh 'docker rmi $DOCKER_IMAGE || true'
            archiveArtifacts artifacts: '**/target/*.jar', onlyIfSuccessful: true
        }
        failure {
            echo 'Pipeline failed. Please check logs.'
        }
    }
}

