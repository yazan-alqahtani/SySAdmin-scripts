#!/bin/bash

# Terraform Deployment Script
# Author: yazan-alqahtani
# Description: Automates Terraform workflows including init, validate, plan, apply, and destroy.

# Configuration
TF_DIR="./terraform"
BACKUP_DIR="./terraform-backups"
ACTION="plan"
VAR_FILE=""
AUTO_APPROVE=0  # Set to 1 for automatic approval of apply/destroy

# Functions
log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

check_command() {
  command -v "$1" > /dev/null 2>&1 || { echo "Error: '$1' command not found."; exit 1; }
}

backup_state() {
  mkdir -p "$BACKUP_DIR"
  if [[ -f "$TF_DIR/terraform.tfstate" ]]; then
    cp "$TF_DIR/terraform.tfstate" "$BACKUP_DIR/terraform.tfstate.$(date +'%Y%m%d%H%M%S')"
    log_message "Terraform state backed up to $BACKUP_DIR."
  fi
}

terraform_action() {
  local action=$1
  log_message "Starting Terraform $action..."

  case $action in
    init)
      terraform -chdir="$TF_DIR" init ;;
    validate)
      terraform -chdir="$TF_DIR" validate ;;
    plan)
      if [[ -n $VAR_FILE ]]; then
        terraform -chdir="$TF_DIR" plan -var-file="$VAR_FILE"
      else
        terraform -chdir="$TF_DIR" plan
      fi
      ;;
    apply)
      if [[ -n $VAR_FILE ]]; then
        terraform -chdir="$TF_DIR" apply $( [[ $AUTO_APPROVE -eq 1 ]] && echo "-auto-approve" ) -var-file="$VAR_FILE"
      else
        terraform -chdir="$TF_DIR" apply $( [[ $AUTO_APPROVE -eq 1 ]] && echo "-auto-approve" )
      fi
      ;;
    destroy)
      terraform -chdir="$TF_DIR" destroy $( [[ $AUTO_APPROVE -eq 1 ]] && echo "-auto-approve" )
      ;;
    *)
      log_message "Error: Unsupported action '$action'."
      exit 1
      ;;
  esac

  if [[ $? -eq 0 ]]; then
    log_message "Terraform $action completed successfully."
  else
    log_message "Error: Terraform $action failed."
    exit 1
  fi
}

# Usage
usage() {
  echo "Usage: $0 -a [init|validate|plan|apply|destroy] [-d TF_DIR] [-v VAR_FILE] [-y]"
  echo "Options:"
  echo "  -a ACTION     Terraform action to perform (default: plan)."
  echo "  -d TF_DIR     Path to Terraform configuration directory (default: ./terraform)."
  echo "  -v VAR_FILE   Path to Terraform variables file."
  echo "  -y            Auto-approve apply/destroy actions."
  exit 1
}

# Parse arguments
while getopts "a:d:v:y" opt; do
  case $opt in
    a) ACTION=$OPTARG ;;
    d) TF_DIR=$OPTARG ;;
    v) VAR_FILE=$OPTARG ;;
    y) AUTO_APPROVE=1 ;;
    *) usage ;;
  esac
done

# Main Script
log_message "Terraform Deployment Script Started."
check_command "terraform"

if [[ ! -d $TF_DIR ]]; then
  log_message "Error: Terraform directory '$TF_DIR' not found."
  exit 1
fi

backup_state
terraform_action "$ACTION"

log_message "Terraform Deployment Script Completed."
exit 0
