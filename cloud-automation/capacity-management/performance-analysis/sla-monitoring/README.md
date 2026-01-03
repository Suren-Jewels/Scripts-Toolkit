# sla-monitoring — Multi‑Cloud SLA Analytics & Threshold Evaluation

![Status](https://img.shields.io/badge/Module%20Status-Complete-4CAF50?style=for-the-badge)
![Languages](https://img.shields.io/badge/Mixed%20Languages-Bash%20%7C%20PowerShell%20%7C%20Python-673AB7?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-SLA%20Monitoring%20%26%20Threshold%20Evaluation-2196F3?style=for-the-badge)
![Compliance](https://img.shields.io/badge/Enterprise-Ready-009688?style=for-the-badge)

A capability‑centric SLA monitoring suite for **latency**, **uptime**, and **error rate** across **GCP, Azure, and AWS**.  
Designed for **atomic**, **multi‑cloud**, **threshold‑driven** SLA rollups with JSON‑first outputs for dashboards, CI/CD pipelines, and alerting engines.

---

## 🧭 Architecture Overview

![SLA Monitoring Architecture](https://github.com/Suren-Jewels/Scripts-Toolkit/blob/main/capacity-management/performance-analysis/sla-monitoring/SLA_Monitoring_Architecture.png)

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **api-latency/** | 📡 Latency collectors + analyzer for GCP, Azure, AWS |
| **uptime-monitoring/** | 🟢 Uptime checks + rollup for all clouds |
| **error-rate/** | 🔴 Error rate collectors + analyzer |
| **org-wide-sla-rollup/** | 🌐 SLA rollup, scoring, threshold evaluation, dashboard, CI/CD |
| **sample-endpoints/** | 📂 Sample CSV endpoint definitions for all clouds |

---

## 📡 Latency Capabilities (`api-latency/`)

- `gcp-api-latency.sh` — GCP endpoint latency collector  
- `azure-api-latency.ps1` — Azure endpoint latency collector  
- `aws-api-latency.sh` — AWS endpoint latency collector  
- `latency-analyzer.py` — Aggregates latency JSONs into unified analysis  

---

## 🟢 Uptime Capabilities (`uptime-monitoring/`)

- `gcp-uptime-check.sh` — GCP endpoint availability check  
- `azure-availability.ps1` — Azure endpoint availability check  
- `aws-health-check.sh` — AWS endpoint health check  
- `uptime-rollup.py` — Aggregates uptime JSONs into unified analysis  

---

## 🔴 Error Rate Capabilities (`error-rate/`)

- `gcp-error-rate.sh` — GCP error rate collector  
- `azure-error-rate.ps1` — Azure error rate collector  
- `aws-error-rate.sh` — AWS error rate collector  
- `error-rate-analyzer.py` — Aggregates error JSONs into unified analysis  

---

## 🌐 Org‑Wide SLA Rollup (`org-wide-sla-rollup/`)

- `multi-cloud-sla-rollup.sh` — Aggregates latency, uptime, error into SLA rollup  
- `sla-efficiency-score.py` — Weighted SLA efficiency scoring  
- `sla-alert-thresholds.sh` — Threshold validation + alert JSON  
- `threshold-evaluator.py` — Evaluates SLA metrics against thresholds  
- `thresholds.json` — Threshold definitions for SLA metrics  

### 📊 Dashboard

- `sla-dashboard-generator.py` — Generates dashboard JSON  
- `sla-dashboard.html` — Visual HTML dashboard  

### ⚙️ CI/CD Workflows

- `sla-monitoring-workflow.yml` — GitHub Actions pipeline  
- `sla-monitoring.gitlab-ci.yml` — GitLab CI pipeline  

### 📂 History & Anomalies

- `history/` — Daily SLA snapshots  
- `history-anomalies/` — Outlier detection and anomaly logs  
- `ascii-visualization.txt` — CLI‑friendly SLA trend chart template  

---

## 🔐 Environment Variables

Common variables used across scripts:

- `LATENCY_FILES`, `ERROR_FILES`, `UPTIME_FILES` — Comma‑separated input JSONs  
- `LATENCY_ANALYSIS_FILE`, `ERROR_ANALYSIS_FILE`, `UPTIME_ANALYSIS_FILE` — Analyzer outputs  
- `SLA_ROLLUP_FILE` — Rollup input for scoring/evaluation  
- `THRESHOLDS_FILE` — Threshold definitions for alerting  
- `OUTPUT_FILE` — Destination for JSON output  

Each script documents its own required variables.

---

## 🧩 Design Principles

- **Atomic capabilities** — one script = one SLA dimension  
- **Strict validation** — CLI/tool presence, safe execution, fail‑fast  
- **Multi‑cloud symmetry** — GCP / Azure / AWS parity  
- **JSON‑first outputs** — dashboard‑ready, pipeline‑ready  
- **Deterministic + reproducible** — stable for CI/CD + scheduled jobs  
- **Recruiter‑grade clarity** — clean, minimal, enterprise‑ready  
- **Copy‑paste reliability** — no hidden dependencies  

---

## ▶️ Usage

Each script runs independently and emits JSON suitable for dashboards, automation pipelines, and alerting engines.

Examples:

```bash
bash api-latency/gcp-api-latency.sh
python3 api-latency/latency-analyzer.py
bash org-wide-sla-rollup/multi-cloud-sla-rollup.sh
python3 org-wide-sla-rollup/sla-efficiency-score.py
bash org-wide-sla-rollup/sla-alert-thresholds.sh
