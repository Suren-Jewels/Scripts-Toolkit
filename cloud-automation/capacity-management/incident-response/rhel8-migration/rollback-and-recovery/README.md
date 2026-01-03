# 🔄 rollback-and-recovery — RHEL8 Migration Rollback & System Recovery Engine

A capability‑centric recovery suite that provides **safe, deterministic, and auditable rollback paths** for failed RHEL7 → RHEL8 migrations.  
This module ensures that any host experiencing **boot failures**, **service regressions**, **network loss**, or **critical blockers** can be restored to a stable pre‑migration state.

---

## 📁 Folder Structure

| **File** | **Purpose** | **Category** |
|----------|-------------|--------------|
| **snapshot-validator.sh** | Validates snapshot integrity before rollback | 🔍 Validation |
| **rollback-runner.sh** | Restores the system to the pre‑migration snapshot | ⏪ Core Rollback |
| **grub-repair.sh** | Repairs GRUB/bootloader issues | 🛠️ Boot Recovery |
| **network-recovery.sh** | Restores network configuration after failure | 🌐 Network Recovery |
| **service-restore.py** | Restores systemd services to pre‑migration state | 🔧 Service Recovery |
| **emergency-rollback.sh** | Fast‑path rollback for P1 migration incidents | 🚨 Emergency Path |

---

## 🧠 Architecture & Logic Flow
```mermaid
flowchart TD
    A[🔍 snapshot-validator.sh<br/><b>Validate Snapshot Integrity</b>] --> B{Valid?}
    
    B -->|✅ Yes| C[⏪ rollback-runner.sh<br/><b>Controlled Rollback</b>]
    B -->|❌ No| Z[⛔ Abort - Invalid Snapshot]
    
    C --> D[🛠️ grub-repair.sh<br/><b>Fix Bootloader</b>]
    C --> E[🌐 network-recovery.sh<br/><b>Restore Network</b>]
    C --> F[🔧 service-restore.py<br/><b>Restore Services</b>]
    
    D --> G[✅ System Ready]
    E --> G
    F --> G
    
    H[🚨 emergency-rollback.sh<br/><b>P1 Fast-Path</b>] -.->|Bypass validation| D
    H -.-> E
    H -.-> F
    
    style A fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    style C fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style D fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style E fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    style F fill:#fff9c4,stroke:#f9a825,stroke-width:2px
    style H fill:#ffebee,stroke:#c62828,stroke-width:3px
    style G fill:#c8e6c9,stroke:#2e7d32,stroke-width:2px
    style Z fill:#ffcdd2,stroke:#d32f2f,stroke-width:2px
```

---

## 🔧 Core Capabilities

| **Capability** | **Description** | **Key Actions** | **Priority** |
|----------------|-----------------|-----------------|--------------|
| **🔍 Snapshot Validation** | Ensures rollback safety by verifying snapshot integrity | • Check snapshot directory<br>• Verify pre-migration image<br>• Confirm host eligibility | 🟢 Pre-flight |
| **⏪ Controlled Rollback** | Orchestrates full system restoration | • Stop critical services<br>• Restore snapshot<br>• Reboot to known-good state | 🟡 Standard Path |
| **🛠️ GRUB & Bootloader Repair** | Fixes boot-related failures | • Reinstall GRUB<br>• Rebuild config<br>• Fix post-migration boot issues | 🟠 Boot Recovery |
| **🌐 Network Recovery** | Restores network connectivity | • Restore NIC configs<br>• Reload NetworkManager<br>• Re-establish routing/DNS | 🔵 Network Layer |
| **🔧 Service State Restoration** | Returns services to pre-migration state | • Restore systemd presets<br>• Restore service units<br>• Reload systemd daemon | 🟣 Service Layer |
| **🚨 Emergency Rollback** | Immediate recovery for critical failures | • Bypass validation<br>• Execute snapshot restore<br>• Minimal safety checks | 🔴 P1/SEV-1 Only |

---

## ▶️ Usage Examples

### **Standard Workflow**
```bash
# Step 1: Validate snapshot before rollback
./snapshot-validator.sh prod-web-01
# ✅ Snapshot validated successfully

# Step 2: Perform controlled rollback
./rollback-runner.sh prod-web-01
# ⏪ Rolling back to pre-migration state...
# ✅ Rollback complete. System will reboot.

# Step 3 (if needed): Repair specific components
./grub-repair.sh prod-web-01        # Fix boot issues
./network-recovery.sh prod-web-01    # Restore network
python3 service-restore.py prod-web-01  # Restore services
```

### **Emergency Scenario (P1 Incident)**
```bash
# Fast-path rollback - skips validation for speed
./emergency-rollback.sh prod-db-03
# 🚨 EMERGENCY ROLLBACK INITIATED
# ⏪ Restoring snapshot immediately...
# ✅ System restored. Rebooting now.
```

---

## 🎯 Decision Matrix: Which Tool to Use?

| **Scenario** | **Tool** | **Reasoning** |
|--------------|----------|---------------|
| Pre-flight check before rollback | `snapshot-validator.sh` | Verify safety before action |
| Standard failed migration | `rollback-runner.sh` | Controlled, full restoration |
| System won't boot after migration | `grub-repair.sh` | GRUB corruption likely |
| Network unavailable post-migration | `network-recovery.sh` | NIC config issue |
| Services disabled/broken | `service-restore.py` | systemd state corrupted |
| **Production down / SEV-1** | `emergency-rollback.sh` | **Speed > validation** |

---

## 📊 Rollback Success Criteria

| **Check** | **Expected State** | **Validation** |
|-----------|-------------------|----------------|
| 🟢 Boot Status | System boots to login prompt | `systemctl is-system-running` |
| 🟢 Network | Default route & DNS functional | `ping -c3 8.8.8.8` |
| 🟢 Services | Critical services running | `systemctl status <service>` |
| 🟢 RHEL Version | Confirmed RHEL7 kernel | `uname -r` shows `.el7.` |
| 🟢 Snapshot | Pre-migration snapshot retained | Snapshot files exist |

---

## ⚠️ Safety & Guardrails

| **Protection** | **Implementation** | **Override** |
|----------------|-------------------|--------------|
| **Snapshot Verification** | Hash validation before restore | `--force` flag (dangerous) |
| **Pre-rollback Backup** | Creates rollback-of-rollback snapshot | Always enabled |
| **Service Stop** | Graceful shutdown of critical services | 30s timeout → SIGKILL |
| **Boot Validation** | Verifies GRUB config post-repair | Auto-revert on failure |
| **Audit Logging** | All actions logged to `/var/log/rollback.log` | Cannot be disabled |

---

## 🔗 Integration Points
```mermaid
graph LR
    A[🔍 snapshot-validator.sh] -->|Verified| B[⏪ rollback-runner.sh]
    B --> C[🛠️ grub-repair.sh]
    B --> D[🌐 network-recovery.sh]
    B --> E[🔧 service-restore.py]
    
    F[🚨 emergency-rollback.sh] -.->|Bypasses| A
    F --> C
    F --> D
    F --> E
    
    C --> G[📊 Health Check]
    D --> G
    E --> G
    
    G -->|✅ Pass| H[✓ Rollback Complete]
    G -->|❌ Fail| I[⚠️ Manual Intervention Required]
    
    style A fill:#4fc3f7,stroke:#0288d1,color:#000
    style B fill:#ffb74d,stroke:#f57c00,color:#000
    style C fill:#ba68c8,stroke:#7b1fa2,color:#fff
    style D fill:#81c784,stroke:#388e3c,color:#000
    style E fill:#fff59d,stroke:#f9a825,color:#000
    style F fill:#ef5350,stroke:#c62828,color:#fff
    style G fill:#90caf9,stroke:#1976d2,color:#000
    style H fill:#66bb6a,stroke:#2e7d32,color:#fff
    style I fill:#ff8a65,stroke:#d84315,color:#fff
```

---

## 🎨 Color Legend

| **Color** | **Meaning** | **Components** |
|-----------|-------------|----------------|
| 🔵 **Blue** | Validation & Pre-flight | snapshot-validator.sh |
| 🟠 **Orange** | Core Rollback Operations | rollback-runner.sh |
| 🟣 **Purple** | Boot & GRUB Recovery | grub-repair.sh |
| 🟢 **Green** | Network Recovery | network-recovery.sh |
| 🟡 **Yellow** | Service Restoration | service-restore.py |
| 🔴 **Red** | Emergency Paths | emergency-rollback.sh |

---

## 📝 Notes

- **Always validate snapshots** before rollback unless P1/SEV-1
- **Emergency rollback** bypasses safety checks — use only in production incidents
- **All operations are logged** to `/var/log/rollback.log` for audit compliance
- **Rollback does not delete RHEL8 artifacts** — migration can be re-attempted
- **Network recovery** requires backed-up configs in `/backup/network/`

---

*Last Updated: 2026-01-02 | Maintained by: Platform Engineering*
