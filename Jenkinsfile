pipeline {
    agent any

    tools {
        git 'Git'  // Use the default Git installation configured in Jenkins
    }

    environment {
        // Ensure Git is correctly found in the system's PATH
        GIT_PATH = "C:\\Program Files\\Git\\cmd\\git.exe"  // Adjust path to your Git installation
        TF_PATH = "C:\\Users\\Vetri\\terraform_1.11.4_windows_amd64\\terraform.exe"  // Updated Terraform path
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    // Check if Git is available in the environment
                    echo "Git Path: ${env.GIT_PATH}"
                    sh '"${GIT_PATH}" --version'  // Check Git version to confirm the correct Git tool is being used
                    // Checkout code from the Git repository
                    checkout scm
                }
            }
        }

        stage('Verify Terraform Installation') {
            steps {
                script {
                    // Check Terraform version to ensure it's available
                    echo "Terraform Path: ${env.TF_PATH}"
                    sh '"${TF_PATH}" --version'  // Check Terraform version
                }
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                script {
                    echo 'Initializing Terraform...'
                    // Ensure Terraform initialization and planning are done
                    dir('terraform') {
                        withCredentials([string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                                          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID')]) {
                            // Initialize Terraform
                            sh 'terraform init'
                            // Plan Terraform changes
                            sh 'terraform plan'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    echo 'Applying Terraform changes...'
                    // Apply the Terraform changes
                    dir('terraform') {
                        withCredentials([string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                                          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID')]) {
                            // Apply the plan with auto-approval
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
