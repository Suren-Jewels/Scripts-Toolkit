# ☁️ Cloud Automation Suite

<div align="center">

**Atomic, symmetric, enterprise-grade automation for AWS, Azure, GCP, and multi-cloud environments.**

[![Multi-Cloud](https://img.shields.io/badge/Multi--Cloud-AWS%20%7C%20Azure%20%7C%20GCP-blue?style=flat-square)](.)
[![Enterprise Grade](https://img.shields.io/badge/Enterprise-IL4%2FIL5%20Ready-success?style=flat-square)](.)
[![Zero Trust](https://img.shields.io/badge/Security-Zero%20Trust-critical?style=flat-square)](.)

</div>

---

## 📖 Overview

This directory is the heart of the **Scripts-Toolkit**, delivering modular, copy-paste-ready scripts for cloud infrastructure, security, monitoring, and provisioning.

Each module is structured for **clarity**, **atomicity**, and **multi-cloud symmetry** — ideal for aerospace, enterprise, and regulated workloads.

---

## 📁 Directory Structure
```
cloud-automation/
├── 🌩️ aws/          # Amazon Web Services automation
├── 🟦 azure/        # Microsoft Azure automation
├── ☁️ gcp/          # Google Cloud Platform automation
└── 🌐 multi-cloud/  # Unified provisioning across clouds
```

| Directory | Purpose | Key Capabilities |
|-----------|---------|------------------|
| **🌩️ aws/** | Amazon Web Services | EC2, S3, IAM, VPC, Security Groups |
| **🟦 azure/** | Microsoft Azure | Network, Monitor, Key Vault, VM, Storage |
| **☁️ gcp/** | Google Cloud Platform | Compute, Storage, IAM, Firewall |
| **🌐 multi-cloud/** | Cross-Cloud Templates | Unified provisioning patterns |

---

## 🧩 Design Philosophy

| Principle | Description |
|-----------|-------------|
| **⚛️ Atomic Capabilities** | One script = one action, no side effects |
| **✅ Strict Validation** | Every variable required and enforced |
| **🔄 Symmetric Structure** | Identical naming and layout across clouds |
| **🎯 Zero Noise** | No logging, no chaining, no ambiguity |
| **🏢 Enterprise Alignment** | IL4/IL5, FedRAMP, Zero Trust-friendly |

---

## ☁️ Cloud Modules

### 🌩️ AWS Module

<table>
<tr>
<td width="50%">

**Capabilities**
- EC2 instance management
- S3 bucket operations
- IAM policies & roles
- VPC networking

</td>
<td width="50%">

**Security Features**
- Security group rules
- Bucket policies
- Lifecycle management
- Access controls

</td>
</tr>
</table>

**→** [Explore AWS Module](./aws)

---

### 🟦 Azure Module

<table>
<tr>
<td width="50%">

**Infrastructure**
- Virtual Networks
- Virtual Machines
- Storage Accounts
- Key Vault

</td>
<td width="50%">

**Operations**
- NSG rules
- Alerts & diagnostics
- Secrets management
- Autoscaling

</td>
</tr>
</table>

**→** [Explore Azure Module](./azure)

---

### ☁️ GCP Module

<table>
<tr>
<td width="50%">

**Core Services**
- Compute Engine
- Cloud Storage
- IAM & Service Accounts

</td>
<td width="50%">

**Security**
- Firewall rules
- Bucket permissions
- Access policies

</td>
</tr>
</table>

**→** [Explore GCP Module](./gcp)

---

### 🌐 Multi-Cloud Module

<table>
<tr>
<td>

**Unified Patterns**
- Cross-cloud provisioning templates
- Standardized variable schemas
- Symmetric operational workflows
- Future: atomic cross-cloud scripts

</td>
</tr>
</table>

**→** [Explore Multi-Cloud Templates](./multi-cloud)

---

## 🚀 Quick Start

### Step 1: Set Environment Variables
```bash
# Example: Azure Virtual Network creation
export RESOURCE_GROUP="rg-demo"
export LOCATION="eastus"
export VNET_NAME="vnet-production"
export ADDRESS_SPACE="10.0.0.0/16"
```

### Step 2: Execute Script
```bash
cd azure/network
./vnet-create.sh
```

### Step 3: Verify
```bash
az network vnet show \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME
```

---

## 📊 Feature Comparison Matrix

| Feature | AWS | Azure | GCP | Multi-Cloud |
|---------|:---:|:-----:|:---:|:-----------:|
| **Compute** | ✅ | ✅ | ✅ | 🔄 |
| **Storage** | ✅ | ✅ | ✅ | 🔄 |
| **Network** | ✅ | ✅ | ✅ | 🔄 |
| **IAM/Security** | ✅ | ✅ | ✅ | 🔄 |
| **Monitoring** | ✅ | ✅ | 🔄 | ⏳ |
| **Secrets** | ✅ | ✅ | 🔄 | ⏳ |

**Legend:** ✅ Complete | 🔄 In Progress | ⏳ Planned

---

## 🔐 Security & Compliance

<table>
<tr>
<th>Standard</th>
<th>Status</th>
<th>Notes</th>
</tr>
<tr>
<td><strong>IL4/IL5</strong></td>
<td>🟢 Ready</td>
<td>Impact Level compliance patterns</td>
</tr>
<tr>
<td><strong>FedRAMP</strong></td>
<td>🟢 Ready</td>
<td>Federal authorization standards</td>
</tr>
<tr>
<td><strong>Zero Trust</strong></td>
<td>🟢 Ready</td>
<td>Least-privilege, validate-always</td>
</tr>
<tr>
<td><strong>NIST 800-53</strong></td>
<td>🟡 Aligned</td>
<td>Security control framework</td>
</tr>
</table>

---

## 🔗 Navigation

| Resource | Link |
|----------|------|
| 🏠 **Root Toolkit** | [Scripts-Toolkit](../..) |
| 🌩️ **AWS Module** | [./aws](./aws) |
| 🟦 **Azure Module** | [./azure](./azure) |
| ☁️ **GCP Module** | [./gcp](./gcp) |
| 🌐 **Multi-Cloud** | [./multi-cloud](./multi-cloud) |

---

## 👤 Author

<table>
<tr>
<td width="20%" align="center">
<img src="https://github.com/surenjewels.png" width="100px" style="border-radius:50%"/>
</td>
<td width="80%">

**Suren Jewels**  
*Cloud & Infrastructure Engineer*

Specializing in Security, Automation, and Multi-Cloud Architecture

🌐 [LinkedIn](https://linkedin.com/in/surenjewels) | 💻 [GitHub](https://github.com/surenjewels) | ✉️ SurenJewelsPro@gmail.com

</td>
</tr>
</table>

---

## 🎯 Core Principles
```
┌─────────────────────────────────────────────────────┐
│  Every script is a capability                       │
│  Every capability is atomic                         │
│  Every module is symmetric                          │
│  Every cloud is treated with equal rigor           │
└─────────────────────────────────────────────────────┘
```

<div align="center">

### Built for Clarity · Atomicity · Symmetry · Reliability

**[⭐ Star this project](.)** if you find it useful!

</div>

---

<div align="center">
<sub>Last updated: December 2025 | Version 1.0.0</sub>
</div>
