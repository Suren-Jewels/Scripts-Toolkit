"""
Cloud Provisioning Tool
Author: Suren Jewels

Automates the creation of cloud resources across Azure and AWS using SDKs and environment variables.
"""

import os
import boto3
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient

# AWS Setup
aws_region = "us-west-2"
aws_client = boto3.client('ec2', region_name=aws_region)

def create_aws_instance():
    print("🚀 Launching AWS EC2 instance...")
    response = aws_client.run_instances(
        ImageId='ami-0abcdef1234567890',
        InstanceType='t2.micro',
        MinCount=1,
        MaxCount=1
    )
    print(f"✅ AWS Instance ID: {response['Instances'][0]['InstanceId']}")

# Azure Setup
azure_credential = DefaultAzureCredential()
azure_client = ResourceManagementClient(azure_credential, os.environ["AZURE_SUBSCRIPTION_ID"])

def create_azure_resource_group():
    print("🚀 Creating Azure Resource Group...")
    rg_result = azure_client.resource_groups.create_or_update(
        "SurenRG",
        {"location": "westus"}
    )
    print(f"✅ Azure Resource Group: {rg_result.name}")

# Main Execution
if __name__ == "__main__":
    create_aws_instance()
    create_azure_resource_group()
    print("🌐 Cloud provisioning complete.")
