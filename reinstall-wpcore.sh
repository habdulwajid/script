#!/bin/bash

echo "🔄 Starting WordPress core reset with checksum validation and confirmation..."

# Step 1: Move wp-content and wp-config.php to safe location
echo "📦 Moving wp-content and wp-config.php to ../private_html/..."
if mv wp-content wp-config.php ../private_html/; then
  echo "✅ Files moved successfully."
else
  echo "❌ Failed to move wp-content or wp-config.php. Aborting to prevent data loss."
  exit 1
fi

# Step 2: Verify WordPress core files
echo -e "\n🛡️ Running wp core verify-checksums..."
wp core verify-checksums --allow-root | tee verify-checksums.log

# Show only suspicious files (optional: clean them later)
echo -e "\n🔎 Suspicious files that should not exist:"
wp core verify-checksums --allow-root \
| grep 'should not exist' \
| awk -F': ' '{print $2}' \
| tee suspicious-files.log

# Step 3: Show current path and contents
echo -e "\n📂 Current path: $(pwd)"
echo -e "📄 Listing contents:\n"
ls -la

# Step 4: Ask for confirmation before deleting all files
read -p $'\n⚠️  Do you want to run `rm -rf *` to wipe the directory? [y/N]: ' confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "🧨 Deleting all files in $(pwd)..."
  rm -rf *
else
  echo "❌ Aborted. No files were deleted. Exiting safely."
  exit 1
fi

# Step 5: Download WordPress core without wp-content
echo "⬇️ Downloading fresh WordPress core (excluding wp-content)..."
if wp core download --skip-content --allow-root; then
  echo "✅ WordPress core downloaded."

  # Step 6: Restore original wp-content and wp-config.php
  echo "🔁 Restoring original wp-content and wp-config.php..."
  if mv ../private_html/wp-content ../private_html/wp-config.php ./; then
    echo "✅ Restoration complete. You're all set!"
  else
    echo "⚠️ Failed to restore files. Please move them back manually from ../private_html/"
    exit 1
  fi
else
  echo "❌ WordPress download failed. Attempting to restore original files..."
  mv ../private_html/wp-content ../private_html/wp-config.php ./ 2>/dev/null
  echo "⚠️ Core not refreshed. Backup restored (if possible)."
  exit 1
fi
