pipeline {
    agent any

    parameters {
        booleanParam(name: 'AUTO_APPLY', defaultValue: false, description: 'Apply Terraform changes automatically?')
    }

    stages {
        stage('Clone Repo') {
            steps {
                // Specify the main branch in the git clone command
                git branch: 'main', url: 'https://github.com/VETRI9876/Incident_Tracker.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        // Set environment variables for AWS
                        sh '''
                            echo "AWS Access Key: $AWS_ACCESS_KEY_ID"
                            echo "AWS Secret Key: $AWS_SECRET_ACCESS_KEY"
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            terraform init
                        '''
                    }
                }
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
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        // Set environment variables for AWS
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return params.AUTO_APPLY }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        // Set environment variables for AWS
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }
    }
}
