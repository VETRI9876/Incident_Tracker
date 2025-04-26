pipeline {
    agent any
    
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
