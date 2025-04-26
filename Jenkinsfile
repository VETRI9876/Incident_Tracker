pipeline {
    agent any

    stages {
        stage('Check Git Version') {
            steps {
                sh 'git --version'
            }
        }

        stage('Check Terraform Version') {
            steps {
                sh 'terraform version'
            }
        }
    }
}
