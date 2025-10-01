pipeline {
    agent {
        label 'agent1'
    }
    stages {
        stage('Print env') {
            steps {
                sh 'env'
                sh 'find .'
                sh 'pwd'
                sh 'ls'
            }
        }
        stage('Deploy') {
            environment {
                TF_VAR_HETZNER_API_TOKEN = credentials('hetzner_token')
            }
            steps {
                sh '''
                    sudo apt-get update && sudo apt-get install -y wget unzip
                    wget https://releases.hashicorp.com/terraform/1.13.3/terraform_1.13.3_linux_amd64.zip
                    unzip terraform_1.13.3_linux_amd64.zip
                    sudo mv terraform /usr/local/bin/
                    terraform -v
                    echo $TF_VAR_HETZNER_API_TOKEN
                '''
            }
        }
        stage('Configure') {
            steps {
                echo 'Ansible will run now...'
            }
        }
    }
}