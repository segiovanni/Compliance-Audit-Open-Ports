#!/bin/bash
# Script to audit open ports on macOS

# Log file for output
LOG_FILE="$HOME/open_ports_audit_$(date +%Y%m%d_%H%M%S).txt"

# Header for readability
echo "Open Ports Audit - $(date)" | tee "$LOG_FILE"
echo "--------------------------------" | tee -a "$LOG_FILE"

# Check if lsof is available (should be built-in on macOS)
if ! command -v lsof &> /dev/null; then
    echo "Error: lsof not found. Please install it or use an alternative method." | tee -a "$LOG_FILE"
    exit 1
fi

# List all open ports (TCP and UDP) with process info
echo "Listing all open TCP and UDP ports..." | tee -a "$LOG_FILE"
lsof -i -P -n | grep LISTEN | awk '{print $1, $2, $8, $9}' | sort -u | tee -a "$LOG_FILE"

# Explanation of columns:
# $1 = Command, $2 = PID, $8 = Protocol (e.g., TCP), $9 = Address:Port (e.g., *:22)

# Optional: Highlight common risky ports (e.g., 22=SSH, 80=HTTP, 445=SMB)
echo -e "\nChecking for commonly exploited ports..." | tee -a "$LOG_FILE"
for PORT in 22 23 80 445 3389; do
    if lsof -i :"$PORT" | grep LISTEN > /dev/null; then
        echo "WARNING: Port $PORT is open!" | tee -a "$LOG_FILE"
    fi
done

echo "Audit complete. Results saved to $LOG_FILE"