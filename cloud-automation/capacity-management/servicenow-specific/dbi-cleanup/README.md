# dbi-cleanup — Database Integrity Cleanup & Lifecycle Automation

![Status](https://img.shields.io/badge/Module%20Status-Complete-4CAF50?style=for-the-badge)
![Languages](https://img.shields.io/badge/Mixed%20Languages-Python%20%7C%20Bash%20%7C%20SQL%20%7C%20PowerShell%20%7C%20Puppet-673AB7?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Database%20Integrity%20Automation-2196F3?style=for-the-badge)
![Compliance](https://img.shields.io/badge/Enterprise-Ready-009688?style=for-the-badge)

A comprehensive automation suite for **Database Integrity (DBI)** discovery, validation, cleanup, retirement, and lifecycle workflows.  
Designed for **multi‑language**, **atomic**, **capability‑centric** operations across enterprise environments.

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **core** | 🔧 Cleanup, retirement, CI refresh, reporting |
| **workflow** | 🔄 Workflow monitoring, debugging, discovery gates |
| **validation** | 🛡️ SQL integrity checks, capacity validation, dependency validation |

---

## 🔧 Core Capabilities (`core/`)

- [`find-orphan-dbi.py`](core/find-orphan-dbi.py) — Detect orphaned DBI records  
- [`find-stale-dbi.sh`](core/find-stale-dbi.sh) — Identify stale DBI entries  
- [`find-pending-retire-dbi.sh`](core/find-pending-retire-dbi.sh) — Locate DBIs pending retirement  
- [`bulk-retire-dbi.sh`](core/bulk-retire-dbi.sh) — Bulk retirement workflow  
- [`retire-dbi.sh`](core/retire-dbi.sh) — Atomic DBI retirement  
- [`refresh-dbi-ci.sh`](core/refresh-dbi-ci.sh) — Refresh CMDB CI for DBI  
- [`export-dbi-cleanup-report.py`](core/export-dbi-cleanup-report.py) — Export cleanup reports  
- [`puppet-retire-dbi.pp`](core/puppet-retire-dbi.pp) — Puppet manifest for DBI retirement  

---

## 🔄 Workflow Capabilities (`workflow/`)

- [`monitor-dbi-workflow.py`](workflow/monitor-dbi-workflow.py) — Monitor DBI lifecycle workflows  
- [`workflow-debug.ps1`](workflow/workflow-debug.ps1) — Debug DBI workflow transitions  
- [`validate-dbi-discovery.sh`](workflow/validate-dbi-discovery.sh) — Validate DBI discovery state (pre‑workflow gate)  

---

## 🛡️ Validation Capabilities (`validation/`)

### SQL Integrity Checks
- [`check-dbi-active-schemas.sql`](validation/check-dbi-active-schemas.sql)  
- [`check-dbi-connections.sql`](validation/check-dbi-connections.sql)  
- [`check-dbi-last-access.sql`](validation/check-dbi-last-access.sql)  
- [`check-dbi-metadata.sql`](validation/check-dbi-metadata.sql)  
- [`check-dbi-orphaned-users.sql`](validation/check-dbi-orphaned-users.sql)  
- [`check-dbi-readonly.sql`](validation/check-dbi-readonly.sql)  
- [`check-dbi-replication.sql`](validation/check-dbi-replication.sql)  
- [`check-dbi-size.sql`](validation/check-dbi-size.sql)  

### Python / PowerShell Validation
- [`validate-dbi-capacity.py`](validation/validate-dbi-capacity.py) — Validate DBI capacity thresholds  
- [`validate-dbi-dependencies.py`](validation/validate-dbi-dependencies.py) — Validate DBI dependency graph  
- [`validate-dbi-windows.ps1`](validation/validate-dbi-windows.ps1) — Windows‑specific DBI validation  

---

## 🔐 Environment Variables

Scripts use minimal, strict environment variables such as:

- `DBI_ID`  
- `DBI_ENV`  
- `DBI_REPORT_PATH`  
- `SN_INSTANCE`, `SN_USER`, `SN_PASS` (for CI refresh workflows)  

Each script documents its own required variables.

---

## 🧩 Design Principles

- **Atomic capabilities** — one script = one operation  
- **Strict validation** — fail fast, no ambiguity  
- **Multi‑language symmetry** — Python, Bash, SQL, PowerShell, Puppet  
- **Capability‑centric foldering** — core / workflow / validation  
- **Recruiter‑grade clarity** — readable, auditable, enterprise‑ready  
- **Copy‑paste reliability** — no external dependencies beyond standard tooling  

---

## ▶️ Usage

Each script is designed to run as:

```
export VAR=value
python3 script.py
```

or:

```
export VAR=value
./script.sh
```

SQL files are executed via your preferred SQL client or automation pipeline.

---

