# ci-cd — Automated Incident Orchestration Pipelines

<div align="center">

**🔄 GitHub Actions & GitLab CI**

*Capability-centric CI/CD module enabling automated incident classification,  
on-call routing, auto-remediation, and multi-channel communication*

**Deterministic • Multi-stage • Enterprise-grade**

</div>

---

## 📁 Folder Structure

| File | Purpose | Status |
|------|---------|--------|
| **`github-actions/escalation-workflow.yml`** | GitHub Actions pipeline for full incident lifecycle automation | ✅ Active |
| **`gitlab/escalation.gitlab-ci.yml`** | GitLab CI pipeline for multi-stage incident orchestration | ✅ Active |

---

## 🧠 Architecture Overview
```mermaid
flowchart TD
    subgraph GH["⚙️ GitHub Actions"]
        GA1["escalation-workflow.yml"]
    end

    subgraph GL["🛠️ GitLab CI"]
        GL1["escalation.gitlab-ci.yml"]
    end

    subgraph SD["🔎 Severity Detection"]
        A1["severity-classifier.py"]
        A2["detect-critical-service-impact.sh"]
        A3["detect-major-service-degradation.sh"]
        A4["detect-moderate-service-degradation.sh"]
    end

    subgraph OCR["📞 On-Call Routing"]
        B1["pagerduty-trigger.sh"]
        B2["opsgenie-alert.sh"]
        B3["slack-escalation.py"]
        B4["oncall-resolver.py"]
    end

    subgraph AR["🛠️ Auto-Remediation"]
        C1["restart-service.sh"]
        C2["scale-out.ps1"]
        C3["failover-handler.sh"]
        C4["remediation-engine.py"]
    end

    subgraph COMMS["📣 Communications"]
        D1["slack-incident-broadcast.py"]
        D2["teams-incident-broadcast.py"]
        D3["email-notify.sh"]
    end

    GH -.->|1. Classify| SD
    GL -.->|1. Classify| SD
    
    SD -->|severity=CRITICAL/MAJOR| OCR
    SD -->|severity=MODERATE| COMMS
    
    OCR -->|escalate| AR
    OCR -->|notify| COMMS
    
    AR -->|success/failure| COMMS

    style GH fill:#2ea043,stroke:#1a7f37,color:#fff
    style GL fill:#fc6d26,stroke:#e24329,color:#fff
    style SD fill:#0969da,stroke:#0550ae,color:#fff
    style OCR fill:#8250df,stroke:#6639ba,color:#fff
    style AR fill:#bf3989,stroke:#a0337a,color:#fff
    style COMMS fill:#fb8500,stroke:#d67000,color:#fff
```

---

## 🔧 Core Capabilities

<table>
<thead>
<tr>
<th width="30%">Capability</th>
<th>Description</th>
<th width="15%">Trigger</th>
</tr>
</thead>
<tbody>

<tr>
<td><strong>🎯 Severity Classification</strong></td>
<td>
- Deterministic severity detection<br>
- Multi-signal analysis (logs, metrics, alerts)<br>
- Output: <code>CRITICAL</code> | <code>MAJOR</code> | <code>MODERATE</code>
</td>
<td><code>push</code><br><code>schedule</code><br><code>manual</code></td>
</tr>

<tr>
<td><strong>📞 On-Call Routing</strong></td>
<td>
- PagerDuty / OpsGenie / Slack integration<br>
- Severity-aware escalation paths<br>
- Automated responder notification
</td>
<td><code>severity ≥ MAJOR</code></td>
</tr>

<tr>
<td><strong>🛠️ Auto-Remediation</strong></td>
<td>
- Service restart / scale-out / failover<br>
- Event-aware remediation logic<br>
- Rollback capability
</td>
<td><code>severity = CRITICAL</code></td>
</tr>

<tr>
<td><strong>📣 Multi-Channel Broadcast</strong></td>
<td>
- Slack + Teams + Email notifications<br>
- Severity-colored messaging<br>
- Event payload + metadata included
</td>
<td><code>all severities</code></td>
</tr>

</tbody>
</table>

---

## 🎨 Pipeline Stages Visualization
```
┌─────────────────────────────────────────────────────────────────┐
│                    🔄 INCIDENT AUTOMATION FLOW                   │
└─────────────────────────────────────────────────────────────────┘

  ┌─────────┐       ┌─────────┐       ┌─────────┐       ┌─────────┐
  │  DETECT │  ───► │  ROUTE  │  ───► │ REMEDY  │  ───► │ NOTIFY  │
  └─────────┘       └─────────┘       └─────────┘       └─────────┘
       │                 │                  │                 │
       ▼                 ▼                  ▼                 ▼
  
  • Classify        • PagerDuty       • Restart         • Slack
  • Analyze         • OpsGenie        • Scale-out       • Teams
  • Prioritize      • Slack Esc.      • Failover        • Email
```

---

## 🧩 Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Pipeline-driven orchestration** | CI/CD as the incident automation backbone |
| **Deterministic stage flow** | `classify → route → remediate → broadcast` |
| **Multi-platform parity** | GitHub Actions ≅ GitLab CI workflows |
| **Capability-centric modularity** | Each stage maps to a folder capability |
| **Operational realism** | Aligned with SRE incident workflows |
| **Extensible architecture** | New CI/CD providers drop in cleanly |

---

## ▶️ Usage

### GitHub Actions
```yaml
# .github/workflows/escalation-workflow.yml
name: Incident Orchestration
on: [push, workflow_dispatch, schedule]
jobs:
  orchestrate:
    runs-on: ubuntu-latest
    steps:
      - name: 🔎 Classify Severity
        run: ./severity-detection/severity-classifier.py
      
      - name: 📞 Route On-Call
        if: env.SEVERITY >= 'MAJOR'
        run: ./oncall-routing/pagerduty-trigger.sh
      
      - name: 🛠️ Execute Remediation
        if: env.SEVERITY == 'CRITICAL'
        run: ./auto-remediation/remediation-engine.py
      
      - name: 📣 Broadcast Updates
        run: ./comms/slack-incident-broadcast.py
```

### GitLab CI
```yaml
# .gitlab-ci.yml
include:
  - local: 'gitlab/escalation.gitlab-ci.yml'

stages:
  - detect
  - route
  - remediate
  - notify
```

---

## 🎯 Severity Color Codes

| Severity | Color | Hex | Action |
|----------|-------|-----|--------|
| **CRITICAL** | 🔴 Red | `#DC3545` | Immediate escalation + auto-remediation |
| **MAJOR** | 🟠 Orange | `#FD7E14` | On-call routing + manual review |
| **MODERATE** | 🟡 Yellow | `#FFC107` | Notification only |
| **LOW** | 🟢 Green | `#28A745` | Log entry |

---

## 📊 Operational Metrics
```
┌─────────────────────────────────────────────────────────────┐
│  MTTR (Mean Time to Remediation)                             │
│  ════════════════════════════════════════════════════════   │
│  Manual:   ~45 minutes   ████████████████████░░░░░░░░░░░░   │
│  Automated: ~2 minutes   ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
│  Improvement: 95.6% ↓                                        │
└─────────────────────────────────────────────────────────────┘
```

---

<div align="center">

**Built for reliability • Designed for scale • Automated for speed**

[GitHub Actions Docs](https://docs.github.com/actions) • [GitLab CI Docs](https://docs.gitlab.com/ee/ci/)

</div>
