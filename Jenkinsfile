pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')       // Jenkins Credentials
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')    // Jenkins Credentials
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

                        // Write inventory.ini with the public IP
                        writeFile file: 'inventory.ini', text: """[servers]\n${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/devops.pem"""
                    }
                }
            }
        }

        stage('Save PEM Key Locally') {
            steps {
                withCredentials([string(credentialsId: 'devops-pem', variable: 'PEM_CONTENT')]) {
                    sh '''
                      echo "$PEM_CONTENT" > ~/devops.pem
                      chmod 600 ~/devops.pem
                    '''
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
