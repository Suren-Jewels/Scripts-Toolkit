# 📄 CUI Handling Procedures (Synthetic Example)

> This document provides **synthetic** example guidance for handling Controlled Unclassified Information (CUI) in IL4/IL5 environments.

---

## 1. Identification

- **Labeling:** All CUI must be clearly labeled in headers/footers and system metadata.
- **Classification tooling:** Use `cui-data-classifier.py` to support detection and tagging of potential CUI content.
- **Separation:** Store CUI only in approved IL4/IL5 enclaves and repositories.

---

## 2. Access Control

- **Need‑to‑know:** Grant access only to authorized personnel with a valid mission need.
- **MFA:** Enforce multi‑factor authentication for all CUI access (see `mfa-enforcement-audit.ps1`).
- **RBAC:** Use role‑based access and audit high‑risk roles with `access-control-audit.py`.

---

## 3. Storage and Transmission

- **Encryption at rest:** Ensure storage uses approved encryption mechanisms (validated using `encryption-validator.sh`).
- **Encryption in transit:** Require TLS with approved cipher suites for all CUI traffic.
- **Backups:** Include CUI in encrypted backups where required by policy.

---

## 4. Handling and Use

- **Approved devices:** Access CUI only from managed, posture‑validated devices (`il-posture-validator.py`).
- **Screen and print control:** Avoid unauthorized printing; control screen sharing and remote access.
- **Data minimization:** Store only the minimum CUI necessary for the mission.

---

## 5. Logging and Monitoring

- **Audit trails:** Enable logging for all CUI access and administrative actions.
- **Review cadence:** Review access logs on a regular schedule and investigate anomalies.
- **Incident handling:** Follow organizational incident response processes for suspected CUI compromise.

---

## 6. Disposal

- **Secure deletion:** Use approved methods to sanitize media containing CUI.
- **Retention:** Follow organizational retention rules for CUI records.
- **Verification:** Confirm destruction or sanitization is complete and documented.
