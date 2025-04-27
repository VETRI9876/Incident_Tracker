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
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Fetch EC2 Public IP and Prepare for Ansible') {
            steps {
                dir('terraform') {
                    script {
                        // Fetch the public IP after apply
                        def ec2_ip = sh(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                        echo "EC2 Public IP: ${ec2_ip}"

                        // Create inventory file dynamically
                        writeFile file: 'inventory.ini', text: """[servers]\n${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/devops.pem"""

                        // Copy the .pem file to home directory and set permissions
                        sh '''
                          cp /mnt/c/Users/Vetri/devops.pem ~/devops.pem
                          chmod 600 ~/devops.pem
                        '''
                    }
                }
            }
        }

        stage('Install Ansible') {
            steps {
                sh '''
                  sudo apt update
                  sudo apt install -y ansible
                '''
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sh '''
                  ansible-playbook -i inventory.ini deploy.yaml
                '''
            }
        }
    }
}
