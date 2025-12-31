# pod-walk-automation — Kubernetes Pod Walk, Inspection & Health Automation

![Status](https://img.shields.io/badge/Module%20Status-Complete-4CAF50?style=for-the-badge)
![Languages](https://img.shields.io/badge/Mixed%20Languages-Bash%20%7C%20Python-673AB7?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Kubernetes%20Inspection%20Automation-2196F3?style=for-the-badge)
![Compliance](https://img.shields.io/badge/Enterprise-Ready-009688?style=for-the-badge)

A capability‑centric automation suite for **Kubernetes pod walks**, including inspection, logging, events, resource usage, workflow orchestration, and validation.  
Designed for **atomic**, **multi‑language**, **enterprise‑grade** operations.

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **core** | 🔧 Pod walks, logs, events, restarts, resource reports |
| **workflow** | 🔄 Scheduling, notifications, archiving, diffing |
| **validation** | 🛡️ Label compliance, health integrity |

---

## 🔧 Core Capabilities (`core/`)

- [`pod-walk-basic.sh`](core/pod-walk-basic.sh) — Basic pod walk summary  
- [`pod-walk-detailed.py`](core/pod-walk-detailed.py) — Deep pod inspection  
- [`pod-logs-collect.sh`](core/pod-logs-collect.sh) — Collect logs for all pods  
- [`pod-events-collect.sh`](core/pod-events-collect.sh) — Collect events for all pods  
- [`pod-restart-report.py`](core/pod-restart-report.py) — Restart count and crash analysis  
- [`pod-resource-report.py`](core/pod-resource-report.py) — CPU/memory usage + requests/limits  

---

## 🔄 Workflow Capabilities (`workflow/`)

- [`pod-walk-schedule.sh`](workflow/pod-walk-schedule.sh) — Scheduled pod walk runner  
- [`pod-walk-notify.py`](workflow/pod-walk-notify.py) — Slack/Teams notifications  
- [`pod-walk-archive.sh`](workflow/pod-walk-archive.sh) — Archive pod walk runs  
- [`pod-walk-diff.py`](workflow/pod-walk-diff.py) — Compare two pod walk snapshots  

---

## 🛡️ Validation Capabilities (`validation/`)

- [`validate-pod-labels.py`](validation/validate-pod-labels.py) — Required label compliance  
- [`validate-pod-health.py`](validation/validate-pod-health.py) — Readiness, liveness, crash state validation  

---

## 🔐 Environment Variables

Common variables used across scripts:

- `KUBECONFIG` — Required for all Kubernetes interactions  
- `OUTPUT_DIR` — Override output directory for logs/events  
- `RUN_DIR` — Directory for workflow notifications  
- `SLACK_WEBHOOK` / `TEAMS_WEBHOOK` — Notification endpoints  
- `REQUIRED_LABELS` — Comma‑separated list of required labels  

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

