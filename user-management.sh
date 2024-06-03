#!/bin/bash

LOGFILE="/var/log/user_management.log"
ERRORLOG="/var/log/user_management_error.log"

function log {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

function log_error {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $ERRORLOG
}

if [ $# -ne 2 ]; then
    echo "Usage: $0 username group"
    log_error "Invalid arguments supplied."
    exit 1
fi

USERNAME=$1
GROUP=$2

if ! getent group $GROUP >/dev/null; then
    groupadd $GROUP
    if [ $? -ne 0 ]; then
        log_error "Failed to create group $GROUP."
        exit 1
    fi
    log "Group $GROUP created."
fi

useradd -m -G $GROUP $USERNAME
if [ $? -eq 0 ]; then
    log "User $USERNAME created and added to group $GROUP."
    echo "User $USERNAME created and added to group $GROUP."
else
    log_error "Failed to create user $USERNAME or add to group $GROUP."
    exit 1
fi
