#!/bin/bash

# Fetch List of Servers from AWS and group based on EC2 instance tag name and value.

# Initialize variables
declare -A allgroups

# Get running instances and group them based on tags
while IFS= read -r each_in; do
  instance_id=$(echo "$each_in" | awk '{print $1}')
  public_ip=$(echo "$each_in" | awk '{print $2}')
  
  # Get instance tags
  instance_tags=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" --output json)
  
  # Loop through instance tags
  for tag in $(echo "$instance_tags" | jq -r '.Tags[] | @base64'); do
    tag_name=$(echo "$tag" | base64 -d | jq -r '.Key')
    tag_value=$(echo "$tag" | base64 -d | jq -r '.Value')
    
    # Group instances by tag name
    if [[ -n ${allgroups[$tag_name]+_} ]]; then
      allgroups[$tag_name]+=" $public_ip"
    else
      allgroups[$tag_name]="$public_ip"
    fi
    
    # Group instances by tag value
    if [[ -n ${allgroups[$tag_value]+_} ]]; then
      allgroups[$tag_value]+=" $public_ip"
    else
      allgroups[$tag_value]="$public_ip"
    fi
  done
done < <(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId,Reservations[].Instances[].PublicIpAddress" --output text)

# Convert associative array to JSON inventory
inventory=$(declare -p allgroups | awk -F= '{print "\"" $1 "\":" "{\"hosts\":[" $2 "]}"}' | tr -d ' ' | paste -sd, -)

# Output inventory
echo "{$inventory}"
