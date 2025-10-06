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
                TF_VAR_HETZNER_API_TOKEN = credentials('HETZNER_API_TOKEN')
                PATH = "$PATH:/tmp"
                AWS_DEFAULT_REGION = 'eu-west-1'
                AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
                AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
            }
            steps {
                sh '''
                    if ! [ -f "/tmp/terraform" ]; then 
                        rm terraform_1.13.3_linux_amd64.zip
                        wget https://releases.hashicorp.com/terraform/1.13.3/terraform_1.13.3_linux_amd64.zip
                        unzip -j terraform_1.13.3_linux_amd64.zip terraform -d /tmp
                        chmod +x /tmp/terraform
                    fi
                    terraform -v
                '''
                dir('terraform'){
                    withCredentials([string(credentialsId: 'public-key-hetzner', variable: 'PUBLIC_KEY')]){
                        sh 'echo "$PUBLIC_KEY" > public.pub'
                    }
                    sh '''
                        terraform init
                        terraform plan
                        terraform apply -auto-approve
                    '''
                    script {
                        def bastion_ip = sh(
                            script: "terraform output -raw bastion_ip",
                            returnStdout: true
                        ).trim()
                        env.BASTION_IP = bastion_ip
                        echo "Bastion host IP: ${env.BASTION_IP}"
                    }
                }
            }
        }
        stage("Execute Ansible") {
            environment {
                HCLOUD_TOKEN = credentials('HETZNER_API_TOKEN')
            }
            steps {
                dir('ansible') {
                    withCredentials([sshUserPrivateKey(credentialsId: "private-key-hetzner", keyFileVariable: 'SSH_KEY')]) {
                        // For debug purposes
                        // ansible-inventory -i inventory --list
                        
                        ansiblePlaybook(
                            playbook: 'playbook.yaml',
                            inventory: 'inventory',
                            credentialsId: 'private-key-hetzner',
                            extraVars{
                                extraVar("BASTION_IP", "$BASTION_IP", false)
                                extraVar("ansible_ssh_private_key_file", "$SSH_KEY", true)
                            })
                    }
                }
            }
        }
    }
}