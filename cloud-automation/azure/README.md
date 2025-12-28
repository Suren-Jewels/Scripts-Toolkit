# ☁️ Azure Automation Suite

<div align="center">

**Atomic, symmetric, and enterprise-grade automation for Azure infrastructure**

[![Azure](https://img.shields.io/badge/Azure-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

*Single-capability scripts across key Azure domains — engineered for clarity, reliability, and multi-cloud symmetry*

Part of the [**Scripts‑Toolkit**](../../..)

</div>

---

## 📁 Directory Structure
```
azure/
├── 🔧 automation/       # General-purpose automation capabilities
├── 🧑‍💼 entra-id/         # Identity & access management (Azure AD)
├── 🔐 keyvault/         # Secrets, keys, certificates, access policies
├── 📊 monitor/          # Alerts, diagnostics, autoscale, log analytics
├── 🟦 network/          # VNet, NSG, routing, peering, public IPs
├── 💾 storage/          # Blob storage lifecycle and access
└── 🖥️ vm/               # Virtual machine lifecycle and configuration
```

> Each folder contains **atomic scripts** — one capability, one script, zero dependencies.

---

## 🎯 Modules & Capabilities

<table>
<thead>
<tr>
<th width="15%">Module</th>
<th width="45%">Description</th>
<th width="40%">Core Capabilities</th>
</tr>
</thead>
<tbody>

<tr>
<td><strong>🟦 network</strong></td>
<td>Infrastructure automation for secure, scalable connectivity</td>
<td>
- VNet create/delete<br>
- Subnet create/delete<br>
- NSG create + rule mgmt<br>
- Public IP create<br>
- Route table create<br>
- VNet peering create
</td>
</tr>

<tr>
<td><strong>📊 monitor</strong></td>
<td>Operational visibility and alerting automation</td>
<td>
- Diagnostic settings enable<br>
- Metric alert create/delete<br>
- Activity log alert create/delete<br>
- Log Analytics workspace mgmt<br>
- Autoscale setting create/delete
</td>
</tr>

<tr>
<td><strong>🔐 keyvault</strong></td>
<td>Secure secrets, keys, certificates, and access policies</td>
<td>
- Vault create/delete<br>
- Secret set/get/delete<br>
- Key create/delete<br>
- Certificate import/delete<br>
- Access policy set
</td>
</tr>

<tr>
<td><strong>🧑‍💼 entra-id</strong></td>
<td>Identity and access automation (Azure AD)</td>
<td>
<em>🚧 Coming soon:</em><br>
User, group, role, and policy management
</td>
</tr>

<tr>
<td><strong>💾 storage</strong></td>
<td>Blob storage lifecycle and access control</td>
<td>
<em>🚧 Coming soon:</em><br>
Container mgmt, lifecycle rules, access policies
</td>
</tr>

<tr>
<td><strong>🖥️ vm</strong></td>
<td>Virtual machine lifecycle and configuration</td>
<td>
<em>🚧 Coming soon:</em><br>
VM create/delete, extensions, diagnostics
</td>
</tr>

<tr>
<td><strong>⚙️ automation</strong></td>
<td>General-purpose automation and orchestration</td>
<td>
<em>🚧 Coming soon:</em><br>
Runbooks, schedules, hybrid workers
</td>
</tr>

</tbody>
</table>

---

## 🧩 Script Design Standard

Every script follows the **atomic pattern** for maximum reliability:
```bash
#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# Capability: <one-line description>
# ═══════════════════════════════════════════════════════════════

# ┌─────────────────────────────────────────────────────────────┐
# │ Required Variables                                           │
# └─────────────────────────────────────────────────────────────┘
VAR1="${VAR1:?❌ VAR1 is required}"
VAR2="${VAR2:?❌ VAR2 is required}"

# ┌─────────────────────────────────────────────────────────────┐
# │ Core Logic                                                   │
# └─────────────────────────────────────────────────────────────┘
az <service> <action> \
  --param1 "$VAR1" \
  --param2 "$VAR2" \
  --output json

# ┌─────────────────────────────────────────────────────────────┐
# │ Validation & Confirmation                                    │
# └─────────────────────────────────────────────────────────────┘
echo "✅ Operation completed successfully"
```

### 🎨 Design Principles

| Principle | Implementation |
|-----------|----------------|
| **🎯 Atomic** | One script = one capability |
| **🔒 Safe** | `set -euo pipefail` + strict validation |
| **📝 Clear** | Self-documenting with visual separators |
| **🔄 Symmetric** | Consistent patterns across all clouds |
| **⚡ Zero Deps** | Pure Bash + Azure CLI only |

---

## 🚀 Quick Start
```bash
# 1. Clone the toolkit
git clone https://github.com/your-org/scripts-toolkit.git
cd scripts-toolkit/azure

# 2. Set required variables
export RESOURCE_GROUP="myResourceGroup"
export LOCATION="eastus"

# 3. Run any script
./network/vnet-create.sh
```

---

## 📊 Module Maturity

| Module | Status | Scripts | Coverage |
|--------|--------|---------|----------|
| 🟦 network | ✅ **Stable** | 12 | 95% |
| 📊 monitor | ✅ **Stable** | 10 | 90% |
| 🔐 keyvault | ✅ **Stable** | 9 | 85% |
| 🧑‍💼 entra-id | 🚧 **Planning** | 0 | 0% |
| 💾 storage | 🚧 **Planning** | 0 | 0% |
| 🖥️ vm | 🚧 **Planning** | 0 | 0% |
| ⚙️ automation | 🚧 **Planning** | 0 | 0% |

---

## 🤝 Contributing

We welcome contributions! Please ensure:

- ✅ Scripts follow the atomic pattern
- ✅ All variables are validated
- ✅ Error handling is comprehensive
- ✅ Documentation is clear and concise

---

## 📜 License

MIT License - see [LICENSE](LICENSE) for details

---

<div align="center">

**Built with ❤️ for Azure automation**

[Documentation](docs/) • [Examples](examples/) • [Issues](../../issues)

</div>
