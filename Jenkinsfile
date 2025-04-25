pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "eu-north-1"
    }
    stages {
        stage('Checkout SCM') {
            steps {
                // Specify the correct branch here (main)
                git branch: 'main', url: 'https://github.com/VETRI9876/Incident_Tracker.git'
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }
    post {
        success {
            echo 'Terraform applied successfully!'
        }
        failure {
            echo 'Terraform failed. Check the logs for errors.'
        }
    }
}
