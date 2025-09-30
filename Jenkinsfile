pipeline {
    agent {
        label 'agent1'
    }
    stages {
        stage('Checkout') {
            steps {
                env
                find .
                pwd
                ls
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