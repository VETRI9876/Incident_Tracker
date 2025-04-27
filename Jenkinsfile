pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')       
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')    
        AWS_REGION = 'eu-north-1'
    }

    stages {

        stage('Terraform Init') {
            steps {
                // Initialize Terraform to set up necessary configurations
                bat 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                // Generate Terraform plan to see the changes that will be applied
                bat 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                // Apply the Terraform configuration to create or update infrastructure
                bat 'terraform apply -auto-approve'
            }
        }

        stage('Fetch EC2 Public IP and Prepare for Ansible') {
            steps {
                script {
                    // Fetch EC2 public IP from Terraform output
                    def ec2_ip = bat(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                    echo "EC2 Public IP: ${ec2_ip}"

                    // Write the inventory.ini file with the fetched EC2 IP
                    writeFile file: 'inventory.ini', text: """[servers]
${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=C:/Users/Vetri/.jenkins/workspace/Jenkins-Piepline/devops.pem
"""
                    
                    // Optional: Print the contents of the inventory.ini file for verification
                    echo "Inventory File Content:"
                    bat 'type inventory.ini'
                }
            }
        }

        stage('Save PEM Key Locally') {
            steps {
                // Save the PEM key locally using Jenkins credentials
                withCredentials([string(credentialsId: 'devops-pem', variable: 'PEM_CONTENT')]) {
                    bat '''
                      echo %PEM_CONTENT% > %cd%\\devops.pem
                      icacls %cd%\\devops.pem /inheritance:r /grant:r %USERNAME%:R
                    '''
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                // Run Ansible playbook inside a Docker container
                bat '''
                  docker run --rm -v %cd%:/workspace -w /workspace willhallonline/ansible ansible-playbook -i inventory.ini deploy.yaml
                '''
            }
        }

        stage('Cleanup PEM Key') {
            steps {
                // Clean up the PEM file after Ansible playbook run
                bat '''
                  del %cd%\\devops.pem
                '''
            }
        }
    }
}
