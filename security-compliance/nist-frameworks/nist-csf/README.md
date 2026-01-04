# 🛡️ NIST Cybersecurity Framework (CSF) Automation Module

![NIST CSF | Cybersecurity](https://img.shields.io/badge/NIST_CSF-Cybersecurity-0A84FF) ![Maturity Level 3](https://img.shields.io/badge/Maturity-Level_3-34C759) ![Automated Assessment](https://img.shields.io/badge/Automated-Assessment-34C759) ![Tier Validation](https://img.shields.io/badge/Tier-Validation-FFD60A)

Comprehensive NIST Cybersecurity Framework implementation toolkit providing automated maturity assessments, core function validation, and implementation tier evaluation across Identify, Protect, Detect, Respond, and Recover functions.

| Resource | Link |
|----------|------|
| NIST CSF v1.1 Framework | https://www.nist.gov/cyberframework |
| CSF Implementation Guide | https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.04162018.pdf |
| CSF Online Learning | https://www.nist.gov/itl/applied-cybersecurity/nice/resources/online-learning-content |
| GitHub Repository | https://github.com/Suren-Jewels/Scripts-Toolkit |

---

## 📊 Current CSF Implementation Status
```
Overall Framework Maturity        [███████████████████░░░░░] 78% (39/50) ✓
Core Functions Coverage           [████████████████████░░░░] 82% (41/50) ✓
────────────────────────────────────────────────────────────────────────────
Identify (ID):
  Asset Management (ID.AM)        [████████████████████████] 95% (19/20) ✓
  Business Environment (ID.BE)    [████████████████████░░░░] 85% (17/20) ✓
  Governance (ID.GV)              [███████████████████░░░░░] 80% (16/20) ✓
  Risk Assessment (ID.RA)         [██████████████████░░░░░░] 75% (15/20) ⚠
  Risk Mgmt Strategy (ID.RM)      [███████████████████░░░░░] 80% (16/20) ✓
────────────────────────────────────────────────────────────────────────────
Protect (PR):
  Identity Mgmt (PR.AC)           [██████████████████████░░] 90% (18/20) ✓
  Awareness & Training (PR.AT)    [███████████████████████░] 92% (18.5/20) ✓
  Data Security (PR.DS)           [█████████████████░░░░░░░] 70% (14/20) ⚠
  Info Protection (PR.IP)         [████████████████████░░░░] 82% (16.5/20) ✓
  Maintenance (PR.MA)             [███████████████████████░] 88% (17.5/20) ✓
  Protective Tech (PR.PT)         [██████████████████░░░░░░] 75% (15/20) ⚠
────────────────────────────────────────────────────────────────────────────
Detect (DE):
  Anomalies & Events (DE.AE)      [███████████████████░░░░░] 78% (15.5/20) ⚠
  Security Monitoring (DE.CM)     [████████████████████████] 95% (19/20) ✓
  Detection Processes (DE.DP)     [██████████████████████░░] 85% (17/20) ✓
────────────────────────────────────────────────────────────────────────────
Respond (RS):
  Response Planning (RS.RP)       [█████████████████░░░░░░░] 72% (14.5/20) ⚠
  Communications (RS.CO)          [████████████████████░░░░] 80% (16/20) ✓
  Analysis (RS.AN)                [███████████████████░░░░░] 78% (15.5/20) ⚠
  Mitigation (RS.MI)              [██████████████████░░░░░░] 75% (15/20) ⚠
  Improvements (RS.IM)            [████████████████████░░░░] 82% (16.5/20) ✓
────────────────────────────────────────────────────────────────────────────
Recover (RC):
  Recovery Planning (RC.RP)       [██████████████████░░░░░░] 74% (14.8/20) ⚠
  Improvements (RC.IM)            [███████████████████░░░░░] 80% (16/20) ✓
  Communications (RC.CO)          [███████████████████░░░░░] 77% (15.5/20) ⚠
────────────────────────────────────────────────────────────────────────────
Monthly Trend:  ▃▄▅▆▇▇█  (Improving)

Implementation Tier Distribution:
  Tier 1: 3  |  Tier 2: 8  |  Tier 3: 15  |  Tier 4: 6  |  Adaptive: 2
```

---

## 🗂️ Module Architecture
```mermaid
graph TD
    Root[[🛡️ NIST CSF Module]]
    
    Root --> Assessment[[📊 Assessment Engine]]
    Root --> Validation[[✅ Core Function Validation]]
    Root --> Audit[[🔍 Response & Recovery Audit]]
    Root --> Config[[⚙️ Configuration]]
    
    Assessment --> File1[csf-maturity-assessment.py]
    
    Validation --> File2[identify-protect-detect.sh]
    
    Audit --> File3[respond-recover-audit.py]
    
    Config --> Config1[csf-implementation-tiers.yaml]
    
    File1 -.references.-> Config1
    File2 -.references.-> Config1
    File3 -.references.-> Config1
    
    style Assessment fill:#BBDEFB
    style Validation fill:#FFE0B2
    style Audit fill:#E1BEE7
    style Config fill:#FFF9C4
    
    style File1 fill:#2196F3,color:#fff
    style File2 fill:#FF9800,color:#fff
    style File3 fill:#9C27B0,color:#fff
    
    style Config1 fill:#FBC02D
```

---

## 🔄 CSF Implementation Workflow
```mermaid
flowchart LR
    subgraph INPUTS["📥 INPUTS"]
        I1[Organization Profile<br/>JSON/YAML]
        I2[Control Evidence<br/>Documents/Logs]
        I3[Risk Register<br/>CSV/Excel]
        I4[Tier Definitions<br/>YAML Config]
    end
    
    subgraph PROCESSING["⚙️ PROCESSING"]
        P1[Maturity Assessment<br/>Python Engine]
        P2[Core Function Check<br/>Bash Validator]
        P3[Response/Recovery Audit<br/>Python Auditor]
        P4[Tier Alignment<br/>YAML Parser]
    end
    
    subgraph OUTPUTS["📤 OUTPUTS"]
        O1[Maturity Scorecard<br/>JSON/PDF]
        O2[Validation Report<br/>Text/HTML]
        O3[Audit Findings<br/>JSON/CSV]
        O4[Gap Analysis<br/>Markdown/PDF]
    end
    
    I1 --> P1
    I2 --> P2
    I3 --> P3
    I4 --> P4
    
    P1 --> O1
    P2 --> O2
    P3 --> O3
    P4 --> O4
    
    style INPUTS fill:#E3F2FD
    style PROCESSING fill:#FFF3E0
    style OUTPUTS fill:#E8F5E9
```

---

## ⚙️ Maturity Assessment Logic Flow
```mermaid
flowchart TD
    Start([Start Assessment]) --> Step1[Load CSF Tier Definitions]
    Step1 --> Step2[Initialize Category Scoring]
    
    Step2 --> Loop{For Each CSF Category}
    
    Loop -->|Next Category| Decision1{Evidence Complete?}
    
    Decision1 -->|No| Action1[❌ Mark Gap - Tier 1/2]
    Decision1 -->|Yes| Decision2{Process Mature?}
    
    Decision2 -->|No| Action2[⚠️ Partial Implementation - Tier 2/3]
    Decision2 -->|Yes| Action3[✓ Full Implementation - Tier 3/4]
    
    Action1 --> Collect[Collect Subcategory Scores]
    Action2 --> Collect
    Action3 --> Collect
    
    Collect --> MoreCategories{More Categories?}
    
    MoreCategories -->|Yes| Loop
    MoreCategories -->|No| Generate[Generate Function Rollup]
    
    Generate --> Calculate[Calculate Weighted Maturity Score]
    Calculate --> Output([📄 Output Scorecard & Recommendations])
    
    style Start fill:#4CAF50,color:#fff
    style Output fill:#4CAF50,color:#fff
    style Action3 fill:#4CAF50,color:#fff
    style Action2 fill:#FF9800,color:#fff
    style Action1 fill:#F44336,color:#fff
    style Decision1 fill:#2196F3,color:#fff
    style Decision2 fill:#2196F3,color:#fff
    style MoreCategories fill:#2196F3,color:#fff
```

---

## 🔗 System Integration
```mermaid
sequenceDiagram
    participant User
    participant Script
    participant CSF_Engine
    participant Evidence_Store
    
    User->>Script: Execute Maturity Assessment
    Note over Script: Load Tier Configuration
    Script->>CSF_Engine: Initialize Framework Mapping
    CSF_Engine->>Evidence_Store: Query Control Evidence
    Evidence_Store-->>CSF_Engine: Return Evidence Documents
    CSF_Engine-->>Script: Mapped Control Data
    
    Note over Script: Process Each Function (ID/PR/DE/RS/RC)
    
    Script->>CSF_Engine: Calculate Category Scores
    CSF_Engine->>Evidence_Store: Validate Implementation Proof
    Evidence_Store-->>CSF_Engine: Validation Results
    CSF_Engine-->>Script: Subcategory Maturity Levels
    
    Script->>Script: Aggregate Function Scores
    
    Script->>CSF_Engine: Generate Gap Analysis
    CSF_Engine->>Evidence_Store: Store Assessment Results
    Evidence_Store-->>CSF_Engine: Confirmation
    CSF_Engine-->>Script: Gap Report Data
    
    Script-->>User: Maturity Scorecard + Recommendations
```

---

## 📂 File Reference Table

<table>
  <thead>
    <tr>
      <th>File</th>
      <th>Type</th>
      <th>Purpose</th>
      <th>CSF Function Coverage</th>
    </tr>
  </thead>
  <tbody>
    <tr style="background-color: #E3F2FD;">
      <td><code>csf-maturity-assessment.py</code></td>
      <td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"/></td>
      <td>Automated maturity scoring engine evaluating implementation levels across all 23 CSF categories with weighted calculations and tier alignment</td>
      <td><img src="https://img.shields.io/badge/All_Functions-0A84FF" alt="All Functions"/></td>
    </tr>
    <tr style="background-color: #FFF3E0;">
      <td><code>identify-protect-detect.sh</code></td>
      <td><img src="https://img.shields.io/badge/Bash-4EAA25?logo=gnu-bash&logoColor=white" alt="Bash"/></td>
      <td>Core function validation script checking Identify, Protect, and Detect controls against organizational evidence and compliance artifacts</td>
      <td><img src="https://img.shields.io/badge/ID_PR_DE-34C759" alt="ID/PR/DE"/></td>
    </tr>
    <tr style="background-color: #F3E5F5;">
      <td><code>respond-recover-audit.py</code></td>
      <td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"/></td>
      <td>Response and recovery capability auditor validating incident response plans, recovery procedures, and continuous improvement processes</td>
      <td><img src="https://img.shields.io/badge/RS_RC-9C27B0" alt="RS/RC"/></td>
    </tr>
    <tr style="background-color: #FFF9C4;">
      <td><code>csf-implementation-tiers.yaml</code></td>
      <td><img src="https://img.shields.io/badge/Config-6C757D" alt="Config"/></td>
      <td>YAML configuration defining CSF Implementation Tiers 1-4 criteria, maturity thresholds, and organizational profile mappings for assessment calibration</td>
      <td><img src="https://img.shields.io/badge/Framework_Config-FFD60A" alt="Framework Config"/></td>
    </tr>
  </tbody>
</table>

---

This module provides **automated CSF maturity assessment and validation** for **enterprise cybersecurity** workflows, enabling continuous compliance monitoring, gap identification, and risk-informed decision-making across all five core functions (Identify, Protect, Detect, Respond, Recover).

---

**Built for NIST Cybersecurity Framework Compliance | Maintained by Suren Jewels**

[![GitHub](https://img.shields.io/badge/GitHub-Suren--Jewels-181717?logo=github)](https://github.com/Suren-Jewels)
