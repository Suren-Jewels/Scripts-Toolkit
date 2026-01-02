incident-orchestration/comms/
    -> email-notify.sh
    ->
#!/usr/bin/env bash
# Capability: Send incident notifications via email.
# Inputs:
#   EVENT_FILE   - JSON event payload
#   EMAIL_TO     - Recipient email address
#   EMAIL_FROM   - Sender email address
#   SUBJECT      - Email subject
#   SMTP_SERVER  - SMTP server address

set -euo pipefail

EVENT_FILE="${EVENT_FILE:-event.json}"
EMAIL_TO="${EMAIL_TO:?EMAIL_TO is required}"
EMAIL_FROM="${EMAIL_FROM:?EMAIL_FROM is required}"
SUBJECT="${SUBJECT:-Incident Notification}"
SMTP_SERVER="${SMTP_SERVER:?SMTP_SERVER is required}"

if [ ! -f "$EVENT_FILE" ]; then
    echo "EVENT_FILE not found: $EVENT_FILE" >&2
    exit 1
fi

payload=$(jq '.' "$EVENT_FILE")

email_body=$(cat <<EOF
To: ${EMAIL_TO}
From: ${EMAIL_FROM}
Subject: ${SUBJECT}

Incident Notification
Severity: ${SEVERITY:-UNKNOWN}

Event Payload:
${payload}
EOF
)

echo "$email_body" | sendmail -S "$SMTP_SERVER" -t

echo "Email notification sent to ${EMAIL_TO}"
