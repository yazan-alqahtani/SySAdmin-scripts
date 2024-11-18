#!/bin/bash

# System Update Script
# Author: yazan-alqahtani
# Description: Automatically updates the system packages and cleans up unnecessary files.

# Configuration
LOG_FILE="/var/log/system-update.log"
DRY_RUN=0                             # Set to 1 to simulate updates without applying them

# Functions
log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_message "Error: This script must be run as root."
    exit 1
  fi
}

detect_package_manager() {
  if command -v apt > /dev/null 2>&1; then
    echo "apt"
  elif command -v yum > /dev/null 2>&1; then
    echo "yum"
  elif command -v dnf > /dev/null 2>&1; then
    echo "dnf"
  elif command -v zypper > /dev/null 2>&1; then
    echo "zypper"
  else
    log_message "Error: No supported package manager found."
    exit 1
  fi
}

update_system() {
  local pm=$1
  case $pm in
    apt)
      log_message "Using APT package manager."
      [[ $DRY_RUN -eq 1 ]] && log_message "Simulating updates..." && apt update || { apt update && apt upgrade -y; }
      apt autoremove -y && apt clean
      ;;
    yum)
      log_message "Using YUM package manager."
      [[ $DRY_RUN -eq 1 ]] && log_message "Simulating updates..." || yum update -y
      yum autoremove -y && yum clean all
      ;;
    dnf)
      log_message "Using DNF package manager."
      [[ $DRY_RUN -eq 1 ]] && log_message "Simulating updates..." || dnf upgrade --refresh -y
      dnf autoremove -y && dnf clean all
      ;;
    zypper)
      log_message "Using Zypper package manager."
      [[ $DRY_RUN -eq 1 ]] && log_message "Simulating updates..." || zypper refresh && zypper update -y
      zypper clean
      ;;
    *)
      log_message "Error: Unsupported package manager."
      exit 1
      ;;
  esac
}

# Main Script
check_root

log_message "Starting system update process..."
PACKAGE_MANAGER=$(detect_package_manager)
log_message "Detected package manager: $PACKAGE_MANAGER"

update_system "$PACKAGE_MANAGER"

log_message "System update process completed successfully."
exit 0
