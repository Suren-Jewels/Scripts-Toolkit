# servicenow-automation — ServiceNow Integration & Workflow Engine

![Status](https://img.shields.io/badge/Module%20Status-In_Progress-FFC107?style=for-the-badge)
![Languages](https://img.shields.io/badge/Mixed%20Languages-Python%20%7C%20Bash-673AB7?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-ServiceNow%20Automation-2196F3?style=for-the-badge)
![Compliance](https://img.shields.io/badge/Enterprise-Ready-009688?style=for-the-badge)

A capability‑centric automation suite for **ServiceNow ticketing, CMDB updates, workflow execution, incident/change management, and API‑driven integrations**.  
Designed for **atomic**, **multi‑language**, **enterprise‑grade** ServiceNow operations with strict validation and reproducible workflows.

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **core** | 🔧 Direct ServiceNow operations (tickets, CMDB, changes, incidents) |
| **workflow** | 🔄 Orchestration, notifications, archiving, diffing |
| **validation** | 🛡️ Schema, payload, and policy compliance |

---

## 🔧 Core Capabilities (`core/`)

- `sn-create-incident.py` — Create ServiceNow incidents via REST API  
- `sn-update-incident.py` — Update incident fields, states, assignments  
- `sn-close-incident.py` — Close incidents with resolution codes  
- `sn-create-change.py` — Create standard/normal/emergency change requests  
- `sn-update-change.py` — Update change states, approvals, tasks  
- `sn-cmdb-query.py` — Query CMDB CI records  
- `sn-cmdb-update.py` — Update CI attributes with strict schema validation  
- `sn-ticket-lookup.py` — Resolve ticket numbers, sys_ids, and relationships  

---

## 🔄 Workflow Capabilities (`workflow/`)

- `sn-run.sh` — Execute a full ServiceNow workflow (incident/change/CMDB)  
- `sn-notify.py` — Slack/Teams notifications for ticket lifecycle events  
- `sn-archive.sh` — Archive ServiceNow workflow snapshots  
- `sn-diff.py` — Compare two ServiceNow ticket states or CMDB snapshots  

---

## 🛡️ Validation Capabilities (`validation/`)

- `validate-sn-schema.py` — Validate payloads against ServiceNow table schemas  
- `validate-sn-policy.py` — Validate assignment groups, states, categories, SLAs  

---

## 🔐 Environment Variables

Common variables used across scripts:

- `SN_INSTANCE` — ServiceNow instance URL  
- `SN_USER` — API username  
- `SN_PASS` — API password or token  
- `SN_TABLE` — Target table (incident, change_request, cmdb_ci, etc.)  
- `BASE_DIR` — Directory for workflow runs  
- `ARCHIVE_DIR` — Directory for archived snapshots  
- `RETENTION` — Number of archives to retain  
- `SLACK_WEBHOOK` / `TEAMS_WEBHOOK` — Notification endpoints  

Each script documents its own required variables.

---

## 🧩 Design Principles

- **Atomic capabilities** — one script = one ServiceNow operation  
- **Strict validation** — schema, payload, and policy enforcement  
- **Multi‑language symmetry** — Python + Bash  
- **Capability‑centric foldering** — core / workflow / validation  
- **Deterministic outputs** — auditable, reproducible, API‑safe  
- **Enterprise alignment** — CMDB integrity, ITIL compliance  
- **Copy‑paste reliability** — no external dependencies beyond Python + curl  

---

## ▶️ Usage

Each script is designed to run as:

```
export SN_INSTANCE="https://example.service-now.com"
export SN_USER="api_user"
export SN_PASS="api_token"
python3 sn-create-incident.py
```

Workflow scripts automatically create timestamped run directories:

```
./sn-run.sh
```

---

## 📦 Outputs

Each workflow run produces:

```
runs/<timestamp>/
  request.json
  response.json
  diff.json
  metadata.json
```

All outputs are deterministic and auditable.

---
