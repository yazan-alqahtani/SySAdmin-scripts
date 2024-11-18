#!/bin/bash

# Database Backup Script
# Author: yazan-alqahtani
# Description: Backs up a MySQL or PostgreSQL database and stores the backup with timestamped filenames.

BACKUP_DIR="/var/db-backups/"
RETENTION_DAYS=7

DB_TYPE="postgres"
DB_NAME="db"
DB_USER="postgres"
DB_PASS="5DXPvm0gvzZPj92l"
DB_HOST="localhost"
DB_PORT="5432"

# Usage
function usage() {
  echo "Usage: $0 -t [mysql|postgres] -n DB_NAME -u DB_USER -p DB_PASS [-h DB_HOST] [-P DB_PORT]"
  exit 1
}

# Parse arguments
while getopts "t:n:u:p:h:P:" opt; do
  case $opt in
    t) DB_TYPE=$OPTARG ;;
    n) DB_NAME=$OPTARG ;;
    u) DB_USER=$OPTARG ;;
    p) DB_PASS=$OPTARG ;;
    h) DB_HOST=$OPTARG ;;
    P) DB_PORT=$OPTARG ;;
    *) usage ;;
  esac
done

# Validate arguments
if [[ -z $DB_TYPE || -z $DB_NAME || -z $DB_USER || -z $DB_PASS ]]; then
  echo "Error: Missing required arguments."
  usage
fi

# Set default ports if not provided
if [[ $DB_TYPE == "mysql" ]]; then
  DB_PORT=${DB_PORT:-3306}
elif [[ $DB_TYPE == "postgres" ]]; then
  DB_PORT=${DB_PORT:-5432}
else
  echo "Error: Unsupported database type '$DB_TYPE'."
  usage
fi

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR" || { echo "Error: Unable to create backup directory '$BACKUP_DIR'."; exit 1; }

# Generate timestamp
TIMESTAMP=$(date +'%Y%m%d%H%M%S')
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_${TIMESTAMP}.sql"

# Backup function
function backup_mysql() {
  echo "Starting MySQL backup for database '$DB_NAME'..."
  mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "MySQL backup completed: $BACKUP_FILE"
  else
    echo "Error: MySQL backup failed."
    exit 1
  fi
}

function backup_postgres() {
  echo "Starting PostgreSQL backup for database '$DB_NAME'..."
  PGPASSWORD="$DB_PASS" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "PostgreSQL backup completed: $BACKUP_FILE"
  else
    echo "Error: PostgreSQL backup failed."
    exit 1
  fi
}

# Perform backup
case $DB_TYPE in
  mysql) backup_mysql ;;
  postgres) backup_postgres ;;
  *) echo "Error: Unsupported database type."; exit 1 ;;
esac

# Cleanup old backups
echo "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -name "${DB_NAME}_backup_*.sql" -mtime +$RETENTION_DAYS -exec rm -f {} \;
echo "Cleanup completed."

echo "Database backup process finished."
exit 0