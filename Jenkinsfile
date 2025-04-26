pipeline {
    agent any

    environment {
        GIT_HOME = 'C:\\Users\\Vetri\\AppData\\Local\\Programs\\Git\\cmd'  // Set Git home directory
        PATH = "${env.GIT_HOME};${env.PATH}"  // Add Git to the PATH for this pipeline
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    // Check out the repository
                    checkout scm
                }
            }
        }
        
        stage('Check Git Installation') {
            steps {
                script {
                    // Check Git version to verify it's installed
                    def gitVersion = bat(script: 'git --version', returnStdout: true).trim()
                    echo "Git Version: ${gitVersion}"
                }
            }
        }
    }
}
