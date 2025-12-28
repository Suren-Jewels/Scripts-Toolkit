# 🌐 Multi‑Cloud Provisioning Toolkit  
Unified automation template for provisioning across AWS, Azure, and GCP.

This module provides a **starter script** for orchestrating infrastructure across multiple clouds using a single, parameterized Python template.  
It is designed to be **extended**, **modularized**, and eventually split into atomic capabilities that match the structure of your AWS, Azure, and GCP modules.

---

## 📁 Directory Contents

| Path | Description |
|------|-------------|
| `multi-cloud/` | Root directory for multi-cloud provisioning |
| `└── multi-cloud-provisioning-template.py` | Main orchestration template script |

---

## 🧩 Template Highlights

| Feature | Description |
|---------|-------------|
| **Language** | Python for cross-cloud orchestration |
| **Input Model** | Parameterized inputs for cloud selection, resource naming, and configuration |
| **Cloud Support** | Starter logic blocks for AWS, Azure, and GCP provisioning |
| **Architecture** | Designed for copy-paste modularity into atomic scripts |

---

## 🎨 Cloud Provider Color Codes

| Provider | Color | Hex Code | Usage |
|----------|-------|----------|-------|
| **AWS** | 🟠 Orange | `#FF9900` | AWS resources and blocks |
| **Azure** | 🔵 Blue | `#0078D4` | Azure resources and blocks |
| **GCP** | 🔴 Red | `#EA4335` | GCP resources and blocks |
| **Multi-Cloud** | 🟣 Purple | `#7B68EE` | Unified/shared components |

---

## 🚀 Quick Start

### 1️⃣ Navigate to Directory
```bash
cd Scripts-Toolkit/cloud-automation/multi-cloud
```

### 2️⃣ Review Template Structure
```bash
cat multi-cloud-provisioning-template.py
```

### 3️⃣ Execute Provisioning
```bash
python multi-cloud-provisioning-template.py \
  --cloud aws \
  --region us-east-1 \
  --resource-name my-resource
```

---

## 📊 Supported Resource Types

| Resource Type | AWS | Azure | GCP | Status |
|--------------|:---:|:-----:|:---:|--------|
| Virtual Machines | ✅ | ✅ | ✅ | Implemented |
| Storage Buckets | ✅ | ✅ | ✅ | Implemented |
| Virtual Networks | ✅ | ✅ | ✅ | Implemented |
| Load Balancers | 🟡 | 🟡 | 🟡 | Partial |
| Databases | 🔴 | 🔴 | 🔴 | Planned |
| Container Orchestration | 🔴 | 🔴 | 🔴 | Planned |

**Legend:**  
✅ Fully Implemented | 🟡 Partial Support | 🔴 Not Yet Available

---

## ⚙️ Configuration Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `--cloud` | string | ✅ | - | Target cloud provider (`aws`, `azure`, `gcp`) |
| `--region` | string | ✅ | - | Cloud region/location |
| `--resource-name` | string | ✅ | - | Name prefix for resources |
| `--environment` | string | ❌ | `dev` | Environment tag (`dev`, `staging`, `prod`) |
| `--dry-run` | boolean | ❌ | `false` | Preview changes without applying |

---

## 🔧 Template Architecture
```
┌─────────────────────────────────────────┐
│     Multi-Cloud Provisioning Engine     │
├─────────────────────────────────────────┤
│  ┌───────────┐  ┌───────────┐  ┌──────┐ │
│  │🟠 AWS     │  │🔵 Azure  │  │🔴GCP │ │
│  │ Adapter   │  │ Adapter   │  │Adapt.│ │
│  └─────┬─────┘  └─────┬─────┘  └───┬──┘ │
│        │              │            │    │
│  ┌─────▼──────────────▼────────────▼───┐│
│  │   Unified Parameter Validation      ││
│  └─────────────────┬───────────────────┘│
│                    │                    │
│  ┌─────────────────▼───────────────────┐│
│  │    Resource Provisioning Logic      ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

---

## 📝 Example Usage Scenarios

### Scenario 1: AWS EC2 Instance
```bash
python multi-cloud-provisioning-template.py \
  --cloud aws \
  --region us-west-2 \
  --resource-name web-server \
  --environment prod
```

### Scenario 2: Azure Virtual Machine
```bash
python multi-cloud-provisioning-template.py \
  --cloud azure \
  --region eastus \
  --resource-name api-server \
  --environment staging
```

### Scenario 3: GCP Compute Engine
```bash
python multi-cloud-provisioning-template.py \
  --cloud gcp \
  --region us-central1 \
  --resource-name data-processor \
  --environment dev
```

---

## 🛠️ Extension Points

| Extension Area | Implementation Status | Priority |
|----------------|----------------------|----------|
| Custom tagging strategies | 🔴 Not Started | High |
| Cost estimation integration | 🔴 Not Started | High |
| State management (Terraform) | 🔴 Not Started | Medium |
| Rollback mechanisms | 🔴 Not Started | Medium |
| Multi-region orchestration | 🔴 Not Started | Low |

---

## 📚 Related Modules

| Module | Path | Purpose |
|--------|------|---------|
| AWS Automation | `../aws/` | AWS-specific provisioning scripts |
| Azure Automation | `../azure/` | Azure-specific provisioning scripts |
| GCP Automation | `../gcp/` | GCP-specific provisioning scripts |

---

## 🤝 Contributing

When extending this template, follow these conventions:

- 🟠 **AWS blocks**: Use boto3 SDK
- 🔵 **Azure blocks**: Use Azure SDK for Python
- 🔴 **GCP blocks**: Use Google Cloud Client Libraries
- 🟣 **Shared logic**: Keep cloud-agnostic in base classes

---

## 📄 License

Part of the Scripts-Toolkit project. See root LICENSE for details.

---

## 🔗 Quick Links

| Resource | URL |
|----------|-----|
| AWS CLI Documentation | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| Azure CLI Documentation | [learn.microsoft.com/cli/azure](https://learn.microsoft.com/cli/azure/) |
| GCP CLI Documentation | [cloud.google.com/sdk/gcloud](https://cloud.google.com/sdk/gcloud/) |
