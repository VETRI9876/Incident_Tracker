pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "eu-north-1"
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clone the repository with Terraform configuration
                git 'https://github.com/your-repo/your-terraform-config.git'
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Run terraform init to initialize Terraform configuration
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Run terraform plan to show what changes will be applied
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Run terraform apply to apply the plan
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
