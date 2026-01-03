# 🔐 DB Encryption Authority

Unified validation toolkit for **DARE**, **Clotho**, and **AES** encryption systems governing DB servers.

This module provides **mixed‑language, atomic scripts** to validate:

- Key metadata
- Encryption/decryption correctness
- Workflow state
- Audit trails
- PostgreSQL encryption alignment
- Cross‑authority consistency

Designed for **DBserver ↔ Encryption Authority** ecosystems where multiple encryption systems coexist.

---

## 🧭 Structure Overview

| System | Purpose | Icon |
|--------|---------|------|
| **DARE** | Data‑At‑Rest Encryption authority | 🔒 |
| **Clotho** | Encryption workflow & metadata orchestration | 🧬 |
| **AES** | Application/service‑level encryption | ⚡ |
| **Unified Tools** | Cross‑authority correlation & health | 🧩 |

---

## 📁 Directory Layout

```
db-encryption-authority/
  dare/
  clotho/
  aes/
  encryption-authority-matrix.py
  encryption-authority-health.sh
```

Each subfolder contains **atomic, capability‑centric scripts** aligned to the same pattern.

---

## 🔒 DARE — Data‑At‑Rest Encryption  
**Folder:** `dare/`  
**Icon:** 🔒

| Script | Type | Purpose |
|--------|------|---------|
| [dare-key-metadata.py](dare/dare-key-metadata.py) | Python | Fetch DARE key metadata |
| [dare-encryption-test.sh](dare/dare-encryption-test.sh) | Bash | Round‑trip encryption test |
| [dare-audit-log-query.py](dare/dare-audit-log-query.py) | Python | Retrieve DARE audit logs |
| [dare-postgres-check.sql](dare/dare-postgres-check.sql) | SQL | Validate PostgreSQL encryption state |

---

## 🧬 Clotho — Encryption Workflow Orchestration  
**Folder:** `clotho/`  
**Icon:** 🧬

| Script | Type | Purpose |
|--------|------|---------|
| [clotho-encryption-workflow.py](clotho/clotho-encryption-workflow.py) | Python | Retrieve workflow state |
| [clotho-key-association.sql](clotho/clotho-key-association.sql) | SQL | Validate key association |
| [clotho-postgres-check.sql](clotho/clotho-postgres-check.sql) | SQL | Validate DB ↔ Clotho metadata |

---

## ⚡ AES — Application‑Level Encryption  
**Folder:** `aes/`  
**Icon:** ⚡

| Script | Type | Purpose |
|--------|------|---------|
| [aes-key-validation.py](aes/aes-key-validation.py) | Python | Fetch AES key metadata |
| [aes-encryption-test.sh](aes/aes-encryption-test.sh) | Bash | Round‑trip AES encryption test |
| [aes-postgres-check.sql](aes/aes-postgres-check.sql) | SQL | Validate PostgreSQL encryption alignment |

---

## 🧩 Unified Encryption Tools  
**Folder:** `db-encryption-authority/`  
**Icon:** 🧩

| Script | Type | Purpose |
|--------|------|---------|
| [encryption-authority-matrix.py](encryption-authority-matrix.py) | Python | Consolidated DARE/Clotho/AES matrix |
| [encryption-authority-health.sh](encryption-authority-health.sh) | Bash | Unified health check |

---

## 🏁 Purpose of This Module

This module ensures that **all encryption authorities governing a DB server** are:

- Healthy  
- Consistent  
- Correctly configured  
- Using the right keys  
- Reporting accurate metadata  
- Aligned with PostgreSQL encryption state  

It provides a **single source of truth** for encryption validation across multiple systems.

