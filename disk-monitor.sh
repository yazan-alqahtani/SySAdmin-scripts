#!/bin/bash

THRESHOLD=80
EMAIL="it@taqatpay.com"
LOGFILE="/var/log/disk_cleanup.log"

function log {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

function send_email {
    local subject=$1
    local message=$2
    echo "$message" | mail -s "$subject" $EMAIL
}

DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

log "Disk usage: $DISK_USAGE%"

if [ $DISK_USAGE -gt $THRESHOLD ]; then
    log "Disk usage exceeds threshold of $THRESHOLD%. Starting cleanup."
    
    rm -rf /tmp/*
    if [ $? -eq 0 ]; then
        log "Temporary files cleaned up."
    else
        log "Failed to clean up temporary files."
    fi
    
    DISK_USAGE_AFTER=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
    log "Disk usage after cleanup: $DISK_USAGE_AFTER%"
    
    send_email "Disk Usage Alert" "Disk usage exceeded $THRESHOLD%. Current usage: $DISK_USAGE_AFTER%"
else
    log "Disk usage is within the threshold."
fi
