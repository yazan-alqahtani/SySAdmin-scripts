#!/usr/bin/env python3

import os
import smtplib
import tarfile
from email.mime.text import MIMEText
from datetime import datetime
import logging

SOURCE_DIR = "/u01"
BACKUP_DIR = "/backup/weblogic"
EMAIL_FROM = "info@taqatpay.com"
EMAIL_TO = "it@taqatpay.com"
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SMTP_USER = "info@taqatpay.com"
SMTP_PASS = "6HNc9tKaxvlN3XUf"

logging.basicConfig(filename='/var/log/backup.log', level=logging.INFO)

def send_email(subject, message):
    msg = MIMEText(message)
    msg['Subject'] = subject
    msg['From'] = EMAIL_FROM
    msg['To'] = EMAIL_TO

    with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
        server.starttls()
        server.login(SMTP_USER, SMTP_PASS)
        server.sendmail(EMAIL_FROM, EMAIL_TO, msg.as_string())

def create_backup():
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    backup_file = os.path.join(BACKUP_DIR, f"backup_{timestamp}.tar.gz")

    try:
        with tarfile.open(backup_file, "w:gz") as tar:
            tar.add(SOURCE_DIR, arcname=os.path.basename(SOURCE_DIR))
        logging.info(f"Backup created: {backup_file}")
        send_email("Backup Successful", f"Backup created successfully: {backup_file}")
    except Exception as e:
        logging.error(f"Backup failed: {str(e)}")
        send_email("Backup Failed", f"Backup failed: {str(e)}")

if __name__ == "__main__":
    create_backup()
