# 🔐 IL4–IL5 Compliance Automation Module

![Impact Level](https://img.shields.io/badge/Impact-IL4%20%7C%20IL5-0A84FF) ![Category](https://img.shields.io/badge/Category-Security%20%7C%20Compliance-34C759) ![Automation](https://img.shields.io/badge/Automation-Enabled-30D158) ![CUI](https://img.shields.io/badge/CUI-Handling%20Included-FFD60A)

A modular, analytics-driven automation suite for **IL4/IL5 compliance**, covering posture validation, RBAC auditing, encryption checks, CUI classification, and enclave boundary validation. Engineered for **repeatable, auditable, and scalable** compliance workflows across DoD-aligned environments.

## 🔗 Quick Links

| Resource | Link |
|----------|------|
| **DoD Impact Levels** | https://public.cyber.mil |
| **CUI Program** | https://www.archives.gov/cui |
| **NIST 800-171** | https://csrc.nist.gov |
| **Suren Jewels GitHub** | https://github.com/Suren-Jewels |

---

## 📊 Current Compliance Status

### Control Implementation Progress
```
IL4 Controls (140/170):  ████████████████████░░░░  82% ✓
IL5 Controls (139/240):  ██████████████░░░░░░░░░░  58% ⚠

Security Posture:
├─ Encryption:          ████████████████████████ 100% ✓
├─ Firewall:            ███████████████████████░  95% ✓
├─ Antivirus:           ██████████████████████░░  90% ✓
├─ MFA:                 █████████████████████░░░  85% ✓
└─ OS Patching:         ███████████████████░░░░░  75% ⚠

CUI Classification:     ████████████████████░░░░  78% ⚠

Boundary Validation:
├─ GCC High:            ████████████████████████ 100% ✓
├─ DoD Cloud:           ███████████████████████░  95% ✓
└─ NSC:                 ██████████████████████░░  90% ✓
```

### Monthly Trend (Last 6 Months)
```
IL4: ▁▃▅▆▇█  (Improving)
IL5: ▂▃▄▅▅▆  (Steady Growth)
```

### Risk Distribution
```
Critical:  ██░░░░░░░░░░░░░░░░░░░░░░  8%  ❌
High:      █████░░░░░░░░░░░░░░░░░░░ 22%  ⚠
Medium:    ████████████░░░░░░░░░░░░ 48%  ⚠
Low:       █████░░░░░░░░░░░░░░░░░░░ 22%  ✓
```

---

## 🗂️ Module Architecture
```mermaid
graph TD
    Root[🔐 IL4-IL5 Compliance Module]
    
    %% Script Categories
    Root --> Checkers[📋 Compliance Checkers]
    Root --> Validators[✅ Validators]
    Root --> Auditors[🔍 Auditors]
    Root --> Config[⚙️ Configuration Files]
    
    %% Checkers
    Checkers --> IL4Check[il4-compliance-checker.py]
    Checkers --> IL5Check[il5-compliance-checker.py]
    
    %% Validators
    Validators --> CUIClass[cui-data-classifier.py]
    Validators --> BoundCheck[gcc-nsc-boundary-check.sh]
    Validators --> PostureVal[il-posture-validator.py]
    Validators --> EncryptVal[encryption-validator.sh]
    
    %% Auditors
    Auditors --> MFAAudit[mfa-enforcement-audit.ps1]
    Auditors --> AccessAudit[access-control-audit.py]
    
    %% Configuration
    Config --> IL4Matrix[il4-control-matrix.yaml]
    Config --> IL5Matrix[il5-control-matrix.yaml]
    Config --> CUIProc[cui-handling-procedures.md]
    
    %% Connections
    IL4Check -.->|references| IL4Matrix
    IL5Check -.->|references| IL5Matrix
    CUIClass -.->|references| CUIProc
    
    %% Styling
    classDef checkerStyle fill:#2196F3,stroke:#1976D2,color:#fff
    classDef validatorStyle fill:#FF9800,stroke:#F57C00,color:#fff
    classDef auditorStyle fill:#9C27B0,stroke:#7B1FA2,color:#fff
    classDef configStyle fill:#FFC107,stroke:#FFA000,color:#000
    
    class IL4Check,IL5Check checkerStyle
    class CUIClass,BoundCheck,PostureVal,EncryptVal validatorStyle
    class MFAAudit,AccessAudit auditorStyle
    class IL4Matrix,IL5Matrix,CUIProc configStyle
```

---

## 🔄 Compliance Workflow
```mermaid
flowchart LR
    subgraph INPUTS["📥 INPUTS"]
        I1[Control Matrices<br/>IL4/IL5 YAML]
        I2[Device Configs<br/>Posture Data]
        I3[User Data<br/>MFA Status]
        I4[Cipher Configs<br/>Encryption Settings]
        I5[CUI Content<br/>Text Files]
        I6[Boundary Config<br/>Tenant Data]
    end
    
    subgraph PROCESSING["⚙️ PROCESSING"]
        P1[Control Validation<br/>Engine]
        P2[Posture Assessment<br/>Engine]
        P3[CUI Classification<br/>Engine]
        P4[Boundary Validation<br/>Engine]
        P5[MFA Audit<br/>Engine]
        P6[Encryption Check<br/>Engine]
        P7[RBAC Analysis<br/>Engine]
    end
    
    subgraph OUTPUTS["📤 OUTPUTS"]
        O1[Compliance Reports<br/>Pass/Fail Status]
        O2[Finding Details<br/>Missing/Extra Controls]
        O3[Metrics Dashboard<br/>Coverage Statistics]
        O4[Audit Logs<br/>Timestamped Events]
        O5[Remediation Guide<br/>Action Items]
    end
    
    I1 --> P1
    I2 --> P2
    I3 --> P5
    I4 --> P6
    I5 --> P3
    I6 --> P4
    
    P1 --> O1
    P2 --> O1
    P3 --> O2
    P4 --> O2
    P5 --> O2
    P6 --> O2
    P7 --> O2
    
    P1 --> O3
    P2 --> O3
    P5 --> O3
    
    P1 --> O4
    P2 --> O4
    P5 --> O4
    P6 --> O4
    
    O2 --> O5
    
    style INPUTS fill:#E3F2FD,stroke:#1976D2
    style PROCESSING fill:#FFF3E0,stroke:#F57C00
    style OUTPUTS fill:#E8F5E9,stroke:#388E3C
```

---

## ⚙️ Validation Logic Flow
```mermaid
flowchart TD
    Start([🚀 Start Validation]) --> LoadMatrix[📋 Load Control Matrix]
    LoadMatrix --> LoadImpl[📥 Load Implemented Controls]
    LoadImpl --> CompareLoop{🔍 Compare Each Control}
    
    CompareLoop -->|Control Found| CheckStandard{📏 Meets Standard?}
    CompareLoop -->|Control Missing| MarkMissing[⚠️ Flag as Missing]
    
    CheckStandard -->|Yes| MarkPass[✅ Mark as Compliant]
    CheckStandard -->|No| MarkFail[❌ Mark as Non-Compliant]
    
    MarkPass --> CheckMore{More Controls?}
    MarkFail --> CheckMore
    MarkMissing --> CheckMore
    
    CheckMore -->|Yes| CompareLoop
    CheckMore -->|No| CheckExtra{🔎 Extra Controls?}
    
    CheckExtra -->|Yes| MarkExtra[⚠️ Flag Extra Controls]
    CheckExtra -->|No| GenerateReport
    MarkExtra --> GenerateReport
    
    GenerateReport[📊 Generate Report] --> CalcScore[📈 Calculate Compliance Score]
    CalcScore --> OutputResults[📤 Output Results]
    OutputResults --> End([✓ Complete])
    
    style Start fill:#4CAF50,stroke:#2E7D32,color:#fff
    style End fill:#4CAF50,stroke:#2E7D32,color:#fff
    style MarkPass fill:#4CAF50,stroke:#2E7D32,color:#fff
    style MarkFail fill:#F44336,stroke:#C62828,color:#fff
    style MarkMissing fill:#FF9800,stroke:#F57C00,color:#fff
    style MarkExtra fill:#FF9800,stroke:#F57C00,color:#fff
    style LoadMatrix fill:#2196F3,stroke:#1976D2,color:#fff
    style LoadImpl fill:#2196F3,stroke:#1976D2,color:#fff
    style GenerateReport fill:#2196F3,stroke:#1976D2,color:#fff
    style CalcScore fill:#2196F3,stroke:#1976D2,color:#fff
```

---

## 🔗 System Integration
```mermaid
sequenceDiagram
    participant User as 👤 User
    participant Script as 🐍 Validation Script
    participant API as 🌐 Compliance API
    participant DB as 💾 Database
    
    User->>Script: Execute validation run
    Note over User,Script: Initiates compliance check
    
    Script->>API: Authenticate request
    Note over Script,API: API Key + MFA token
    API-->>Script: Auth token returned
    
    Script->>API: Fetch control matrix
    API->>DB: Query control requirements
    Note over API,DB: Cached for 24h
    DB-->>API: Return control data
    API-->>Script: Control matrix JSON
    
    Script->>Script: Load implemented controls
    Script->>Script: Validate against matrix
    Note over Script: Comparison logic
    
    Script->>API: Submit validation results
    API->>DB: Store compliance snapshot
    DB-->>API: Confirmation
    API-->>Script: Results stored
    
    Script-->>User: Display compliance report
    Note over User,Script: Pass/Fail + findings
    
    User->>Script: Request detailed findings
    Script->>API: Fetch finding details
    Note over Script,API: Include remediation steps
    API-->>Script: Detailed findings JSON
    Script-->>User: Display finding breakdown
```

---

## 📂 File Reference Table

<table>
<thead>
<tr>
<th>File</th>
<th>Type</th>
<th>Purpose</th>
<th>Impact Level</th>
</tr>
</thead>
<tbody>
<tr style="background-color: #E3F2FD;">
<td><code>il4-compliance-checker.py</code></td>
<td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"></td>
<td>Validates IL4 controls against baseline</td>
<td><img src="https://img.shields.io/badge/IL4-0A84FF" alt="IL4"></td>
</tr>
<tr style="background-color: #FCE4EC;">
<td><code>il5-compliance-checker.py</code></td>
<td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"></td>
<td>Validates IL5 controls against baseline</td>
<td><img src="https://img.shields.io/badge/IL5-FF3B30" alt="IL5"></td>
</tr>
<tr style="background-color: #FFF9C4;">
<td><code>cui-data-classifier.py</code></td>
<td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"></td>
<td>Classifies CUI vs NON-CUI content</td>
<td><img src="https://img.shields.io/badge/BOTH-FFD60A" alt="BOTH"></td>
</tr>
<tr style="background-color: #F3E5F5;">
<td><code>gcc-nsc-boundary-check.sh</code></td>
<td><img src="https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=white" alt="Bash"></td>
<td>Validates GCC/NSC enclave boundaries</td>
<td><img src="https://img.shields.io/badge/BOTH-FFD60A" alt="BOTH"></td>
</tr>
<tr style="background-color: #E8F5E9;">
<td><code>il-posture-validator.py</code></td>
<td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"></td>
<td>Validates device posture: encryption, firewall, AV, MFA, OS</td>
<td><img src="https://img.shields.io/badge/BOTH-FFD60A" alt="BOTH"></td>
</tr>
<tr style="background-color: #FCE4EC;">
<td><code>mfa-enforcement-audit.ps1</code></td>
<td><img src="https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white" alt="PowerShell"></td>
<td>Audits MFA enforcement across users</td>
<td><img src="https://img.shields.io/badge/BOTH-FFD60A" alt="BOTH"></td>
</tr>
<tr style="background-color: #FFF3E0;">
<td><code>encryption-validator.sh</code></td>
<td><img src="https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=white" alt="Bash"></td>
<td>Validates FIPS-approved encryption</td>
<td><img src="https://img.shields.io/badge/BOTH-FFD60A" alt="BOTH"></td>
</tr>
<tr style="background-color: #E0F7FA;">
<td><code>access-control-audit.py</code></td>
<td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"></td>
<td>Audits RBAC and privilege assignments</td>
<td><img src="https://img.shields.io/badge/BOTH-FFD60A" alt="BOTH"></td>
</tr>
<tr style="background-color: #EEEEEE;">
<td><code>il4-control-matrix.yaml</code></td>
<td><img src="https://img.shields.io/badge/Config-6C757D" alt="Config"></td>
<td>IL4 control requirements baseline</td>
<td><img src="https://img.shields.io/badge/IL4-0A84FF" alt="IL4"></td>
</tr>
<tr style="background-color: #EEEEEE;">
<td><code>il5-control-matrix.yaml</code></td>
<td><img src="https://img.shields.io/badge/Config-6C757D" alt="Config"></td>
<td>IL5 control requirements baseline</td>
<td><img src="https://img.shields.io/badge/IL5-FF3B30" alt="IL5"></td>
</tr>
<tr style="background-color: #EEEEEE;">
<td><code>cui-handling-procedures.md</code></td>
<td><img src="https://img.shields.io/badge/Config-6C757D" alt="Config"></td>
<td>CUI handling guidelines</td>
<td><img src="https://img.shields.io/badge/BOTH-FFD60A" alt="BOTH"></td>
</tr>
</tbody>
</table>

---

## 🏁 Summary

This module provides **end-to-end IL4/IL5 compliance automation**, enabling consistent, auditable, and repeatable workflows across DoD-aligned environments. It integrates posture validation, RBAC auditing, encryption checks, CUI classification, and enclave boundary validation into a unified, modular toolkit designed for operational excellence in high-security contexts.

---

**Built for DoD Impact Level Compliance | Maintained by Suren Jewels**

[![GitHub](https://img.shields.io/badge/GitHub-Suren--Jewels-181717?logo=github)](https://github.com/Suren-Jewels)
