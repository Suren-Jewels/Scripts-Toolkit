#!/usr/bin/env bash
set -euo pipefail

# Launch EC2 instance automation:
# - AMI selection
# - Instance type
# - Key pair
# - Security groups
# - Tags

usage() {
  echo "Usage: $0 <name> <ami_id> <instance_type> <key_name> <security_group_id> <subnet_id>"
  echo "  name               : EC2 instance name"
  echo "  ami_id             : AMI ID to launch"
  echo "  instance_type      : EC2 instance type"
  echo "  key_name           : SSH key pair name"
  echo "  security_group_id  : Security group ID"
  echo "  subnet_id          : Subnet ID"
  exit 1
}

if [[ $# -ne 6 ]]; then
  usage
fi

NAME="$1"
AMI_ID="$2"
INSTANCE_TYPE="$3"
KEY_NAME="$4"
SECURITY_GROUP_ID="$5"
SUBNET_ID="$6"

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "${AMI_ID}" \
  --instance-type "${INSTANCE_TYPE}" \
  --key-name "${KEY_NAME}" \
  --security-group-ids "${SECURITY_GROUP_ID}" \
  --subnet-id "${SUBNET_ID}" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NAME}}]" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "EC2 instance launched: ${INSTANCE_ID}"
