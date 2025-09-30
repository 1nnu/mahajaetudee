pipeline {
    agent {
        label 'agent1'
    }
    stages {
        stage('Checkout') {
            steps {
                echo 'Test webhook...'
            }
        }
        stage('Plan') {
            steps {
                echo 'Testing...'
            }
        }
        stage('Apply') {
            steps {
                echo 'Deploying...'
            }
        }
    }
}