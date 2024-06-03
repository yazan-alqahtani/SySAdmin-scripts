#!/usr/bin/env python3

import subprocess
import smtplib
from email.mime.text import MIMEText
from datetime import datetime
import logging

DOMAINS = ["taqatpay.com", "ftp.taqatpay.com", "app.taqatpay.com", "www.taqatpay.com"]
EMAIL_FROM = "info@taqatpay.com"
EMAIL_TO = "it@taqatpay.com"
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SMTP_USER = "info@taqatpay.com"
SMTP_PASS = "6HNc9tKaxvlN3XUf"
LOG_FILE = "/var/log/ssl_renewal.log"

logging.basicConfig(filename=LOG_FILE, level=logging.INFO)

def send_email(subject, message):
    msg = MIMEText(message)
    msg['Subject'] = subject
    msg['From'] = EMAIL_FROM
    msg['To'] = EMAIL_TO

    with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
        server.starttls()
        server.login(SMTP_USER, SMTP_PASS)
        server.sendmail(EMAIL_FROM, EMAIL_TO, msg.as_string())

def renew_certificates():
    for domain in DOMAINS:
        try:
            command = f"certbot renew --cert-name {domain}"
            result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
            logging.info(f"Successfully renewed SSL certificate for {domain}: {result.stdout}")
            send_email("SSL Certificate Renewal Successful", f"Successfully renewed SSL certificate for {domain}.")
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to renew SSL certificate for {domain}: {str(e)}")
            send_email("SSL Certificate Renewal Failed", f"Failed to renew SSL certificate for {domain}: {str(e)}")

if __name__ == "__main__":
    renew_certificates()
