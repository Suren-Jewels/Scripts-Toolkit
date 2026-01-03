# Rollback Decision Tree

## Step 1 — Identify Failure Type
- Boot failure  
- Network regression  
- Service failure  
- Application regression  

## Step 2 — Can Issue Be Fixed Forward?
- Minor config drift → Fix forward  
- Missing package → Fix forward  
- Kernel panic → Rollback  
- Bootloader corruption → Rollback  

## Step 3 — Time Sensitivity
- P1 incident → Immediate rollback  
- P2/P3 → Attempt fix forward first  

## Step 4 — Rollback Execution
- Validate snapshot  
- Trigger rollback workflow  
- Reboot and verify system health  

## Step 5 — Post‑Rollback Actions
- Document root cause  
- Update migration history  
- Schedule re‑attempt  
