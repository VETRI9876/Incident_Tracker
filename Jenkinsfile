pipeline {
    agent any
    
    tools {
        git 'Git'  // This should match the name you gave in the Global Tool Configuration
    }

    stages {
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
