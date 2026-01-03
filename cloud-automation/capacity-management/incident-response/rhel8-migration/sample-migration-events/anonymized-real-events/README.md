# anonymized-real-events — Sanitized Production Migration Incidents

This module contains **sanitized real-world RHEL8 migration incidents**, anonymized for safe distribution and training.  
These events originate from actual production outages and degradations encountered during large‑scale migrations, then stripped of identifying data while preserving operational truth.

These samples support:
- Realistic incident‑response training  
- Severity‑driven analytics  
- Regression testing against real patterns  
- MTTR and blast‑radius modeling  
- Migration readiness assessments  

---

## 📁 Folder Structure

| File | Purpose | Severity | Type |
|------|---------|----------|------|
| **incident-20240715-server-042.json** | Real bootloader failure (blocker) | 🔴 **SEV-1** | Boot Failure |
| **incident-20240722-server-156.json** | Real NIC driver regression (major) | 🟠 **SEV-2** | Network Regression |
| **incident-20240805-server-289.json** | Real package dependency conflict (major) | 🟠 **SEV-2** | Package Conflict |

---

## 🧠 Architecture & Logic Flow
```mermaid
flowchart TD

    A[🧪 Anonymized Real Migration Incidents<br/>anonymized-real-events/] --> B{Incident Type}

    %% Boot Failure Path - RED
    B -->|🔴 Boot Failure| C[incident-20240715-server-042.json<br/>Bootloader failure]
    C --> C1[🛠 GRUB repair + initramfs rebuild]
    C1 --> C2[🚨 SEV-1 escalation]

    %% Network Regression Path - ORANGE
    B -->|🟠 Network Regression| D[incident-20240722-server-156.json<br/>NIC driver instability]
    D --> D1[🛠 Driver update + interface stabilization]
    D1 --> D2[📉 Service degradation]

    %% Package Conflict Path - ORANGE
    B -->|🟠 Package Conflict| E[incident-20240805-server-289.json<br/>Dependency conflict]
    E --> E1[🛠 Resolve dependencies + rebuild environment]
    E1 --> E2[📊 Partial outage]

    %% Downstream Integration - BLUE
    C2 --> F[📈 Metrics Pipeline]
    D2 --> F
    E2 --> F

    F --> G[📝 Post-Migration Analytics]
    G --> H[📚 Training & Readiness Improvement]

    %% Styling
    style C fill:#ff6b6b,stroke:#c92a2a,stroke-width:3px,color:#fff
    style C2 fill:#ff6b6b,stroke:#c92a2a,stroke-width:2px,color:#fff
    style D fill:#ff922b,stroke:#e8590c,stroke-width:3px,color:#fff
    style D2 fill:#ff922b,stroke:#e8590c,stroke-width:2px,color:#fff
    style E fill:#ff922b,stroke:#e8590c,stroke-width:3px,color:#fff
    style E2 fill:#ff922b,stroke:#e8590c,stroke-width:2px,color:#fff
    style F fill:#4dabf7,stroke:#1971c2,stroke-width:2px,color:#fff
    style G fill:#51cf66,stroke:#2f9e44,stroke-width:2px,color:#fff
    style H fill:#51cf66,stroke:#2f9e44,stroke-width:2px,color:#fff
```

---

## 🔧 Core Capabilities

### **1. Real‑World Incident Modeling**
| Capability | Description | Impact |
|------------|-------------|---------|
| 🔴 **Bootloader failures** | GRUB misconfigurations, initramfs corruption | Critical service outage |
| 🟠 **NIC driver regressions** | Network instability post-migration | Service degradation |
| 🟠 **Package dependency conflicts** | RPM resolution failures | Partial functionality loss |
| ✅ **Data sanitization** | All PII/sensitive data removed | Safe for training/analysis |

### **2. Escalation & Response Training**
| Severity | Response Time | Escalation Path | Training Use Case |
|----------|---------------|-----------------|-------------------|
| 🔴 **SEV-1** | < 15 min | Immediate on-call + management | Critical incident response drills |
| 🟠 **SEV-2** | < 1 hour | Standard on-call rotation | Service degradation scenarios |
| 🟡 **SEV-3** | < 4 hours | Next business day | Non-critical issue handling |

### **3. Analytics & Reporting Integration**
| Metric | Calculation | Business Value |
|--------|-------------|----------------|
| **MTTR** | Time from detection → resolution | Operational efficiency |
| **MTTD** | Time from occurrence → detection | Monitoring effectiveness |
| **Blast Radius** | # affected servers/services | Risk quantification |
| **Recurrence Rate** | Incidents per migration phase | Quality improvement |

### **4. Regression Testing & Validation**
| Test Category | Purpose | Validation Target |
|---------------|---------|-------------------|
| ✅ **Pattern Detection** | Verify tooling catches known issues | Automated detection accuracy |
| ✅ **Canary Deployment** | Test migration phases safely | Pre-production validation |
| ✅ **Rollback Procedures** | Ensure recovery mechanisms work | Business continuity |
| ✅ **Alert Tuning** | Reduce false positives | Alert signal quality |

---

## ▶️ Usage Examples

### **View Real Boot Failure Sample**
```bash
cat incident-20240715-server-042.json
```
**Expected output:** SEV-1 bootloader failure with GRUB repair steps

### **View Real Network Regression Sample**
```bash
cat incident-20240722-server-156.json
```
**Expected output:** SEV-2 NIC driver instability with rollback procedure

### **View Real Package Conflict Sample**
```bash
cat incident-20240805-server-289.json
```
**Expected output:** SEV-2 dependency conflict with resolution workflow

### **Batch Analysis**
```bash
# Count incidents by severity
jq -r '.severity' incident-*.json | sort | uniq -c

# Extract MTTR statistics
jq -r '.metrics.mttr' incident-*.json | awk '{sum+=$1; count++} END {print "Avg MTTR:", sum/count, "minutes"}'
```

---

## 📊 Incident Classification Matrix

| Incident Type | Frequency | Avg MTTR | Blast Radius | Prevention Strategy |
|---------------|-----------|----------|--------------|---------------------|
| 🔴 **Boot Failures** | 3% | 45 min | High (entire server) | Pre-migration boot validation |
| 🟠 **Network Issues** | 12% | 75 min | Medium (service-level) | Driver compatibility testing |
| 🟠 **Package Conflicts** | 8% | 60 min | Low-Medium (app-level) | Dependency graph analysis |
| 🟡 **Performance Degradation** | 15% | 120 min | Low (gradual impact) | Load testing + profiling |

---

## 🎯 Key Takeaways

| Finding | Recommendation | Priority |
|---------|----------------|----------|
| **Boot failures are rare but critical** | Implement automated bootloader validation | 🔴 High |
| **Network regressions show patterns** | Maintain driver compatibility matrix | 🟠 Medium |
| **Package conflicts are preventable** | Use dependency pre-flight checks | 🟠 Medium |
| **Real data beats synthetic tests** | Expand anonymized incident corpus | 🟢 Low |

---

## 🔒 Data Privacy & Compliance

✅ All hostnames sanitized  
✅ All IP addresses anonymized  
✅ All personnel names removed  
✅ All customer identifiers stripped  
✅ Operational truth preserved  

**Safe for:** Training, testing, documentation, public repositories
