# reserve-pool-mgmt — Reserve Compute Pool Automation

![Status](https://img.shields.io/badge/Module%20Status-Complete-4CAF50?style=for-the-badge)
![Languages](https://img.shields.io/badge/Mixed%20Languages-Bash%20%7C%20Python-673AB7?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Reserve%20Pool%20Management-2196F3?style=for-the-badge)
![Compliance](https://img.shields.io/badge/Enterprise-Ready-009688?style=for-the-badge)

A capability‑centric automation suite for **managing reserve compute pools**, including discovery, capacity reporting, node promotion/demotion, draining, lifecycle workflows, and compliance validation.  
Designed for **atomic**, **multi‑language**, **enterprise‑grade** operations.

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **core** | 🔧 Reserve pool operations (discover, promote, demote, drain, return, capacity) |
| **workflow** | 🔄 Scheduling, notifications, archiving, diffing |
| **validation** | 🛡️ Node health and policy compliance |

---

## 🔧 Core Capabilities (`core/`)

- [`discover-reserve-pool.sh`](core/discover-reserve-pool.sh) — Discover reserve pool nodes  
- [`reserve-pool-capacity.py`](core/reserve-pool-capacity.py) — Compute reserve pool capacity  
- [`promote-node-to-reserve.sh`](core/promote-node-to-reserve.sh) — Promote node into reserve pool  
- [`demote-node-from-reserve.sh`](core/demote-node-from-reserve.sh) — Remove node from reserve pool  
- [`drain-reserve-node.sh`](core/drain-reserve-node.sh) — Safely drain a reserve node  
- [`return-reserve-node.sh`](core/return-reserve-node.sh) — Return drained node to active pool  

---

## 🔄 Workflow Capabilities (`workflow/`)

- [`reserve-pool-schedule.sh`](workflow/reserve-pool-schedule.sh) — Scheduled reserve pool audit  
- [`reserve-pool-notify.py`](workflow/reserve-pool-notify.py) — Slack/Teams notifications  
- [`reserve-pool-archive.sh`](workflow/reserve-pool-archive.sh) — Archive reserve pool snapshots  
- [`reserve-pool-diff.py`](workflow/reserve-pool-diff.py) — Compare two reserve pool states  

---

## 🛡️ Validation Capabilities (`validation/`)

- [`validate-reserve-node-health.py`](validation/validate-reserve-node-health.py) — Node readiness, taints, conditions  
- [`validate-reserve-pool-policy.py`](validation/validate-reserve-pool-policy.py) — Label/annotation/taint policy compliance  

---

## 🔐 Environment Variables

Common variables used across scripts:

- `KUBECONFIG` — Required for all Kubernetes interactions  
- `LABEL_KEY` — Reserve pool label key (default: `reserve-pool`)  
- `LABEL_VALUE` — Reserve pool label value (default: `true`)  
- `RUNS_DIR` — Directory for workflow runs  
- `ARCHIVE_DIR` — Directory for archived snapshots  
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

