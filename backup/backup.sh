#!/bin/bash
set -e

# Load AWS credentials
source /app/aws-credentials.env

# Variables
DATE=$(date +'%Y-%m-%d_%H-%M')
BACKUP_DIR="/app/backups/$DATE"
WEB_CONTAINER="web"        # name in docker-compose.yml
DB_CONTAINER="db"          # name in docker-compose.yml
DB_USER="root"
DB_PASSWORD="your_db_password"
DB_NAME="your_db_name"

mkdir -p $BACKUP_DIR

echo "🔹 Backing up website files..."
docker cp ${WEB_CONTAINER}:/usr/share/nginx/html $BACKUP_DIR/html

echo "🔹 Backing up MySQL database..."
docker exec ${DB_CONTAINER} /usr/bin/mysqldump -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > $BACKUP_DIR/db_backup.sql

echo "🔹 Compressing backup..."
tar -czf /app/backups/backup_${DATE}.tar.gz -C $BACKUP_DIR .

echo "🔹 Uploading to S3..."
aws s3 cp /app/backups/backup_${DATE}.tar.gz s3://${S3_BUCKET_NAME}/website_backups/

echo "✅ Backup completed: $DATE"
