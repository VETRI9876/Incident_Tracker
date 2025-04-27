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

        stage('Fetch EC2 Public IP') {
            steps {
                script {
                    def ec2_ip = bat(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                    echo "Fetched EC2 Public IP: ${ec2_ip}"
                    env.EC2_PUBLIC_IP = ec2_ip
                }
            }
        }

        stage('Prepare PEM for WSL') {
            steps {
                bat '''
                    wsl cp /mnt/c/Users/Vetri/devops.pem ~/devops.pem
                    wsl chmod 600 ~/devops.pem
                '''
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                bat """
                    wsl ansible-playbook -i "${env.EC2_PUBLIC_IP}," -u ubuntu --private-key ~/devops.pem deploy.yaml
                """
            }
        }

    }
}
