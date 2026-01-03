#!/usr/bin/env bash
# Capability: Execute cutover plan in defined order.

set -euo pipefail

PLAN="cutover-plan.yaml"

echo "=== Executing Cutover Plan ==="

run_step() {
    local step="$1"
    echo "--- Running step: $step ---"

    case "$step" in
        pre-checks)
            ./pre-cutover-checklist.sh
            ;;
        freeze-window)
            echo "Entering freeze window..."
            ;;
        execute-migration)
            echo "Triggering migration workflow..."
            ;;
        post-validation)
            python3 post-cutover-validation.py
            ;;
        release)
            echo "Releasing systems from freeze window..."
            ;;
        *)
            echo "Unknown step: $step"
            exit 1
            ;;
    esac
}

steps=$(grep "step:" "$PLAN" | awk '{print $2}' | tr -d '"')

for s in $steps; do
    run_step "$s"
done

echo "=== Cutover Complete ==="
