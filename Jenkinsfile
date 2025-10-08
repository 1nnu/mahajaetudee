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

                        // Test connetion to private hosts until reachable
                        sh '''
                        for i in $(seq 1 20);
                        do
                            echo "Attempt $i: Trying connection to private network host"
                            ssh -o StrictHostKeyChecking=no -i $SSH_KEY root@$BASTION_IP "ping -c1 192.168.0.3" >/dev/null 2>&1 || true
                            if [ $? -eq 0 ]; then
                                echo "Connection successful!"
                                break
                            fi
                            sleep 10
                        done
                        '''

                        ansiblePlaybook(
                            playbook: 'playbook.yaml',
                            inventory: 'inventory',
                            credentialsId: 'private-key-hetzner',
                            extraVars: [
                                BASTION_IP: "${BASTION_IP}",
                                ansible_ssh_private_key_file: "${SSH_KEY}"
                            ])
                    }
                }
            }
        }
    }
}