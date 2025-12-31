# pstreq-automation — ServiceNow PSTREQ Automation Module

![Status](https://img.shields.io/badge/Module%20Status-Complete-4CAF50?style=for-the-badge)
![Language](https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Shell](https://img.shields.io/badge/Bash-Scripts-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)
![ServiceNow](https://img.shields.io/badge/ServiceNow-Automation-81BC00?style=for-the-badge&logo=servicenow&logoColor=white)

A capability‑centric automation suite for managing **PSTREQ** (Provisioning / Service Technical Request) records in ServiceNow.  
Designed for atomic operations, strict validation, and multi‑language operational reliability across enterprise environments.

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **core** | 🔧 Create, update, comment, attach, close |
| **workflow** | 🔄 State transitions, approvals, assignment, reassignment |
| **validation** | 🛡️ Schema checks, state audits, API health |

---

## 🚀 Capabilities

### 🔧 Core Capabilities (`core/`)

- [`pstreq-create.py`](core/pstreq-create.py) — Create a new PSTREQ  
- [`pstreq-update.py`](core/pstreq-update.py) — Update any PSTREQ fields  
- [`pstreq-comment.py`](core/pstreq-comment.py) — Add comments to PSTREQ  
- [`pstreq-attach-file.py`](core/pstreq-attach-file.py) — Upload attachments  
- [`pstreq-close.py`](core/pstreq-close.py) — Close PSTREQ with notes  

---

### 🔄 Workflow Capabilities (`workflow/`)

- [`pstreq-next-state.py`](workflow/pstreq-next-state.py) — Move PSTREQ to next workflow state  
- [`pstreq-approval.py`](workflow/pstreq-approval.py) — Approve or reject PSTREQ  
- [`pstreq-assign.py`](workflow/pstreq-assign.py) — Assign PSTREQ to user or group  
- [`pstreq-reassign.py`](workflow/pstreq-reassign.py) — Reassign PSTREQ cleanly  

---

### 🛡️ Validation Capabilities (`validation/`)

- [`pstreq-schema-check.py`](validation/pstreq-schema-check.py) — Validate PSTREQ schema  
- [`pstreq-state-audit.py`](validation/pstreq-state-audit.py) — Audit workflow state  
- [`pstreq-api-health.sh`](validation/pstreq-api-health.sh) — API health check  

---

## 🔐 Environment Variables

All scripts rely on strict, minimal environment variables:

- `SN_INSTANCE` — ServiceNow instance  
- `SN_USER` — API username  
- `SN_PASS` — API password  
- Script‑specific variables (e.g., `PSTREQ_SYS_ID`, `PSTREQ_SHORT_DESCRIPTION`, etc.)

---

## 🧩 Design Principles

- **Atomic capabilities** — one script = one operation  
- **Strict validation** — fail fast, no ambiguity  
- **No noise** — clean output, no logs  
- **Symmetric foldering** — core / workflow / validation  
- **Recruiter‑grade clarity** — readable, auditable, professional  
- **Copy‑paste reliability** — no dependencies beyond Python/Bash + requests  

---

## ▶️ Usage

Each script is designed to run as:

```
export VAR=value
python3 script.py
```

or for Bash:

```
export VAR=value
./script.sh
```

All outputs are JSON‑clean and automation‑friendly.
