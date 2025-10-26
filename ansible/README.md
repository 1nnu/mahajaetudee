Development commands:

Playbook

ansible-playbook playbook.yaml -i inventory/ -e "BASTION_IP={IP_ADDRESS}" -e "ansible_ssh_private_key_file=../../../.ssh/jenkins"

Inventory

ansible-inventory -i inventory/ --list


Get variables

ansible all -m debug -a "var=vars all" -i inventory/ -e "BASTION_IP={IP_ADDRESS}" -e "ansible_ssh_private_key_file=../../../.ssh/jenkins"

SSH through bastion

ssh root@{BASTION_IP} -i ~/.ssh/jenkins -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i ~/.ssh/jenkins -o StrictHostKeyChecking=no -W %h:%p root@{PRIVATE_HOST_IP}"
