# Emergency Response Guide (P1 Migration Incidents)

## 1. Declare Incident
- Assign Incident Commander  
- Notify SRE + Platform teams  
- Start incident bridge  

## 2. Stabilize System
- Stop failing services  
- Capture logs and metrics  
- Prevent cascading failures  

## 3. Determine Recovery Path
- Fix forward if safe  
- Rollback if system unstable  
- Trigger emergency rollback workflow if required  

## 4. Validate Recovery
- Confirm systemd health  
- Validate network  
- Confirm application availability  

## 5. Communicate
- Provide updates every 15 minutes  
- Notify stakeholders when stable  
- Document timeline  

## 6. Close Incident
- Update incident ticket  
- Trigger post‑mortem process  
