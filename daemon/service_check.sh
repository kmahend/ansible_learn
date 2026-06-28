#!/bin/bash

echo "============================================="
echo "Daemon / Service Accounts Status Check"
echo "============================================="

# Get service/daemon accounts (UID < 1000, excluding root)
daemon_accounts=$(awk -F: '$3 < 1000 && $1 != "root" {print $1}' /etc/passwd)

for user in $daemon_accounts
do
    echo "---------------------------------------------"
    echo "User: $user"

    # Check account lock status
    status=$(passwd -S $user 2>/dev/null)
    echo "Account Status: $status"

    # Check shell
    shell=$(grep "^$user:" /etc/passwd | cut -d: -f7)
    echo "Login Shell: $shell"

    # Check if service account has login enabled
    if [[ "$shell" == "/sbin/nologin" || "$shell" == "/bin/false" ]]; then
        echo "Login: Disabled (Correct for service accounts)"
    else
        echo "Login: Enabled (Review Required)"
    fi

    # Check running processes
    ps_output=$(ps -u $user -o pid,cmd --no-headers 2>/dev/null | head -5)
    if [[ -n "$ps_output" ]]; then
        echo "Running Processes:"
        echo "$ps_output"
    else
        echo "Running Processes: None"
    fi

done

echo "============================================="
echo "Check Completed"
echo "============================================="
