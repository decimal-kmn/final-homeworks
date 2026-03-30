#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== STEP 1: Destroy infrastructure/main.tf resources ==="
cd "${SCRIPT_DIR}/infrastructure"

# Re-export credentials from environment if they exist
if [ -n "${AWS_ACCESS_KEY_ID}" ] && [ -n "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo "Reusing existing AWS credentials"
fi

terraform init -input=false
terraform destroy -auto-approve

echo "=== STEP 2: Destroy bootstrap/main.tf resources ==="
cd "${SCRIPT_DIR}/bootstrap"

terraform init -input=false
terraform destroy -auto-approve

echo "=== All Terraform resources have been destroyed ==="