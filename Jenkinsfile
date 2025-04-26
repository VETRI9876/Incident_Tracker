pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-creds').username
        AWS_SECRET_ACCESS_KEY = credentials('aws-creds').password
    }
    parameters {
        booleanParam(name: 'AUTO_APPLY', defaultValue: false, description: 'Apply Terraform changes automatically?')
    }
    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/VETRI9876/Incident_Tracker.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Format & Validate') {
            steps {
                sh 'terraform fmt -check'
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return params.AUTO_APPLY }
            }
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
