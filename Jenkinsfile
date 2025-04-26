pipeline {
    agent any

    parameters {
        booleanParam(name: 'AUTO_APPLY', defaultValue: false, description: 'Apply Terraform changes automatically?')
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')  // Using Jenkins credentials
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')  // Using Jenkins credentials
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
                script {
                    try {
                        sh '''
                            terraform init
                        '''
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Terraform Init failed"
                    }
                }
            }
        }

        stage('Terraform Format & Validate') {
            steps {
                script {
                    try {
                        sh 'terraform fmt -check'
                        sh 'terraform validate'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Terraform Format & Validate failed"
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    try {
                        sh 'terraform plan -out=tfplan'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Terraform Plan failed"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return params.AUTO_APPLY }
            }
            steps {
                script {
                    try {
                        sh '''
                            terraform apply -auto-approve tfplan
                        '''
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Terraform Apply failed"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully."
        }

        failure {
            echo "Pipeline failed."
        }

        always {
            echo "Cleaning up or any other tasks to run after pipeline stages."
        }
    }
}
