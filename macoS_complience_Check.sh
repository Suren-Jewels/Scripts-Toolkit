#!/bin/bash

# macOS Compliance Check Script for IL4/IL5 Environments
# Author: Suren Jewels

echo "🔒 Starting macOS compliance check..."

# Check for FileVault encryption
fv_status=$(fdesetup status)
if [[ $fv_status == *"FileVault is On."* ]]; then
    echo "✅ FileVault encryption: ENABLED"
else
    echo "❌ FileVault encryption: DISABLED"
fi

# Check for Jamf enrollment
jamf_status=$(jamf checkEnrollment)
if [[ $jamf_status == *"Computer is enrolled"* ]]; then
    echo "✅ Jamf enrollment: VERIFIED"
else
    echo "❌ Jamf enrollment: MISSING"
fi

# Check for CrowdStrike agent
if pgrep -x "falconctl" > /dev/null; then
    echo "✅ CrowdStrike agent: RUNNING"
else
    echo "❌ CrowdStrike agent: NOT FOUND"
fi

# Check for password policy
pw_policy=$(pwpolicy getaccountpolicies)
if [[ $pw_policy == *"minChars"* ]]; then
    echo "✅ Password policy: ENFORCED"
else
    echo "❌ Password policy: NOT SET"
fi

echo "🔍 Compliance check complete."