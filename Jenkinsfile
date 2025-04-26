pipeline {
    agent any
    stages {
        stage('Check Git Version') {
            steps {
                bat 'git --version'
            }
        }
        stage('Check Terraform Version') {
            steps {
                bat 'terraform version'
            }
        }
    }
}
