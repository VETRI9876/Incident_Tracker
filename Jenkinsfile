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
                    def output = bat(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                    // Only take the last line (pure IP)
                    def lines = output.readLines()
                    def ec2_ip = lines[-1]    // Last line
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
                script {
                    echo "Running Ansible on IP: ${env.EC2_PUBLIC_IP}"
                    bat """
                        wsl ansible-playbook -i '${env.EC2_PUBLIC_IP},' -u ubuntu --private-key ~/devops.pem deploy.yaml \
                            -e aws_access_key_id=${AWS_ACCESS_KEY_ID} \
                            -e aws_secret_access_key=${AWS_SECRET_ACCESS_KEY} \
                            -e aws_region=${AWS_REGION} \
                            -e ecr_image_name='409784048198.dkr.ecr.eu-north-1.amazonaws.com/vetri:latest'
                    """
                }
            }
        }

    }
}
