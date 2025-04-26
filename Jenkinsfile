pipeline {
    agent any

    environment {
        IMAGE_NAME = "ghcr.io/vetri9876/incident-tracker"
        IMAGE_TAG = "latest"
        AWS_DEFAULT_REGION = "eu-north-1"
        GHCR_CREDENTIALS_ID = "ghcr-creds"         
        AWS_CREDENTIALS_ID = "aws-creds"            
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Login to GHCR') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${GHCR_CREDENTIALS_ID}", usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')]) {
                    sh """
                        echo "${GITHUB_TOKEN}" | docker login ghcr.io -u ${GITHUB_USERNAME} --password-stdin
                    """
                }
            }
        }

        stage('Push Docker Image to GHCR') {
            steps {
                script {
                    docker.withRegistry('https://ghcr.io', "${GHCR_CREDENTIALS_ID}") {
                        docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                    sh '''
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed. Check logs."
        }
    }
}
