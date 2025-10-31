#!/bin/bash
set -e

source /app/aws-credentials.env

DATE=$(date +'%Y-%m-%d_%H-%M')
BACKUP_DIR="/app/backups/$DATE"

# container names from docker-compose.yml
WEB_CONTAINER="wordpress"
DB_CONTAINER="db"

# MySQL credentials
DB_USER="root"
DB_PASSWORD="your_db_password"
DB_NAME="wordpress"

# create local backup dir
mkdir -p $BACKUP_DIR

echo "🔹 Backing up WordPress files..."
docker cp ${WEB_CONTAINER}:/var/www/html $BACKUP_DIR/html

echo "🔹 Dumping MySQL database..."
docker exec ${DB_CONTAINER} /usr/bin/mysqldump -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > $BACKUP_DIR/db_backup.sql

echo "🔹 Compressing backup..."
tar -czf /app/backups/wp_backup_${DATE}.tar.gz -C $BACKUP_DIR .

echo "🔹 Uploading to S3..."
aws s3 cp /app/backups/wp_backup_${DATE}.tar.gz s3://${S3_BUCKET_NAME}/wordpress_backups/

echo "✅ Backup complete for $DATE"
