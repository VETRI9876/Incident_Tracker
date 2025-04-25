pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = "eu-north-1"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/VETRI9876/Incident_Tracker.git'
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                withCredentials([ 
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    withEnv([
                        "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}",
                        "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
                    ]) {
                        sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([ 
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    withEnv([
                        "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}",
                        "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
                    ]) {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Terraform applied successfully!'
        }
        failure {
            echo '❌ Terraform failed. Check the logs for errors.'
        }
    }
}
