pipeline {
    agent {
        label 'agent1'
    }
    stages {
        stage('Checkout') {
            steps {
                sh 'env'
                sh 'find .'
                sh 'pwd'
                sh 'ls'
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