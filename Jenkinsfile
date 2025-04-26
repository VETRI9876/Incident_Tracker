pipeline {
    agent any

    tools {
        git 'DefaultGit'  // Must match the name in Global Tool Configuration
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/VETRI9876/Incident_Tracker.git'
            }
        }

        stage('Build') {
            steps {
                echo '🔧 Build step goes here (e.g., npm install, mvn build, etc.)'
            }
        }

        stage('Post-Build') {
            steps {
                echo '✅ Post-build step (like archiving artifacts)'
            }
        }
    }
}
