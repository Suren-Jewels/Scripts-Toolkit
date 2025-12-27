#!/usr/bin/env bash
set -euo pipefail

# Governance guardrails compliance template:
# - Tagging enforcement
# - Resource policy guardrails
# - Cost and quota governance

usage() {
  echo "Usage: $0 <environment> [plan|apply]"
  echo "  environment : Name of the environment (e.g., dev, prod)"
  echo "  action      : plan | apply (default: apply)"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

ENVIRONMENT="$1"
ACTION="${2:-apply}"

case "${ACTION}" in
  plan|apply) ;;
  *) usage ;;
esac

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${TEMPLATE_DIR}/governance-guardrails"

VARS_FILE="${TF_DIR}/env/${ENVIRONMENT}.tfvars"

if [[ ! -f "${VARS_FILE}" ]]; then
  echo "Missing tfvars: ${VARS_FILE}"
  exit 1
fi

pushd "${TF_DIR}" >/dev/null

terraform init -input=false

case "${ACTION}" in
  plan)
    terraform plan -input=false -var-file="${VARS_FILE}"
    ;;
  apply)
    terraform plan -input=false -var-file="${VARS_FILE}" -out="plan_${ENVIRONMENT}.tfplan"
    terraform apply -input=false "plan_${ENVIRONMENT}.tfplan"
    ;;
esac

popd >/dev/null

echo "Governance guardrails compliance template ${ACTION} completed for environment: ${ENVIRONMENT}"
