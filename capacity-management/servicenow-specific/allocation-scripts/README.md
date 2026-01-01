# allocation-scripts — Multi‑DC Capacity & Allocation Engine

![Status](https://img.shields.io/badge/Module%20Status-Complete-4CAF50?style=for-the-badge)
![Languages](https://img.shields.io/badge/Mixed%20Languages-Bash%20%7C%20Python-673AB7?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Capacity%20%26%20Allocation%20Automation-2196F3?style=for-the-badge)
![Compliance](https://img.shields.io/badge/Enterprise-Ready-009688?style=for-the-badge)

A capability‑centric automation suite for **multi‑DC capacity discovery, shared/private pool allocation, domain extraction, workflow orchestration, and compliance validation**.  
Designed for **atomic**, **multi‑language**, **enterprise‑grade** allocation operations across shared pools, private customer pools, and POD/Pair‑POD balancing.

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **core** | 🔧 Capacity discovery, shared/private allocation, domain extraction |
| **workflow** | 🔄 Allocation orchestration, notifications, archiving, diffing |
| **validation** | 🛡️ Health and policy compliance |

---

## 🔧 Core Capabilities (`core/`)

- [`discover-capacity.py`](core/discover-capacity.py) — Normalize shared/private/DC/domain/POD inputs  
- [`allocate-shared.py`](core/allocate-shared.py) — Shared‑pool allocation with POD/Pair‑POD balancing  
- [`allocate-private.py`](core/allocate-private.py) — Per‑customer private‑pool allocation with isolation  
- [`allocate-domain-db.py`](core/allocate-domain-db.py) — Extract DB allocations  
- [`allocate-domain-scv.py`](core/allocate-domain-scv.py) — Extract SCV allocations  
- [`allocate-domain-app.py`](core/allocate-domain-app.py) — Extract APP allocations  
- [`allocate-domain-pod.py`](core/allocate-domain-pod.py) — Extract POD allocations (primary DC)  
- [`allocate-domain-pairpod.py`](core/allocate-domain-pairpod.py) — Extract Pair‑POD allocations (secondary DC)  

---

## 🔄 Workflow Capabilities (`workflow/`)

- [`allocation-run.sh`](workflow/allocation-run.sh) — Full allocation workflow with timestamped runs  
- [`allocation-notify.py`](workflow/allocation-notify.py) — Slack/Teams notifications  
- [`allocation-archive.sh`](workflow/allocation-archive.sh) — Archive allocation snapshots  
- [`allocation-diff.py`](workflow/allocation-diff.py) — Compare two allocation states  

---

## 🛡️ Validation Capabilities (`validation/`)

- [`validate-allocation-health.py`](validation/validate-allocation-health.py) — Capacity limits, domain minimums, POD/Pair‑POD balancing  
- [`validate-allocation-policy.py`](validation/validate-allocation-policy.py) — Allocation policy, ratios, placement rules, customer limits  

---

## 🔐 Environment Variables

Common variables used across scripts:

- `CAPACITY_FILE` — Input capacity definition (shared/private/DC/domain/POD)  
- `DISCOVERED_CAPACITY` — Normalized capacity file for allocation steps  
- `SHARED_ALLOC` — Shared allocation output  
- `PRIVATE_ALLOC` — Private allocation output  
- `ALLOCATION_FILE` — Final allocation.json for validation/notification  
- `BASE_DIR` — Directory for allocation runs  
- `ARCHIVE_DIR` — Directory for archived snapshots  
- `RETENTION` — Number of archives to retain  
- `SLACK_WEBHOOK` / `TEAMS_WEBHOOK` — Notification endpoints  

Each script documents its own required variables.

---

## 🧩 Design Principles

- **Atomic capabilities** — one script = one operation  
- **Strict validation** — fail fast, no ambiguity  
- **Multi‑language symmetry** — Bash + Python  
- **Capability‑centric foldering** — core / workflow / validation  
- **Deterministic outputs** — auditable, reproducible, multi‑DC safe  
- **Recruiter‑grade clarity** — clean, minimal, enterprise‑ready  
- **Copy‑paste reliability** — no external dependencies beyond Python + Bash  

---

## ▶️ Usage

Each script is designed to run as:

```
export CAPACITY_FILE=capacity.json
python3 discover-capacity.py
```

or:

```
export DISCOVERED_CAPACITY=runs/<ts>/discovered.json
python3 allocate-shared.py
```

Workflow scripts automatically create timestamped run directories:

```
./allocation-run.sh
```

---
