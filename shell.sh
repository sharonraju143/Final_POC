#!/bin/bash

# Fetch public IP addresses from AWS
public_ips=$(aws ec2 describe-instances --region us-east-2 --filters "Name=tag:Name,Values=Kubernetes_Master" --query "Reservations[].Instances[].PublicIpAddress" --output text)

# Check if any public IPs are found
if [ -z "$public_ips" ]; then
  echo "No instances found with the specified tags in the us-east-2 region."
  exit 1
fi

# Append public IPs to Ansible hosts file
for ip in $public_ips; do
  echo "$ip" | sudo tee -a /etc/ansible/hosts > /dev/null
done

echo "Public IP addresses added to Ansible hosts file."
