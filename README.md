# 🧰 Scripts Toolkit  
**Automation • SRE Utilities • Diagnostics • Networking • Identity • Cloud**

## 📌 Overview

The **Scripts Toolkit** is a curated, production-ready collection of automation utilities and troubleshooting frameworks used across Cloud, SRE, Security, and Infrastructure environments.

This toolkit reflects real-world engineering patterns designed to improve reliability, accelerate diagnostics, and standardize operational workflows across Linux, Windows, and hybrid systems.

The structure below represents a **clean, senior-level SRE layout**, organized by engineering function rather than programming language.

---

## 📂 Repository Structure
```
Scripts-Toolkit/
│
├── 🤖 automation/           # Deployment & task automation
│   ├── 🐚 deploy_app.sh
│   ├── 💠 cleanup_temp.ps1
│   ├── 🐍 restart_services.py
│   └── 🐚 schedule_tasks.sh
│
├── 🔍 diagnostics/          # Health checks & troubleshooting
│   ├── 🐍 system_health_check.py
│   ├── 💠 get_system_info.ps1
│   ├── 🐍 log_parser.py
│   └── 🐚 service_status.sh
│
├── 🌐 networking/           # Network diagnostics & testing
│   ├── 🐚 network_diag.sh
│   ├── 💠 test_connectivity.ps1
│   ├── 🐍 dns_lookup.py
│   └── 🐚 trace_route.sh
│
├── 🔐 identity/             # Authentication & access management
│   ├── 💠 yubikey_status.ps1
│   ├── 🐍 mfa_test.py
│   └── 🐚 session_audit.sh
│
├── ☁️ cloud/                # Cloud platform monitoring
│   ├── 🐍 aws_resource_check.py
│   ├── 💠 azure_vm_status.ps1
│   └── 🐚 gcp_health_check.sh
│
├── 📋 templates/            # Configuration templates
│   ├── 📄 config.json
│   ├── 📄 workflow.yaml
│   └── 📄 log_format.txt
│
└── 🛠️ utils/                # Shared utilities & helpers
    ├── 🐍 common_functions.py
    ├── 💠 helpers.ps1
    └── 🐚 env_setup.sh
```

### **Legend:**
- 🐍 **Python** - Cross-platform automation & data processing
- 💠 **PowerShell** - Windows automation & enterprise tooling
- 🐚 **Bash** - Linux/Unix system administration
- 📄 **Config Files** - Templates & specifications

---

## 📊 Script Inventory by Language

<table>
<thead>
<tr>
<th>Category</th>
<th>🐍 Python</th>
<th>💠 PowerShell</th>
<th>🐚 Bash</th>
<th>📄 Config</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>🤖 Automation</strong></td>
<td><code>restart_services.py</code></td>
<td><code>cleanup_temp.ps1</code></td>
<td><code>deploy_app.sh</code><br><code>schedule_tasks.sh</code></td>
<td>-</td>
</tr>
<tr>
<td><strong>🔍 Diagnostics</strong></td>
<td><code>system_health_check.py</code><br><code>log_parser.py</code></td>
<td><code>get_system_info.ps1</code></td>
<td><code>service_status.sh</code></td>
<td>-</td>
</tr>
<tr>
<td><strong>🌐 Networking</strong></td>
<td><code>dns_lookup.py</code></td>
<td><code>test_connectivity.ps1</code></td>
<td><code>network_diag.sh</code><br><code>trace_route.sh</code></td>
<td>-</td>
</tr>
<tr>
<td><strong>🔐 Identity</strong></td>
<td><code>mfa_test.py</code></td>
<td><code>yubikey_status.ps1</code></td>
<td><code>session_audit.sh</code></td>
<td>-</td>
</tr>
<tr>
<td><strong>☁️ Cloud</strong></td>
<td><code>aws_resource_check.py</code></td>
<td><code>azure_vm_status.ps1</code></td>
<td><code>gcp_health_check.sh</code></td>
<td>-</td>
</tr>
<tr>
<td><strong>📋 Templates</strong></td>
<td>-</td>
<td>-</td>
<td>-</td>
<td><code>config.json</code><br><code>workflow.yaml</code><br><code>log_format.txt</code></td>
</tr>
<tr>
<td><strong>🛠️ Utils</strong></td>
<td><code>common_functions.py</code></td>
<td><code>helpers.ps1</code></td>
<td><code>env_setup.sh</code></td>
<td>-</td>
</tr>
</tbody>
</table>

---

## 📈 Language Distribution

| Language | Count | Use Cases |
|----------|-------|-----------|
| 🐍 **Python** | 7 scripts | API automation, data processing, cross-platform utilities |
| 💠 **PowerShell** | 6 scripts | Windows administration, identity workflows, enterprise tools |
| 🐚 **Bash** | 9 scripts | Linux automation, system checks, network diagnostics |
| 📄 **Config** | 3 files | Templates, specifications, workflow definitions |

---

## 🎯 Purpose & Scope

- Automate repetitive operational tasks
- Standardize troubleshooting workflows
- Provide reusable building blocks for Cloud/SRE teams
- Support Linux, Windows, and hybrid environments
- Accelerate diagnostics and reduce MTTR
- Serve as a personal engineering toolkit for rapid problem-solving

---

## 🛠️ Technologies & Languages

- **Python** — Automation, parsing, API calls, data processing
- **PowerShell** — Windows automation, identity workflows, diagnostics
- **Bash** — Linux automation, service checks, network tools
- **YAML/JSON** — Configuration templates
- **CLI Tools** — Networking, system monitoring, package management

---

## ⚙️ Example Use Cases

- ✅ Collect system logs across Linux/Windows fleets
- ✅ Automate API calls for cloud or internal services
- ✅ Run health checks before deployments
- ✅ Parse and normalize logs for troubleshooting
- ✅ Automate identity or access workflows
- ✅ Perform network diagnostics and connectivity tests
- ✅ Clean up stale files, processes, or temp data

---

## 🚀 Engineering Impact

- Reduced manual troubleshooting time
- Improved consistency across operational workflows
- Enabled faster incident response
- Provided reusable automation for Cloud/SRE teams
- Strengthened reliability through proactive checks and scripts

---

## 🔒 Confidentiality Notice

All scripts are sanitized and generic.

No internal company code, proprietary logic, or sensitive operational details are included.

---

## 📫 Contact

**Suren Jewels**  
Senior Cloud Engineer | Infrastructure & Security Specialist

*For inquiries about this project or collaboration opportunities, please reach out via LinkedIn.*
