#!/bin/bash

APPLICATIONS_PATH="/home/master/applications"
cd "$APPLICATIONS_PATH" || exit

echo "Starting backup process for all applications..."

# Loop through each app name from nginx config symlinks
for i in $(ls /etc/nginx/sites-available); do
    APP_PATH="$APPLICATIONS_PATH/$i"
    PRIVATE_HTML="$APP_PATH/private_html"

    echo "--------------------------------------------------"
    echo "Processing app: $i"
    echo "Navigating to: $PRIVATE_HTML"

    cd "$PRIVATE_HTML" || { echo "❌ Failed to access $PRIVATE_HTML. Skipping..."; continue; }

    echo "📦 Dumping database: $i-db.sql"
    mysqldump "$i" > "$i-db.sql"

    echo "🗜️  Creating backup zip: $i-backup.zip (includes DB + public_html)"
    zip -rq "$i-backup.zip" "$i-db.sql" ../public_html

    echo "🧹 Cleaning up SQL dump: $i-db.sql"
    rm -f "$i-db.sql"

    echo "✅ Backup completed for: $i"
    echo

    # Return to applications directory for next loop
    cd "$APPLICATIONS_PATH" || exit
done

echo "🚀 All application backups completed."
