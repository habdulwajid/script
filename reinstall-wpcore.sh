#!/bin/bash

echo "🔄 Starting WordPress core reinstall safely..."

# Step 1: Move wp-content and wp-config.php to a backup location
echo "📦 Moving wp-content and wp-config.php to ../private_html/..."
if mv wp-content wp-config.php ../private_html/; then
  echo "✅ Successfully moved."
else
  echo "❌ Failed to move wp-content or wp-config.php. Aborting."
  exit 1
fi

# Step 2: Verify WordPress core checksums
echo "🛡️ Verifying WordPress core checksums..."
wp core verify-checksums --allow-root | tee verify-checksums.log

echo -e "\n🔎 Suspicious files that should NOT exist:"
wp core verify-checksums --allow-root \
  | grep 'should not exist' \
  | awk -F': ' '{print $2}' \
  | tee suspicious-files.log

# Step 3: Show current directory and list files
echo -e "\n📂 Current directory: $(pwd)"
ls -la

# Step 4: Prompt before wiping directory
read -p $'\n⚠️  Do you want to delete all files in this directory with `rm -rf *`? [y/N]: ' confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "🧨 Deleting all files in $(pwd)..."
  rm -rf *
else
  echo "❌ Action cancelled. No files were deleted. Exiting safely."
  exit 1
fi

# Step 5: Download fresh WordPress core (without wp-content)
echo "⬇️ Downloading fresh WordPress core (excluding wp-content)..."
if wp core download --skip-content --allow-root; then
  echo "✅ WordPress core downloaded."

  # Step 6: Restore wp-content and wp-config.php
  echo "🔁 Restoring wp-content and wp-config.php..."
  if mv ../private_html/wp-content ../private_html/wp-config.php ./; then
    echo "✅ Restore completed successfully."
  else
    echo "⚠️ Restore failed. Please move them manually from ../private_html/"
    exit 1
  fi

  echo "🎉 WordPress core reinstall complete!"

else
  echo "❌ Download failed. Attempting to restore original files..."
  mv ../private_html/wp-content ../private_html/wp-config.php ./ 2>/dev/null
  echo "⚠️ Core not refreshed. Backup restored if possible."
  exit 1
fi
