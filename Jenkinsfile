pipeline {
    agent any

    tools {
        git 'C:/Program Files/Git/cmd/git.exe'  // Explicitly specify the Git tool path
    }

    environment {
        // Optionally, define any environment variables required
        // TF_AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        // TF_AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    // Checkout code from the Git repository
                    checkout scm
                }
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                // Ensure Terraform initialization and planning are done
                dir('terraform') {
                    withCredentials([string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                                      string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID')]) {
                        sh 'terraform init'
                        sh 'terraform plan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Apply the Terraform changes
                    dir('terraform') {
                        withCredentials([string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                                          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID')]) {
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Post Actions') {
            steps {
                echo 'Terraform execution complete.'
            }
        }
    }

    post {
        failure {
            echo 'Terraform failed. Check the logs for errors.'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
    }
}
