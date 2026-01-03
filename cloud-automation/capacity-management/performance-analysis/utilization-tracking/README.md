# utilization-tracking — Multi‑Cloud Utilization & Efficiency Analytics

![Status](https://img.shields.io/badge/Module%20Status-Complete-4CAF50?style=for-the-badge)
![Languages](https://img.shields.io/badge/Mixed%20Languages-Bash%20%7C%20PowerShell%20%7C%20Python-673AB7?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Performance%20%26%20Utilization%20Tracking-2196F3?style=for-the-badge)
![Compliance](https://img.shields.io/badge/Enterprise-Ready-009688?style=for-the-badge)

A capability‑centric analytics suite for **compute, storage, network, and org‑wide utilization tracking** across **GCP, Azure, and AWS**.  
Designed for **atomic**, **multi‑language**, **pipeline‑ready** performance monitoring with **JSON‑first outputs**, **strict validation**, and **multi‑cloud symmetry**.

---

## 📁 Folder Structure

| Folder | Purpose |
|--------|---------|
| **compute-utilization** | CPU/RAM/IO utilization, idle detection, EC2 credits, VM saturation |
| **storage-utilization** | Filestore/EBS/Storage Account throughput, IOPS, latency, growth |
| **network-utilization** | VPC/VNet bandwidth, packet drops, LB saturation, flow analytics |
| **org-wide-utilization-rollup** | Multi‑cloud aggregation, scoring, alert thresholds |

---

## 🖥️ Compute Utilization (`compute-utilization/`)

- **gcp-compute-utilization.sh** — GCP CPU/RAM/IO utilization across all instances  
- **azure-vm-utilization.ps1** — Azure VM performance metrics + saturation scoring  
- **aws-ec2-utilization.sh** — EC2 CPU credits, network IO, burst capacity  
- **compute-idle-detector.py** — Cross‑cloud idle resource detection  

---

## 📦 Storage Utilization (`storage-utilization/`)

- **gcp-filestore-utilization.sh** — Filestore throughput, latency, saturation  
- **azure-storage-utilization.ps1** — Storage account IOPS + bandwidth patterns  
- **aws-ebs-utilization.sh** — EBS IOPS, throughput, burst balance  
- **storage-growth-analyzer.py** — Growth forecasting + anomaly detection  

---

## 🌐 Network Utilization (`network-utilization/`)

- **gcp-network-utilization.sh** — VPC flow throughput + packet drops  
- **azure-network-utilization.ps1** — VNet bandwidth + gateway performance  
- **aws-vpc-utilization.sh** — ENI usage, subnet pressure, VPC traffic  
- **lb-utilization-summary.py** — Cross‑cloud load balancer utilization  

---

## 📊 Org‑Wide Rollup (`org-wide-utilization-rollup/`)

- **multi-cloud-utilization-rollup.sh** — Unified compute/storage/network rollup  
- **utilization-efficiency-score.py** — Weighted efficiency scoring  
- **utilization-alert-thresholds.sh** — Threshold validation + alert JSON  

---

## 🔐 Environment Variables

Common variables used across scripts:

- `WINDOW` — Lookback window for utilization metrics  
- `PROJECTS` / `SUBSCRIPTIONS` / `REGIONS` — Cloud scope selectors  
- `OUTPUT_DIR` — Directory for storing utilization reports  
- `THRESHOLDS_FILE` — Threshold definitions for alerting  
- `ROLLUP_INPUT_DIR` — Directory containing per‑domain JSON reports  

Each script documents its own required variables.

---

## 🧩 Design Principles

- **Atomic capabilities** — one script = one utilization dimension  
- **Strict validation** — CLI/tool presence, safe execution, fail‑fast  
- **Multi‑cloud symmetry** — GCP / Azure / AWS parity  
- **JSON‑first outputs** — dashboard‑ready, pipeline‑ready  
- **Deterministic + reproducible** — stable for CI/CD + scheduled jobs  
- **Recruiter‑grade clarity** — clean, minimal, enterprise‑ready  
- **Copy‑paste reliability** — no hidden dependencies  

---

## ▶️ Usage Examples

Compute:

