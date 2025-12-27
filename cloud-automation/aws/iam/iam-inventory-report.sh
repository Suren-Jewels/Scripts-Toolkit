#!/usr/bin/env bash
set -euo pipefail

# IAM inventory reporting:
# - List users
# - List roles
# - List groups

usage() {
  echo "Usage: $0"
  exit 1
}

aws iam list-users \
  --query "Users[].{UserName:UserName,Created:CreateDate}" \
  --output table

aws iam list-roles \
  --query "Roles[].{RoleName:RoleName,Created:CreateDate}" \
  --output table

aws iam list-groups \
  --query "Groups[].{GroupName:GroupName,Created:CreateDate}" \
  --output table
