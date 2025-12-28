# ☁️ GCP Cloud Automation Toolkit

**Scripts-Toolkit/cloud-automation/gcp**

The GCP Cloud Automation Toolkit provides a complete, capability-centric collection of Bash scripts for automating Google Cloud Platform operations. Each script is atomic, single-purpose, and production-ready. The structure mirrors your AWS and Azure automation suites to maintain symmetry, clarity, and professional presentation.

All scripts use strict error handling, enforce required variables, and are designed for real-world operational use.

---

## 📁 Directory Structure
```
gcp/
├── compute/    # VM lifecycle, networking, and metadata automation
├── iam/        # Identity, roles, and policy automation
└── storage/    # Bucket, object, IAM, lifecycle, and retention automation
```

### Script Organization

| Directory | Purpose | Script Count |
|-----------|---------|--------------|
| `compute/` | VM instances, networking, metadata | 15+ scripts |
| `iam/` | Service accounts, roles, policies | 12+ scripts |
| `storage/` | Buckets, objects, lifecycle management | 18+ scripts |

---

## 🏗️ Script Structure

Each script follows the same consistent structure:

| Section | Purpose | Implementation |
|---------|---------|----------------|
| **1. Capability Header** | Describes script purpose | Clear comment block |
| **2. Required Variables** | Enforces prerequisites | Bash `:?` validation |
| **3. Core Logic** | Single `gcloud` command | No branching/conditionals |
| **4. Error Handling** | Strict execution mode | `set -euo pipefail` |

This ensures consistency across clouds and makes the toolkit easy to scan, understand, and extend.

---

## 🔧 Prerequisites

Before using these scripts, ensure the following:

| Requirement | Installation | Documentation |
|-------------|--------------|---------------|
| **Google Cloud SDK** | `curl https://sdk.cloud.google.com \| bash` | [Install Guide](https://cloud.google.com/sdk) |
| **Authentication** | `gcloud auth login` | [Auth Docs](https://cloud.google.com/sdk/docs/authorizing) |
| **Project Setup** | `gcloud config set project PROJECT_ID` | [Configuration](https://cloud.google.com/sdk/docs/initializing) |
| **Bash 4.0+** | Pre-installed on most systems | Required for strict mode |

### Validation

Each script validates its required variables using Bash's `:?` pattern to prevent accidental misconfiguration:
```bash
: "${PROJECT_ID:?PROJECT_ID must be set}"
: "${BUCKET_NAME:?BUCKET_NAME must be set}"
```

---

## ▶️ Usage

### Basic Execution Pattern
```bash
# 1. Export required variables
export PROJECT_ID="my-project"
export BUCKET_NAME="my-bucket"

# 2. Execute script
./storage/bucket-list.sh
```

### Common Variable Patterns

| Variable Type | Example | Usage |
|---------------|---------|-------|
| **Project** | `PROJECT_ID="prod-app"` | All scripts |
| **Resource Names** | `INSTANCE_NAME="web-01"` | Compute scripts |
| **Regions/Zones** | `ZONE="us-central1-a"` | Geographic resources |
| **IAM** | `SERVICE_ACCOUNT="sa@project.iam"` | Identity scripts |

### Execution Safety

✅ **Do:** Explicitly set all required variables  
✅ **Do:** Review script output before production use  
✅ **Do:** Test in dev/staging environments first  

❌ **Don't:** Rely on implicit defaults  
❌ **Don't:** Skip variable validation  
❌ **Don't:** Run untested scripts in production  

---

## 📂 Capability Matrix

### Compute Operations

| Script | Capability | Required Variables | Output |
|--------|------------|-------------------|--------|
| `instance-create.sh` | Create VM instance | `PROJECT_ID`, `INSTANCE_NAME`, `ZONE` | Instance details |
| `instance-list.sh` | List all instances | `PROJECT_ID`, `ZONE` | Instance inventory |
| `instance-start.sh` | Start stopped instance | `PROJECT_ID`, `INSTANCE_NAME`, `ZONE` | Status confirmation |
| `instance-stop.sh` | Stop running instance | `PROJECT_ID`, `INSTANCE_NAME`, `ZONE` | Status confirmation |
| `instance-delete.sh` | Delete instance | `PROJECT_ID`, `INSTANCE_NAME`, `ZONE` | Deletion confirmation |

### IAM Operations

| Script | Capability | Required Variables | Output |
|--------|------------|-------------------|--------|
| `service-account-create.sh` | Create service account | `PROJECT_ID`, `ACCOUNT_NAME` | Account details |
| `service-account-list.sh` | List service accounts | `PROJECT_ID` | Account inventory |
| `role-grant.sh` | Grant IAM role | `PROJECT_ID`, `MEMBER`, `ROLE` | Policy binding |
| `role-revoke.sh` | Revoke IAM role | `PROJECT_ID`, `MEMBER`, `ROLE` | Policy unbinding |
| `policy-get.sh` | Get IAM policy | `PROJECT_ID` | Current policy JSON |

### Storage Operations

| Script | Capability | Required Variables | Output |
|--------|------------|-------------------|--------|
| `bucket-create.sh` | Create storage bucket | `PROJECT_ID`, `BUCKET_NAME`, `LOCATION` | Bucket URI |
| `bucket-list.sh` | List all buckets | `PROJECT_ID` | Bucket inventory |
| `bucket-delete.sh` | Delete bucket | `BUCKET_NAME` | Deletion confirmation |
| `object-upload.sh` | Upload object | `BUCKET_NAME`, `FILE_PATH` | Object URI |
| `object-download.sh` | Download object | `BUCKET_NAME`, `OBJECT_NAME` | Local file path |
| `lifecycle-set.sh` | Configure lifecycle | `BUCKET_NAME`, `LIFECYCLE_JSON` | Policy details |

---

## 🧭 Design Philosophy

This toolkit is built around **capability-centric automation**:

| Principle | Implementation | Benefit |
|-----------|----------------|---------|
| **Atomic Operations** | One script = one action | Clear responsibility |
| **Explicit Configuration** | No default assumptions | Predictable behavior |
| **Strict Validation** | Required variable checks | Prevents misconfigurations |
| **Cloud Symmetry** | Mirrors AWS/Azure structure | Cross-cloud consistency |
| **Production Ready** | Error handling + logging | Enterprise reliability |

### Use Cases

| Use Case | Application | Value |
|----------|-------------|-------|
| **Infrastructure Engineering** | Automated provisioning workflows | Reduced manual effort |
| **Platform/SRE Teams** | Standardized operations | Consistency at scale |
| **Security/Compliance** | Policy enforcement automation | Audit trail + governance |
| **CI/CD Integration** | Pipeline automation steps | DevOps velocity |
| **Portfolio Demonstration** | Technical capability showcase | Professional presentation |

---

## 🚀 Extending the Toolkit

### Adding New Scripts

Follow this pattern to maintain consistency:

| Step | Action | Example |
|------|--------|---------|
| **1** | Add strict error handling | `set -euo pipefail` |
| **2** | Define required variables | `: "${VAR:?Must be set}"` |
| **3** | Implement single command | `gcloud compute instances list` |
| **4** | Document in README | Update capability matrix |
| **5** | Place in correct directory | `compute/`, `iam/`, `storage/` |

### Example Template
```bash
#!/bin/bash
set -euo pipefail

# Required variables
: "${PROJECT_ID:?PROJECT_ID must be set}"
: "${RESOURCE_NAME:?RESOURCE_NAME must be set}"

# Core logic
gcloud [service] [resource] [action] \
  --project="${PROJECT_ID}" \
  --name="${RESOURCE_NAME}"
```

---

## 🔗 Related Modules

| Cloud Provider | Repository | Status |
|----------------|------------|--------|
| **AWS** | [aws-automation](https://github.com/Suren-Jewels) | ✅ Active |
| **Azure** | [azure-automation](https://github.com/Suren-Jewels) | ✅ Active |
| **GCP** | [gcp-automation](https://github.com/Suren-Jewels) | ✅ Current |

---

## 📊 Quick Reference

### Color-Coded Status Legend

| Symbol | Meaning | Context |
|--------|---------|---------|
| ✅ | Recommended / Safe | Best practices |
| ⚠️ | Caution Required | Review carefully |
| ❌ | Not Recommended | Avoid this approach |
| 🔧 | Configuration | Setup required |
| 📝 | Documentation | Reference material |
| 🚀 | Performance | Optimized approach |

---

## 👤 Author

**Suren Jewels**

| Platform | Link |
|----------|------|
| **LinkedIn** | [linkedin.com/in/suren-jewels](https://www.linkedin.com/in/suren-jewels/) |
| **GitHub** | [github.com/Suren-Jewels](https://github.com/Suren-Jewels/) |
| **Portfolio** | [scripts-toolkit](https://github.com/Suren-Jewels/scripts-toolkit) |

---

## 🏁 Summary

### Key Features

| Feature | Description |
|---------|-------------|
| **45+ Production Scripts** | Covering compute, IAM, and storage |
| **100% Atomic Operations** | Single-purpose, no branching logic |
| **Enterprise-Grade** | Strict validation + error handling |
| **Cloud-Symmetric** | Consistent with AWS/Azure toolkits |
| **Portfolio-Ready** | Professional documentation + structure |

### Ideal For

✅ Infrastructure automation engineers  
✅ Platform and SRE teams  
✅ DevOps/CloudOps professionals  
✅ Technical portfolio showcases  
✅ Enterprise automation frameworks  

This GCP automation suite is designed for **clarity**, **operational reliability**, and **professional presentation**. Every script is atomic, consistent, and ready for real-world use or portfolio demonstration.

---

**License:** MIT | **Version:** 1.0.0 | **Last Updated:** December 2025
