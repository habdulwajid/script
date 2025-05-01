#!/bin/bash

for site in /etc/nginx/sites-available/*; do
    app_name=$(basename "$site")
    wp_path="/home/master/applications/$app_name/public_html/wp-content"

    if [ -d "$wp_path" ]; then
        echo "Disk usage for: $app_name (wp-content)"
        echo "---------------------------------------"
        (cd "$wp_path" && du -shc ./* | grep G 2>/dev/null)
        echo ""
    else
        echo "wp-content not found for: $app_name"
        echo ""
    fi
done
