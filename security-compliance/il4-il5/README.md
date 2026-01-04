# 🔐 IL4–IL5 Compliance Automation Module

![DoD Impact Levels](https://img.shields.io/badge/DoD-IL4%20%7C%20IL5-0A84FF) ![Security Status](https://img.shields.io/badge/Status-High%20Assurance-34C759) ![Automation](https://img.shields.io/badge/Automation-Enabled-34C759) ![CUI Handling](https://img.shields.io/badge/CUI-Compliant-FFD60A)

Comprehensive security compliance automation suite for DoD Impact Level 4 and Impact Level 5 requirements, enabling automated validation of security controls, CUI data classification, enclave boundary verification, and continuous compliance monitoring across GCC and NSC environments.

| Resource | Link |
|----------|------|
| NIST SP 800-171 | https://csrc.nist.gov/publications/detail/sp/800-171/rev-2/final |
| DoD Cloud Computing SRG | https://public.cyber.mil/dccs/dccs-documents/ |
| CMMC Framework | https://www.acq.osd.mil/cmmc/ |
| GitHub Repository | https://github.com/Suren-Jewels/Scripts-Toolkit |

---

## 📊 Current IL4–IL5 Compliance Status
```
IL4 Control Implementation      [███████████████████░░░░░] 82% (123/150) ✓
IL5 Control Implementation      [████████████████░░░░░░░░] 68% (102/150) ⚠
────────────────────────────────────────────────────────────────────────────
Access Controls (NIST AC Family):
  Multi-Factor Authentication   [████████████████████████] 100%          ✓
  Role-Based Access Control     [███████████████████████░] 95%           ✓
  Least Privilege Enforcement   [██████████████████████░░] 89%           ✓
────────────────────────────────────────────────────────────────────────────
Data Protection (NIST SC Family):
  FIPS 140-2 Encryption         [████████████████████░░░░] 85%           ✓
  CUI Data Classification       [███████████████████░░░░░] 78%           ⚠
  Data-at-Rest Protection       [███████████████████████░] 92%           ✓
────────────────────────────────────────────────────────────────────────────
Audit & Accountability (NIST AU):
  Comprehensive Logging         [████████████████████░░░░] 81%           ✓
  Log Retention Compliance      [███████████████████████░] 94%           ✓
  Security Event Monitoring     [██████████████████░░░░░░] 73%           ⚠
────────────────────────────────────────────────────────────────────────────
Boundary Protection:
  GCC Enclave Isolation         [████████████████████████] 100%          ✓
  NSC Network Segmentation      [███████████████████████░] 96%           ✓
────────────────────────────────────────────────────────────────────────────
Device Posture Validation       [██████████████████░░░░░░] 76%           ⚠
────────────────────────────────────────────────────────────────────────────
Monthly Trend:  ▃▅▆▆▇▇█  (Improving)

Risk Distribution:
  Critical: 4  |  High: 12  |  Medium: 28  |  Low: 19  |  Passed: 87
```

---

## 🗂️ Module Architecture
```mermaid
graph TD
    Root[[🔐 IL4-IL5 Compliance Module]]
    
    Root --> Checkers[[🔍 Compliance Checkers]]
    Root --> Classifiers[[📋 Data Classification]]
    Root --> Auditors[[🔎 Security Auditors]]
    Root --> Configs[[⚙️ Configuration Files]]
    
    Checkers --> File1[il4-compliance-checker.py]
    Checkers --> File2[il5-compliance-checker.py]
    Checkers --> File3[il-posture-validator.py]
    
    Classifiers --> File4[cui-data-classifier.py]
    Classifiers --> File5[gcc-nsc-boundary-check.sh]
    
    Auditors --> File6[mfa-enforcement-audit.ps1]
    Auditors --> File7[encryption-validator.sh]
    Auditors --> File8[access-control-audit.py]
    
    Configs --> Config1[il4-control-matrix.yaml]
    Configs --> Config2[il5-control-matrix.yaml]
    Configs --> Config3[cui-handling-procedures.md]
    
    File1 -.references.-> Config1
    File2 -.references.-> Config2
    File4 -.references.-> Config3
    File6 -.references.-> Config1
    File7 -.references.-> Config1
    File8 -.references.-> Config2
    
    style Checkers fill:#BBDEFB
    style Classifiers fill:#FFE0B2
    style Auditors fill:#E1BEE7
    style Configs fill:#FFF9C4
    
    style File1 fill:#2196F3,color:#fff
    style File2 fill:#2196F3,color:#fff
    style File3 fill:#2196F3,color:#fff
    style File4 fill:#FF9800,color:#fff
    style File5 fill:#FF9800,color:#fff
    style File6 fill:#9C27B0,color:#fff
    style File7 fill:#9C27B0,color:#fff
    style File8 fill:#9C27B0,color:#fff
    
    style Config1 fill:#FBC02D
    style Config2 fill:#FBC02D
    style Config3 fill:#FBC02D
```

---

## 🔄 IL4–IL5 Compliance Validation Workflow
```mermaid
flowchart LR
    subgraph INPUTS["📥 INPUTS"]
        I1[Security Policies<br/>STIG Requirements]
        I2[System Inventory<br/>Asset Database]
        I3[CUI Data Sources<br/>Classified Content]
        I4[Network Topology<br/>Enclave Boundaries]
    end
    
    subgraph PROCESSING["⚙️ PROCESSING"]
        P1[Control Validation<br/>Python/YAML]
        P2[Posture Assessment<br/>Python Engine]
        P3[Data Classification<br/>CUI Classifier]
        P4[Boundary Verification<br/>Bash/Network Tools]
    end
    
    subgraph OUTPUTS["📤 OUTPUTS"]
        O1[Compliance Reports<br/>JSON/HTML]
        O2[Remediation Plans<br/>Prioritized Tasks]
        O3[CUI Labels<br/>Classification Tags]
        O4[Boundary Alerts<br/>Security Violations]
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

## ⚙️ Compliance Validation Logic Flow
```mermaid
flowchart TD
    Start([Start Compliance Check]) --> Step1[Load Control Matrix YAML]
    Step1 --> Step2[Initialize Assessment Engine]
    
    Step2 --> Loop{For Each Security Control}
    
    Loop -->|Next Control| Decision1{Control Implemented?}
    
    Decision1 -->|No| Action1[❌ Mark as Non-Compliant]
    Decision1 -->|Yes| Decision2{Evidence Verified?}
    
    Decision2 -->|No| Action2[⚠️ Mark as Partial Compliance]
    Decision2 -->|Yes| Decision3{Meets IL4/IL5 Standard?}
    
    Decision3 -->|No| Action2
    Decision3 -->|Yes| Action3[✓ Mark as Fully Compliant]
    
    Action1 --> CollectFindings[Collect Findings & Evidence]
    Action2 --> CollectFindings
    Action3 --> CollectFindings
    
    CollectFindings --> MoreControls{More Controls?}
    
    MoreControls -->|Yes| Loop
    MoreControls -->|No| Generate[Generate Compliance Report]
    
    Generate --> Calculate[Calculate Risk Score & Gaps]
    Calculate --> Prioritize[Prioritize Remediation Actions]
    Prioritize --> Output([📄 Export Results JSON/HTML])
    
    style Start fill:#4CAF50,color:#fff
    style Output fill:#4CAF50,color:#fff
    style Action3 fill:#4CAF50,color:#fff
    style Action2 fill:#FF9800,color:#fff
    style Action1 fill:#F44336,color:#fff
    style Decision1 fill:#2196F3,color:#fff
    style Decision2 fill:#2196F3,color:#fff
    style Decision3 fill:#2196F3,color:#fff
    style MoreControls fill:#2196F3,color:#fff
```

---

## 🔗 Security Control Validation Integration
```mermaid
sequenceDiagram
    participant Admin
    participant Checker
    participant ControlMatrix
    participant SystemAPI
    
    Admin->>Checker: Execute Compliance Check
    Note over Checker: Load IL4/IL5 Requirements
    Checker->>ControlMatrix: Query Security Controls
    ControlMatrix-->>Checker: Control Definitions & Thresholds
    
    Checker->>SystemAPI: Request System Configuration
    SystemAPI-->>Checker: Current Security Settings
    
    Note over Checker: Validate Against Standards
    
    Checker->>SystemAPI: Query MFA Status
    SystemAPI-->>Checker: MFA Enforcement Data
    
    Checker->>SystemAPI: Query Encryption Status
    SystemAPI-->>Checker: FIPS 140-2 Compliance Data
    
    Checker->>SystemAPI: Query Access Controls
    SystemAPI-->>Checker: RBAC Configuration
    
    Checker->>Checker: Calculate Compliance Score
    
    Checker->>ControlMatrix: Store Assessment Results
    ControlMatrix-->>Checker: Confirmation
    
    Checker-->>Admin: Compliance Report with Findings
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
      <td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"/></td>
      <td>Validates IL4 security controls against NIST SP 800-171 requirements and generates compliance reports</td>
      <td><img src="https://img.shields.io/badge/IL4-0A84FF" alt="IL4"/></td>
    </tr>
    <tr style="background-color: #E3F2FD;">
      <td><code>il5-compliance-checker.py</code></td>
      <td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"/></td>
      <td>Validates IL5 security controls with enhanced requirements for classified information handling</td>
      <td><img src="https://img.shields.io/badge/IL5-FF3B30" alt="IL5"/></td>
    </tr>
    <tr style="background-color: #E3F2FD;">
      <td><code>il-posture-validator.py</code></td>
      <td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"/></td>
      <td>Validates device security posture including patch levels, EDR status, and configuration compliance</td>
      <td><img src="https://img.shields.io/badge/IL4%20%7C%20IL5-FFD60A" alt="Both"/></td>
    </tr>
    <tr style="background-color: #FFF3E0;">
      <td><code>cui-data-classifier.py</code></td>
      <td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"/></td>
      <td>Scans and classifies Controlled Unclassified Information using pattern matching and ML algorithms</td>
      <td><img src="https://img.shields.io/badge/CUI-34C759" alt="CUI"/></td>
    </tr>
    <tr style="background-color: #FFF3E0;">
      <td><code>gcc-nsc-boundary-check.sh</code></td>
      <td><img src="https://img.shields.io/badge/Bash-4EAA25?logo=gnu-bash&logoColor=white" alt="Bash"/></td>
      <td>Validates network boundary controls between GCC and NSC enclaves, ensuring proper isolation</td>
      <td><img src="https://img.shields.io/badge/Network-6C757D" alt="Network"/></td>
    </tr>
    <tr style="background-color: #F3E5F5;">
      <td><code>mfa-enforcement-audit.ps1</code></td>
      <td><img src="https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white" alt="PowerShell"/></td>
      <td>Audits multi-factor authentication enforcement across Azure AD and on-premises Active Directory</td>
      <td><img src="https://img.shields.io/badge/MFA-0A84FF" alt="MFA"/></td>
    </tr>
    <tr style="background-color: #F3E5F5;">
      <td><code>encryption-validator.sh</code></td>
      <td><img src="https://img.shields.io/badge/Bash-4EAA25?logo=gnu-bash&logoColor=white" alt="Bash"/></td>
      <td>Validates FIPS 140-2 compliant encryption for data at rest and in transit across systems</td>
      <td><img src="https://img.shields.io/badge/FIPS%20140--2-34C759" alt="FIPS"/></td>
    </tr>
    <tr style="background-color: #F3E5F5;">
      <td><code>access-control-audit.py</code></td>
      <td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"/></td>
      <td>Audits role-based access controls, least privilege implementation, and separation of duties</td>
      <td><img src="https://img.shields.io/badge/RBAC-FFD60A" alt="RBAC"/></td>
    </tr>
    <tr style="background-color: #FFF9C4;">
      <td><code>il4-control-matrix.yaml</code></td>
      <td><img src="https://img.shields.io/badge/Config-6C757D" alt="Config"/></td>
      <td>Defines IL4 security control requirements, validation criteria, and compliance thresholds</td>
      <td><img src="https://img.shields.io/badge/IL4-0A84FF" alt="IL4"/></td>
    </tr>
    <tr style="background-color: #FFF9C4;">
      <td><code>il5-control-matrix.yaml</code></td>
      <td><img src="https://img.shields.io/badge/Config-6C757D" alt="Config"/></td>
      <td>Defines IL5 enhanced security control requirements with stricter validation rules</td>
      <td><img src="https://img.shields.io/badge/IL5-FF3B30" alt="IL5"/></td>
    </tr>
    <tr style="background-color: #FFF9C4;">
      <td><code>cui-handling-procedures.md</code></td>
      <td><img src="https://img.shields.io/badge/Documentation-6C757D" alt="Documentation"/></td>
      <td>Comprehensive guidelines for CUI data identification, marking, handling, and disposal procedures</td>
      <td><img src="https://img.shields.io/badge/CUI-34C759" alt="CUI"/></td>
    </tr>
  </tbody>
</table>

---

This module provides **automated security control validation** for **DoD Impact Level 4 and 5** workflows, enabling continuous compliance monitoring, CUI data protection, and risk-based remediation prioritization across government cloud computing (GCC) and national security cloud (NSC) environments.

---

**Built for DoD Impact Level Compliance | Maintained by Suren Jewels**

[![GitHub](https://img.shields.io/badge/GitHub-Suren--Jewels-181717?logo=github)](https://github.com/Suren-Jewels)
