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
                bat 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                bat 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                bat 'terraform apply -auto-approve'
            }
        }

        stage('Fetch EC2 Public IP and Prepare for Ansible') {
            steps {
                script {
                    def ec2_ip = bat(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                    echo "EC2 Public IP: ${ec2_ip}"

                    writeFile file: 'inventory.ini', text: """[servers]\n${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/devops.pem"""
                }
            }
        }

        stage('Save PEM Key Locally') {
            steps {
                withCredentials([string(credentialsId: 'devops-pem', variable: 'PEM_CONTENT')]) {
                    bat '''
                      echo %PEM_CONTENT% > %USERPROFILE%\\devops.pem
                      icacls %USERPROFILE%\\devops.pem /inheritance:r /grant:r %USERNAME%:R
                    '''
                }
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
