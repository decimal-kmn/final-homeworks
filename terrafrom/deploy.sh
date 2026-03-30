#!/bin/bash

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== STEP 1: Run Terraform from bootstrap/main.tf ==="
cd "${SCRIPT_DIR}/bootstrap"

# Initialize and apply bootstrap
terraform init -input=false
terraform apply -auto-approve

# Extract output variables: sa_access_key and sa_secret_key
BOOTSTRAP_ACCESS_KEY=$(terraform output -json | jq -r '.sa_access_key.value')
BOOTSTRAP_SECRET_KEY=$(terraform output -json | jq -r '.sa_secret_key.value')

echo "Extracted sa_access_key: ${BOOTSTRAP_ACCESS_KEY}"
echo "Extracted sa_secret_key: ${BOOT_SECRET_KEY}"

echo "=== STEP 2: Export AWS Credentials"
export AWS_ACCESS_KEY_ID="${BOOTSTRAP_ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${BOOTSTRAP_SECRET_KEY}"

echo "Exported AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY for current shell"

echo "=== STEP 3: Run Terraform from infrastructure/main.tf ==="
cd "${SCRIPT_DIR}/infrastructure"

# Initialize and apply infrastructure
terraform init -input=false

# Pass credentials explicitly if needed
terraform apply \
  -auto-approve \
  -input=false

terraform output -raw ansible_inventory > ../../ansible/inventory.ini

echo "=== STEP 4: Run Ansible config ==="
#cd ../../ansible
#ansible-playbook -i inventory.ini site.yml -u ubuntu

# get sa keys
# yc iam key create --service-account-id xxx --output ~/.authorized_key.json
