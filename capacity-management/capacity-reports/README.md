# capacity-reports — Multi‑Cloud Performance & Capacity Analytics

![Status](https://img.shields.io/badge/Module%20Status-Complete-4CAF50?style=for-the-badge)
![Languages](https://img.shields.io/badge/Mixed%20Languages-Bash%20%7C%20PowerShell%20%7C%20Python-673AB7?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Capacity%20%26%20Performance%20Analysis-2196F3?style=for-the-badge)
![Compliance](https://img.shields.io/badge/Enterprise-Ready-009688?style=for-the-badge)

A capability‑centric analytics suite for **compute, storage, and network capacity reporting** across **GCP, Azure, and AWS**.  
Designed for **atomic**, **multi‑cloud**, **enterprise‑grade** performance insights with JSON‑first outputs for dashboards, forecasting engines, and leadership reporting.

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **compute-capacity-report** | 🖥️ Compute utilization, hotspots, idle detection, quota usage |
| **storage-capacity-report** | 📦 Storage consumption, growth, lifecycle optimization |
| **network-capacity-report** | 🌐 Throughput, bandwidth, packet drops, LB saturation |
| **org-wide-capacity-rollup** | 📊 Multi‑cloud aggregation, forecasting, alerting |

---

## 🖥️ Compute Capacity Capabilities (`compute-capacity-report/`)

- [`gcp-compute-capacity-summary.sh`](compute-capacity-report/gcp-compute-capacity-summary.sh) — vCPU/RAM/instance distribution across GCP projects  
- [`gcp-compute-hotspots.sh`](compute-capacity-report/gcp-compute-hotspots.sh) — CPU/RAM/IO hotspot detection  
- [`gcp-compute-idle-resources.sh`](compute-capacity-report/gcp-compute-idle-resources.sh) — Idle/underutilized VM identification  
- [`azure-vm-capacity-summary.ps1`](compute-capacity-report/azure-vm-capacity-summary.ps1) — Azure VM SKU usage + quota saturation  
- [`aws-ec2-capacity-summary.sh`](compute-capacity-report/aws-ec2-capacity-summary.sh) — EC2 fleet utilization + scaling headroom  

---

## 📦 Storage Capacity Capabilities (`storage-capacity-report/`)

- [`gcp-storage-bucket-capacity.sh`](storage-capacity-report/gcp-storage-bucket-capacity.sh) — Bucket size, object count, growth indicators  
- [`gcp-filestore-capacity.sh`](storage-capacity-report/gcp-filestore-capacity.sh) — Filestore capacity + throughput saturation  
- [`azure-storage-account-capacity.ps1`](storage-capacity-report/azure-storage-account-capacity.ps1) — Container + file share capacity metrics  
- [`aws-s3-capacity-summary.sh`](storage-capacity-report/aws-s3-capacity-summary.sh) — S3 size + storage class distribution  

---

## 🌐 Network Capacity Capabilities (`network-capacity-report/`)

- [`gcp-network-throughput-summary.sh`](network-capacity-report/gcp-network-throughput-summary.sh) — VPC flow log throughput + packet drops  
- [`gcp-loadbalancer-capacity.sh`](network-capacity-report/gcp-loadbalancer-capacity.sh) — LB backend utilization + request volume  
- [`azure-network-capacity.ps1`](network-capacity-report/azure-network-capacity.ps1) — VNet bandwidth + gateway usage  
- [`aws-vpc-capacity-summary.sh`](network-capacity-report/aws-vpc-capacity-summary.sh) — ENI usage, subnet saturation, VPC traffic  

---

## 📊 Org‑Wide Rollup Capabilities (`org-wide-capacity-rollup/`)

- [`multi-cloud-capacity-rollup.sh`](org-wide-capacity-rollup/multi-cloud-capacity-rollup.sh) — Unified compute/storage/network JSON rollup  
- [`capacity-trend-analysis.py`](org-wide-capacity-rollup/capacity-trend-analysis.py) — Historical trend analysis + forecasting  
- [`capacity-alert-thresholds.sh`](org-wide-capacity-rollup/capacity-alert-thresholds.sh) — Threshold validation + alert JSON  

---

## 🔐 Environment Variables

Common variables used across scripts:

- `WINDOW` — Lookback window for metrics (e.g., 3600s, 86400s)  
- `PROJECTS` / `SUBSCRIPTIONS` / `REGIONS` — Cloud‑specific scope selectors  
- `OUTPUT_DIR` — Optional directory for storing JSON reports  
- `THRESHOLDS_FILE` — Threshold definitions for alerting  
- `ROLLUP_INPUT_DIR` — Directory containing per‑domain JSON reports  

Each script documents its own required variables.

---

## 🧩 Design Principles

- **Atomic capabilities** — one script = one capacity dimension  
- **Strict validation** — CLI/tool presence, safe execution, fail‑fast  
- **Multi‑cloud symmetry** — GCP / Azure / AWS parity  
- **JSON‑first outputs** — dashboard‑ready, pipeline‑ready  
- **Deterministic + reproducible** — stable for CI/CD + scheduled jobs  
- **Recruiter‑grade clarity** — clean, minimal, enterprise‑ready  
- **Copy‑paste reliability** — no hidden dependencies  

---

## ▶️ Usage

Each script runs independently:

