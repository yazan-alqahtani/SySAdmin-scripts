#!/bin/bash

REPORT="/var/log/patch_report.txt"
ERRORLOG="/var/log/patch_error.log"
EMAIL="it@taqatpay.com"

function log {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $REPORT
}

function log_error {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $ERRORLOG
}

apt-get update -y
if [ $? -eq 0 ]; then
    log "Package list updated successfully."
else
    log_error "Failed to update package list."
    exit 1
fi

apt-get upgrade -y --with-new-pkgs
if [ $? -eq 0 ]; then
    log "System upgraded successfully."
else
    log_error "Failed to upgrade system."
    exit 1
fi

UPDATES=$(apt list --upgradable 2>/dev/null | grep -i security)
echo "Security updates installed:" > $REPORT
echo "$UPDATES" >> $REPORT

mail -s "Security Patch Report" $EMAIL < $REPORT

apt-get autoremove -y
if [ $? -eq 0 ]; then
    log "Unused packages removed successfully."
else
    log_error "Failed to remove unused packages."
    exit 1
fi
