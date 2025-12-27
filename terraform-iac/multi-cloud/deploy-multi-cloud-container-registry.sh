    #!/usr/bin/env bash
set -euo pipefail

# Multi-cloud container registry deployment:
# - AWS ECR
# - Azure ACR
# - GCP Artifact Registry

usage() {
  echo "Usage: $0 <environment> [plan|apply|destroy]"
  echo "  environment : Name of the environment (e.g., dev, prod)"
  echo "  action      : plan | apply | destroy (default: apply)"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

ENVIRONMENT="$1"
ACTION="${2:-apply}"

case "${ACTION}" in
  plan|apply|destroy) ;;
  *) usage ;;
esac

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

AWS_DIR="${ROOT_DIR}/aws/container-registry"
AZURE_DIR="${ROOT_DIR}/azure/container-registry"
GCP_DIR="${ROOT_DIR}/gcp/container-registry"

AWS_VARS="${AWS_DIR}/env/${ENVIRONMENT}.tfvars"
AZURE_VARS="${AZURE_DIR}/env/${ENVIRONMENT}.tfvars"
GCP_VARS="${GCP_DIR}/env/${ENVIRONMENT}.tfvars"

if [[ ! -f "${AWS_VARS}" ]]; then
  echo "Missing AWS tfvars: ${AWS_VARS}"
  exit 1
fi

if [[ ! -f "${AZURE_VARS}" ]]; then
  echo "Missing Azure tfvars: ${AZURE_VARS}"
  exit 1
fi

if [[ ! -f "${GCP_VARS}" ]]; then
  echo "Missing GCP tfvars: ${GCP_VARS}"
  exit 1
fi

run_terraform() {
  local dir="$1"
  local vars_file="$2"
  local action="$3"

  pushd "${dir}" >/dev/null

  terraform init -input=false

  case "${action}" in
    plan)
      terraform plan -input=false -var-file="${vars_file}"
      ;;
    apply)
      terraform plan -input=false -var-file="${vars_file}" -out="plan_${ENVIRONMENT}.tfplan"
      terraform apply -input=false "plan_${ENVIRONMENT}.tfplan"
      ;;
    destroy)
      terraform destroy -input=false -var-file="${vars_file}"
      ;;
  esac

  popd >/dev/null
}

echo "=== AWS ECR: ${ACTION} (${ENVIRONMENT}) ==="
run_terraform "${AWS_DIR}" "${AWS_VARS}" "${ACTION}"

echo "=== Azure ACR: ${ACTION} (${ENVIRONMENT}) ==="
run_terraform "${AZURE_DIR}" "${AZURE_VARS}" "${ACTION}"

echo "=== GCP Artifact Registry: ${ACTION} (${ENVIRONMENT}) ==="
run_terraform "${GCP_DIR}" "${GCP_VARS}" "${ACTION}"

echo "Multi-cloud container registry ${ACTION} completed for environment: ${ENVIRONMENT}"
