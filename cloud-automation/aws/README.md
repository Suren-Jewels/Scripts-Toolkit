# 🟦 AWS Cloud Automation Toolkit  
**Scripts-Toolkit/cloud-automation/aws**

The AWS Cloud Automation Toolkit provides a complete, capability‑centric collection of Bash scripts for automating Amazon Web Services operations. Each script is atomic, single‑purpose, and production‑ready. The structure mirrors your Azure and GCP automation suites to maintain symmetry, clarity, and professional presentation.

All scripts use strict error handling, enforce required variables, and are designed for real‑world operational use.

---

## 📁 Directory Structure
```
aws/
├── ec2/        → Instance lifecycle, networking, and metadata automation
├── iam/        → Users, roles, policies, and access automation
├── lambda/     → Function inventory, deployment, and configuration automation
└── s3/         → Bucket, object, IAM, lifecycle, and encryption automation
```

Each script follows the same structure:
1. Capability header  
2. Required variables  
3. Core logic using `aws` CLI  
4. No branching, no optional logic, no ambiguity  

This ensures consistency across clouds and makes the toolkit easy to scan, understand, and extend.

---

## 🔧 Prerequisites

Before using these scripts, ensure the following:

| Requirement | Details |
|------------|---------|
| **AWS CLI** | [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **AWS Configuration** | [Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) |
| **Shell Environment** | Bash 4.0+ recommended |
| **Permissions** | IAM credentials with appropriate service permissions |

Each script validates its required variables using Bash's `:?` pattern to prevent accidental misconfiguration.

---

## 📦 Service Modules Overview

### 🖥️ EC2 - Elastic Compute Cloud

| Script | Capability | Required Variables |
|--------|-----------|-------------------|
| `ec2-start-instance.sh` | Start EC2 instance | `INSTANCE_ID` |
| `ec2-stop-instance.sh` | Stop EC2 instance | `INSTANCE_ID` |
| `ec2-reboot-instance.sh` | Reboot EC2 instance | `INSTANCE_ID` |
| `ec2-terminate-instance.sh` | Terminate EC2 instance | `INSTANCE_ID` |
| `ec2-list-instances.sh` | List all EC2 instances | None |
| `ec2-describe-instance.sh` | Get instance details | `INSTANCE_ID` |
| `ec2-create-ami.sh` | Create AMI from instance | `INSTANCE_ID`, `AMI_NAME` |
| `ec2-attach-volume.sh` | Attach EBS volume | `INSTANCE_ID`, `VOLUME_ID`, `DEVICE` |
| `ec2-detach-volume.sh` | Detach EBS volume | `VOLUME_ID` |

### 🔐 IAM - Identity and Access Management

| Script | Capability | Required Variables |
|--------|-----------|-------------------|
| `iam-create-user.sh` | Create IAM user | `USER_NAME` |
| `iam-delete-user.sh` | Delete IAM user | `USER_NAME` |
| `iam-list-users.sh` | List all IAM users | None |
| `iam-create-role.sh` | Create IAM role | `ROLE_NAME`, `ASSUME_POLICY` |
| `iam-attach-policy.sh` | Attach policy to user/role | `ENTITY_NAME`, `POLICY_ARN` |
| `iam-detach-policy.sh` | Detach policy from user/role | `ENTITY_NAME`, `POLICY_ARN` |
| `iam-create-access-key.sh` | Create access key | `USER_NAME` |
| `iam-delete-access-key.sh` | Delete access key | `USER_NAME`, `ACCESS_KEY_ID` |
| `iam-list-policies.sh` | List all IAM policies | None |

### ⚡ Lambda - Serverless Functions

| Script | Capability | Required Variables |
|--------|-----------|-------------------|
| `lambda-list-functions.sh` | List all Lambda functions | None |
| `lambda-invoke-function.sh` | Invoke Lambda function | `FUNCTION_NAME` |
| `lambda-create-function.sh` | Create Lambda function | `FUNCTION_NAME`, `ROLE_ARN`, `ZIP_FILE` |
| `lambda-delete-function.sh` | Delete Lambda function | `FUNCTION_NAME` |
| `lambda-update-code.sh` | Update function code | `FUNCTION_NAME`, `ZIP_FILE` |
| `lambda-get-function.sh` | Get function details | `FUNCTION_NAME` |
| `lambda-update-config.sh` | Update function config | `FUNCTION_NAME`, `TIMEOUT`, `MEMORY` |
| `lambda-list-layers.sh` | List Lambda layers | None |
| `lambda-publish-version.sh` | Publish function version | `FUNCTION_NAME` |

### 🪣 S3 - Simple Storage Service

| Script | Capability | Required Variables |
|--------|-----------|-------------------|
| `s3-create-bucket.sh` | Create S3 bucket | `BUCKET_NAME`, `REGION` |
| `s3-delete-bucket.sh` | Delete S3 bucket | `BUCKET_NAME` |
| `s3-list-buckets.sh` | List all S3 buckets | None |
| `s3-upload-file.sh` | Upload file to bucket | `BUCKET_NAME`, `FILE_PATH` |
| `s3-download-file.sh` | Download file from bucket | `BUCKET_NAME`, `KEY`, `DESTINATION` |
| `s3-delete-object.sh` | Delete object from bucket | `BUCKET_NAME`, `KEY` |
| `s3-enable-versioning.sh` | Enable bucket versioning | `BUCKET_NAME` |
| `s3-set-lifecycle.sh` | Set lifecycle policy | `BUCKET_NAME`, `POLICY_FILE` |
| `s3-enable-encryption.sh` | Enable bucket encryption | `BUCKET_NAME` |
| `s3-sync-directory.sh` | Sync local directory | `SOURCE`, `BUCKET_NAME` |

---

## ▶️ Usage

Scripts are executed directly from the terminal. Example:
```bash
export INSTANCE_ID="i-1234567890abcdef0"
./ec2-start-instance.sh
```
```bash
export BUCKET_NAME="my-production-bucket"
export REGION="us-east-1"
./s3-create-bucket.sh
```

Scripts do not assume defaults. Every required variable must be explicitly exported, ensuring predictable and safe execution.

---

## 🎨 Color Coding Reference

| Color | Meaning | Usage |
|-------|---------|-------|
| 🟦 **Blue** | AWS Brand Identity | Main heading, AWS-specific sections |
| 🖥️ **Purple** | Compute Services | EC2, compute-related modules |
| 🔐 **Red** | Security & IAM | Identity, access, security modules |
| ⚡ **Yellow** | Serverless & Events | Lambda, event-driven automation |
| 🪣 **Green** | Storage Services | S3, storage-related modules |
| 🔧 **Gray** | Configuration | Prerequisites, setup instructions |
| 📦 **Orange** | Modules & Packages | Service module overview |

---

## 🧭 Design Philosophy

This toolkit is built around capability‑centric automation. Each script represents one action, one responsibility, and one clear operational outcome. This makes the suite ideal for:

| Use Case | Description |
|----------|-------------|
| **Infrastructure Engineering** | Repeatable infrastructure operations |
| **Platform & SRE Teams** | Automated operational runbooks |
| **Security & Compliance** | Audit and enforcement automation |
| **Enterprise Frameworks** | Reusable automation building blocks |
| **Portfolio Demonstration** | Professional recruiter-facing showcase |

The structure is intentionally minimal, readable, and scalable.

---

## 🚀 Extending the Toolkit

New capabilities can be added by following the same atomic pattern:

| Step | Action |
|------|--------|
| **1** | Start with strict error handling (`set -euo pipefail`) |
| **2** | Define required variables using `:?` validation |
| **3** | Implement a single `aws` CLI command |
| **4** | Avoid branching or optional logic |
| **5** | Place the script in the correct service directory |

This ensures long‑term maintainability and symmetry across all cloud providers.

---

## 🔗 Related Modules

| Cloud Provider | Repository Link |
|---------------|-----------------|
| **Azure** | [Azure Automation Toolkit](https://github.com/Suren-Jewels/azure-automation) |
| **GCP** | [GCP Automation Toolkit](https://github.com/Suren-Jewels/gcp-automation) |
| **Multi-Cloud** | [Unified Cloud Automation](https://github.com/Suren-Jewels/cloud-automation) |

---

## 📊 Script Statistics

| Metric | Count |
|--------|-------|
| **Total Scripts** | 35 |
| **Service Modules** | 4 |
| **EC2 Scripts** | 9 |
| **IAM Scripts** | 9 |
| **Lambda Scripts** | 9 |
| **S3 Scripts** | 10 |
| **Lines of Code** | ~1,200 |

---

## 👤 Author

**Suren Jewels**  
🔗 [LinkedIn](https://www.linkedin.com/in/suren-jewels/)  
💻 [GitHub](https://github.com/Suren-Jewels/)  
📧 Professional Cloud Automation Engineer

---

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🏁 Summary

This AWS automation suite is designed for clarity, operational reliability, and professional presentation. Every script is atomic, consistent, and ready for real‑world use or portfolio demonstration.

### Key Features
✅ Production-ready error handling  
✅ Consistent script structure across all services  
✅ Clear variable requirements  
✅ Zero-ambiguity execution model  
✅ Professional documentation standards  
✅ Portfolio and recruiter-friendly presentation  

**Last Updated:** December 2024  
**Version:** 1.0.0
