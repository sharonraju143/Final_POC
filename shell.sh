#!/bin/bash
export AWS_DEFAULT_REGION=us-east-2

# Create AWS config file with default region
mkdir -p ~/.aws
cat << EOF > ~/.aws/config
[default]
region=us-east-2
EOF

# Run DynamicInventory.py with --list option
./DynamicInventory.py --list


chmod 400 k8s.pem

# Run ansible-playbook with DynamicInventory.py and other options
ansible-playbook -i DynamicInventory.py site.yml -u ubuntu --private-key=k8s.pem --ssh-common-args='-o StrictHostKeyChecking=no'
