#!/bin/bash
FTP_SERVER="ftp.taqatpay.com"
FTP_PORT="21"
FTP_USER="suliman_alzahrani"
FTP_PASS="MXv2dB212@Os"
FTP_DIR="/"
LOGFILE="/var/log/ftp_check.log"
EMAIL="it@taqatpay.com"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

function log {
    echo "$TIMESTAMP - $1" >> $LOGFILE
}

function send_email {
    local subject=$1
    local message=$2
    echo "$message" | mail -s "$subject" $EMAIL
}

log "Starting FTP service check..."

{
    ftp -inv $FTP_SERVER $FTP_PORT <<EOF
user $FTP_USER $FTP_PASS
cd $FTP_DIR
ls
bye
EOF
} &> $LOGFILE

if grep -q "Login successful" $LOGFILE && grep -q "226 Transfer complete" $LOGFILE; then
    log "FTP service check completed successfully."
    send_email "FTP Service Check Successful" "FTP service check completed successfully on $TIMESTAMP."
else
    log "FTP service check failed."
    send_email "FTP Service Check Failed" "FTP service check failed on $TIMESTAMP. Check the log file for details: $LOGFILE"
fi

log "FTP service check process completed."
