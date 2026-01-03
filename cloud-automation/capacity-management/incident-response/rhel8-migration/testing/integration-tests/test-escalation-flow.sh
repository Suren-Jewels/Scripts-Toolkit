#!/usr/bin/env bash
# Capability: Test PagerDuty/Slack escalation integration.

set -euo pipefail

echo "=== Testing Escalation Flow ==="

PD_ENDPOINT="${PAGERDUTY_WEBHOOK:?Missing PAGERDUTY_WEBHOOK}"
SLACK_ENDPOINT="${SLACK_WEBHOOK:?Missing SLACK_WEBHOOK}"

curl -s -X POST -H "Content-Type: application/json" \
    -d '{"event":"test","severity":"info"}' "$PD_ENDPOINT" \
    && echo "[OK] PagerDuty test event sent" \
    || { echo "[FAIL] PagerDuty test failed"; exit 1; }

curl -s -X POST -H "Content-Type: application/json" \
    -d '{"text":"Test escalation event"}' "$SLACK_ENDPOINT" \
    && echo "[OK] Slack test event sent" \
    || { echo "[FAIL] Slack test failed"; exit 1; }

echo "[ESCALATION FLOW TEST PASSED]"
