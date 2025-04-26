pipeline {
    agent any

    stages {
        stage('Terraform Init') {
            steps {
                bat 'terraform init'
            }
        }
        stage('Terraform Apply') {
            steps {
                bat 'terraform apply -auto-approve'
            }
        }
    }
}
