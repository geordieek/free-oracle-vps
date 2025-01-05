#!/bin/bash
# Script to keep retrying to create a VM

MAX_RETRIES=100
RETRY_INTERVAL=10

for ((i = 1; i <= MAX_RETRIES; i++)); do
  echo "Attempt $i to create the VM..."
  terraform apply -var-file=terraform.tfvars -auto-approve
  if [ $? -eq 0 ]; then
    echo "VM created successfully!"
    break
  else
    echo "VM creation failed, retrying in $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
    RETRY_INTERVAL=$((RETRY_INTERVAL * 2)) # Exponential backoff
  fi
done
