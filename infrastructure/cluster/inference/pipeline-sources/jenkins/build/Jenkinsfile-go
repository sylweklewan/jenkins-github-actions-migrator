pipeline {
    agent { docker { image 'golang:1.25.0-alpine3.22' } }
    stages {
        stage('build') {
            steps {
                sh 'go version'
            }
        }
    }
}