# server-lifecycle — End‑to‑End Server Lifecycle Automation

![Status](https://img.shields.io/badge/Module%20Status-Complete-4CAF50?style=for-the-badge)
![Languages](https://img.shields.io/badge/Mixed%20Languages-Bash%20%7C%20Python-673AB7?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Server%20Lifecycle%20Management-2196F3?style=for-the-badge)
![Compliance](https://img.shields.io/badge/Enterprise-Ready-009688?style=for-the-badge)

A capability‑centric automation suite for **end‑to‑end server lifecycle management**, including discovery, provisioning, configuration, draining, decommissioning, workflow orchestration, and compliance validation.  
Designed for **atomic**, **multi‑language**, **enterprise‑grade** operations.

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **core** | 🔧 Server operations (discover, health, provision, configure, drain, decommission) |
| **workflow** | 🔄 Lifecycle orchestration, notifications, archiving, diffing |
| **validation** | 🛡️ Health and policy compliance |

---

## 🔧 Core Capabilities (`core/`)

- [`server-discover.sh`](core/server-discover.sh) — Discover all managed servers  
- [`server-health.py`](core/server-health.py) — CPU/mem/disk/conditions/taints health report  
- [`server-provision.sh`](core/server-provision.sh) — Register a new server into the managed fleet  
- [`server-configure.sh`](core/server-configure.sh) — Apply baseline configuration  
- [`server-drain.sh`](core/server-drain.sh) — Safely drain workloads  
- [`server-decommission.sh`](core/server-decommission.sh) — Remove server from rotation and clear labels  

---

## 🔄 Workflow Capabilities (`workflow/`)

- [`server-lifecycle-run.sh`](workflow/server-lifecycle-run.sh) — Scheduled lifecycle audit  
- [`server-lifecycle-notify.py`](workflow/server-lifecycle-notify.py) — Slack/Teams notifications  
- [`server-lifecycle-archive.sh`](workflow/server-lifecycle-archive.sh) — Archive lifecycle snapshots  
- [`server-lifecycle-diff.py`](workflow/server-lifecycle-diff.py) — Compare two lifecycle states  

---

## 🛡️ Validation Capabilities (`validation/`)

- [`validate-server-health.py`](validation/validate-server-health.py) — Readiness, pressure, taints, schedulability  
- [`validate-server-policy.py`](validation/validate-server-policy.py) — Label/annotation/taint policy compliance  

---

## 🔐 Environment Variables

Common variables used across scripts:

- `KUBECONFIG` — Required for all Kubernetes interactions  
- `LABEL_KEY` — Managed server label key (default: `server-managed`)  
- `LABEL_VALUE` — Managed server label value (default: `true`)  
- `BASE_DIR` — Directory for lifecycle runs  
- `ARCHIVE_DIR` — Directory for archived snapshots  
- `RETAIN_COUNT` — Number of archives to retain  
- `CONFIG_CMD` — External configuration command (Ansible, SSH, SSM, etc.)  
- `REQUIRED_LABELS` — Comma‑separated list of required labels  
- `REQUIRED_ANNOTATIONS` — Required annotations  
- `REQUIRED_TAINTS` — Required taints  
- `SLACK_WEBHOOK` / `TEAMS_WEBHOOK` — Notification endpoints  

Each script documents its own required variables.

---

## 🧩 Design Principles

- **Atomic capabilities** — one script = one operation  
- **Strict validation** — fail fast, no ambiguity  
- **Multi‑language symmetry** — Bash + Python  
- **Capability‑centric foldering** — core / workflow / validation  
- **Recruiter‑grade clarity** — readable, auditable, enterprise‑ready  
- **Copy‑paste reliability** — no external dependencies beyond kubectl + jq  

---

## ▶️ Usage

Each script is designed to run as:

```
export KUBECONFIG=/path/to/kubeconfig
./script.sh
```

or:

```
export KUBECONFIG=/path/to/kubeconfig
python3 script.py
```

Workflow scripts automatically create timestamped run directories.

---

