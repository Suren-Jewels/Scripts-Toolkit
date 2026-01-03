# minor — P3 Severity Sample Migration Events (Cosmetic & Low‑Impact Issues)

This module contains **minor‑severity (P3)** sample migration events used for testing, analytics, and operational readiness validation.  
Minor events represent **cosmetic issues**, **non‑critical configuration drift**, or **low‑impact SELinux mismatches** that do not affect service availability or customer experience.

These samples are used across:
- Smoke tests  
- Integration tests  
- Metrics pipelines  
- Post‑migration validation  
- Documentation and training  

---

## 📁 Folder Structure

| File | Purpose | Severity | Impact |
|------|---------|----------|--------|
| **deprecated-package-warning.json** | Deprecated package detected during validation | 🟡 P3 | Cosmetic |
| **config-file-rpmsave.json** | Config replaced during upgrade, generating `.rpmsave` | 🟡 P3 | Low |
| **selinux-context-mismatch.json** | Non‑critical SELinux context mismatch | 🟡 P3 | Low |

---

## 🧠 Architecture & Logic Flow (Mermaid)
```mermaid
flowchart TD

    A[ℹ️ Minor Event<br/>🟡 P3 Severity] --> B{Category}

    %% Deprecated Package Path
    B -->|📦 Package Warning| C[deprecated-package-warning.json<br/>Deprecated package detected]
    C --> C1[🛠 Review deprecation + plan removal]
    C1 --> C2[🟡 Cosmetic Impact]

    %% Config Drift Path
    B -->|⚙️ Config Drift| D[config-file-rpmsave.json<br/>Config replaced with .rpmsave]
    D --> D1[🛠 Compare configs + restore required settings]
    D1 --> D2[🟡 Low Impact]

    %% SELinux Path
    B -->|🔒 SELinux Regression| E[selinux-context-mismatch.json<br/>Context mismatch]
    E --> E1[🛠 Run restorecon + review policy]
    E1 --> E2[🟡 Low Impact]

    %% Downstream Flow
    C2 --> F[📘 Document Issue]
    D2 --> F
    E2 --> F

    F --> G[✅ No Customer Impact]
    G --> H[📝 Update Migration History]
    
    style A fill:#fff9e6,stroke:#ffcc00,stroke-width:2px
    style C fill:#fff4e6,stroke:#ff9933
    style D fill:#e6f3ff,stroke:#3399ff
    style E fill:#ffe6f0,stroke:#ff3366
    style G fill:#e6ffe6,stroke:#00cc66,stroke-width:2px
```

---

## 🔧 Core Capabilities

### **1. Low‑Impact Migration Issue Simulation**

| Capability | Description | Use Case |
|------------|-------------|----------|
| 📦 **Deprecated Package Warnings** | Simulates package deprecation notices | Post-migration cleanup planning |
| ⚙️ **Config Drift Detection** | Generates `.rpmsave` scenarios | Configuration reconciliation testing |
| 🔒 **SELinux Context Issues** | Non-critical context mismatches | Security policy validation |
| 🧪 **Cosmetic‑Level Validation** | Low-impact issue identification | Quality assurance workflows |

### **2. Documentation & Training Support**

| Function | Benefit | Status |
|----------|---------|--------|
| 📚 Issue Recognition Training | Helps teams identify non‑critical issues | 🟢 Active |
| 🔄 Post‑Migration Workflows | Supports cleanup procedure development | 🟢 Active |
| 💡 Realistic Examples | Provides hands-on learning materials | 🟢 Active |

### **3. Analytics & Reporting Integration**

| Integration Point | Data Flow | Frequency |
|-------------------|-----------|-----------|
| 📊 Weekly Migration Reports | Feeds trend data | Weekly |
| 📈 Recurring Issue Analysis | Pattern identification | Monthly |
| 🎯 Cleanup Prioritization | Supports long-term planning | Quarterly |

### **4. Validation Pipeline Compatibility**

| Pipeline Stage | Event Usage | Coverage |
|----------------|-------------|----------|
| 🧪 Smoke Tests | Basic validation | 100% |
| 🔗 Integration Tests | Cross-component testing | 100% |
| 📊 Metrics Validation | Accuracy verification | 100% |

---

## ▶️ Usage

### View Sample Events
```bash
# View deprecated package warning
cat deprecated-package-warning.json

# View config drift sample
cat config-file-rpmsave.json

# View SELinux mismatch sample
cat selinux-context-mismatch.json
```

### Common Workflows

| Workflow | Command | Purpose |
|----------|---------|---------|
| **Validate All Samples** | `jq . *.json` | Syntax check all events |
| **Extract Severity** | `jq '.severity' *.json` | Verify P3 classification |
| **List Event Types** | `jq '.event_type' *.json` | Catalog event categories |

---

## 📊 Event Classification Matrix

| Event Type | Severity | Customer Impact | SLA Impact | Action Required |
|------------|----------|-----------------|------------|-----------------|
| Deprecated Package | 🟡 P3 | None | None | 📝 Document |
| Config `.rpmsave` | 🟡 P3 | None | None | 🔍 Review |
| SELinux Mismatch | 🟡 P3 | None | None | 🛠 Remediate |

---

## 🎯 Success Criteria

| Metric | Target | Status |
|--------|--------|--------|
| Test Coverage | 100% | ✅ Met |
| Documentation Completeness | 100% | ✅ Met |
| Pipeline Integration | All stages | ✅ Met |
| Training Material Quality | High | ✅ Met |
