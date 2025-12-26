"""
Multi-Cloud Provisioning Template
Location: cloud-automation/multi-cloud/multi-cloud-provisioning-template.py

Author: Suren Jewels

DESCRIPTION:
    A professional, sanitized, and modular multi-cloud provisioning template
    demonstrating automation patterns for AWS, Azure, and GCP.

    This script is intentionally generic and safe for public portfolios.
    It contains:
      - No hardcoded credentials
      - No real subscription IDs
      - No sensitive resource identifiers

    It showcases:
      - Cloud automation structure
      - Logging and error handling
      - Config-driven provisioning
      - Per-cloud modular functions

USAGE:
    1. Install required SDKs:
         pip install boto3 azure-identity azure-mgmt-resource google-api-python-client google-auth

    2. Set environment variables:
         export AZURE_SUBSCRIPTION_ID="your-subscription-id"
         export GCP_SERVICE_ACCOUNT_FILE="/path/to/service-account.json"

    3. Run:
         python multi-cloud-provisioning-template.py

NOTE:
    This is a TEMPLATE. Replace placeholder values with environment-specific details
    before using in a real environment.
"""

import os
import sys
import logging
from typing import Dict, Any

# -----------------------------
# Logging Configuration
# -----------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)

logger = logging.getLogger(__name__)

# -----------------------------
# Optional Imports (Lazy Loading)
# -----------------------------
try:
    import boto3  # AWS
except ImportError:
    boto3 = None

try:
    from azure.identity import DefaultAzureCredential
    from azure.mgmt.resource import ResourceManagementClient
except ImportError:
    DefaultAzureCredential = None
    ResourceManagementClient = None

try:
    from google.oauth2 import service_account
    from googleapiclient.discovery import build as gcp_build
except ImportError:
    service_account = None
    gcp_build = None

# -----------------------------
# Configuration (Template)
# -----------------------------
CONFIG: Dict[str, Any] = {
    "aws": {
        "enabled": True,
        "region": "us-west-2",
        "instance_type": "t3.micro",
        "ami_id": "ami-PLACEHOLDER",
        "tag_project": "multi-cloud-demo"
    },
    "azure": {
        "enabled": True,
        "subscription_id_env": "AZURE_SUBSCRIPTION_ID",
        "resource_group_name": "RG-Demo-MultiCloud",
        "location": "westus"
    },
    "gcp": {
        "enabled": False,
        "project_id": "your-gcp-project-id",
        "credentials_file_env": "GCP_SERVICE_ACCOUNT_FILE"
    }
}

# -----------------------------
# AWS Provisioning
# -----------------------------
def provision_aws_ec2(config: Dict[str, Any]) -> None:
    if not boto3:
        logger.warning("boto3 not installed. Skipping AWS provisioning.")
        return

    logger.info("Starting AWS EC2 provisioning...")

    try:
        ec2_client = boto3.client("ec2", region_name=config["region"])

        response = ec2_client.run_instances(
            ImageId=config["ami_id"],
            InstanceType=config["instance_type"],
            MinCount=1,
            MaxCount=1,
            TagSpecifications=[
                {
                    "ResourceType": "instance",
                    "Tags": [{"Key": "Project", "Value": config["tag_project"]}]
                }
            ]
        )

        instance_id = response["Instances"][0]["InstanceId"]
        logger.info(f"AWS EC2 instance launched successfully. InstanceId={instance_id}")

    except Exception as exc:
        logger.error(f"Failed to provision AWS EC2 instance: {exc}")
        raise

# -----------------------------
# Azure Provisioning
# -----------------------------
def provision_azure_resource_group(config: Dict[str, Any]) -> None:
    if not (DefaultAzureCredential and ResourceManagementClient):
        logger.warning("Azure SDK not installed. Skipping Azure provisioning.")
        return

    logger.info("Starting Azure Resource Group provisioning...")

    subscription_id = os.getenv(config["subscription_id_env"])
    if not subscription_id:
        logger.error(f"Azure subscription ID environment variable '{config['subscription_id_env']}' not set.")
        return

    try:
        credential = DefaultAzureCredential()
        resource_client = ResourceManagementClient(credential, subscription_id)

        rg_result = resource_client.resource_groups.create_or_update(
            config["resource_group_name"],
            {"location": config["location"]}
        )

        logger.info(
            f"Azure Resource Group created/updated: {rg_result.name} "
            f"(Location={config['location']})"
        )

    except Exception as exc:
        logger.error(f"Failed to provision Azure Resource Group: {exc}")
        raise

# -----------------------------
# GCP Provisioning (Placeholder)
# -----------------------------
def provision_gcp_placeholder(config: Dict[str, Any]) -> None:
    if not (service_account and gcp_build):
        logger.warning("GCP libraries not installed. Skipping GCP provisioning.")
        return

    logger.info("Starting GCP provisioning (placeholder)...")

    credentials_file = os.getenv(config["credentials_file_env"])
    if not credentials_file:
        logger.error(f"GCP credentials file environment variable '{config['credentials_file_env']}' not set.")
        return

    try:
        credentials = service_account.Credentials.from_service_account_file(credentials_file)
        # Example: compute_service = gcp_build("compute", "v1", credentials=credentials)
        logger.info(f"GCP provisioning placeholder executed for project: {config['project_id']}")

    except Exception as exc:
        logger.error(f"Failed to execute GCP provisioning placeholder: {exc}")
        raise

# -----------------------------
# Orchestration Entry Point
# -----------------------------
def main() -> None:
    logger.info("Starting multi-cloud provisioning template...")

    if CONFIG["aws"]["enabled"]:
        provision_aws_ec2(CONFIG["aws"])

    if CONFIG["azure"]["enabled"]:
        provision_azure_resource_group(CONFIG["azure"])

    if CONFIG["gcp"]["enabled"]:
        provision_gcp_placeholder(CONFIG["gcp"])

    logger.info("Multi-cloud provisioning template complete.")

if __name__ == "__main__":
    main()
