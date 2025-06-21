#!/bin/bash

echo "🔄 Starting WordPress core reinstall..."

# Check if directory is empty
if [ -z "$(ls -A)" ]; then
  echo "🆕 Directory is already empty."
  echo "⬇️ Downloading fresh WordPress core..."
  
  if wp core download --allow-root; then
    echo "✅ WordPress core downloaded successfully."

    if [ -e ../private_html/wp-content ] && [ -e ../private_html/wp-config.php ]; then
      echo "🔁 Restoring wp-content and wp-config.php from backup..."
      mv ../private_html/wp-content ../private_html/wp-config.php ./ && \
      echo "✅ Restore complete." || echo "⚠️ Failed to restore files."
    else
      echo "ℹ️ No backup found in ../private_html/. Skipping restore."
    fi

    echo "🎉 Installation finished in empty directory."
    exit 0
  else
    echo "❌ wp core download failed."
    exit 1
  fi
fi

# Step 1: Move files to private_html
echo "📦 Moving wp-content and wp-config.php to ../private_html/..."
if mv wp-content wp-config.php ../private_html/; then
  echo "✅ Files moved."
else
  echo "❌ Move failed. Aborting to prevent data loss."
  exit 1
fi

# Step 2: Verify core checksums
echo "🛡️ Running wp core verify-checksums..."
wp core verify-checksums --allow-root | tee verify-checksums.log

echo -e "\n🔎 Suspicious files:"
wp core verify-checksums --allow-root \
| grep 'should not exist' \
| awk -F': ' '{print $2}' \
| tee suspicious-files.log

# Step 3: Show files
echo -e "\n📂 Current directory: $(pwd)"
ls -la

# Step 4: Confirm deletion
read -p $'\n⚠️  Do you want to delete all files in this directory with `rm -rf *`? [y/N]: ' confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "🧨 Deleting all files in $(pwd)..."
  rm -rf *
else
  echo "❌ Cancelled. No files were deleted."
  exit 1
fi

# Step 5: Re-download WP without wp-content
echo "⬇️ Downloading WordPress core without wp-content..."
if wp core download --skip-content --allow-root; then
  echo "✅ WordPress core downloaded."

  echo "🔁 Restoring wp-content and wp-config.php..."
  if mv ../private_html/wp-content ../private_html/wp-config.php ./; then
    echo "✅ Restore complete."
  else
    echo "⚠️ Restore failed. Please move files manually."
    exit 1
  fi

  echo "🎉 WordPress reinstall complete!"

else
  echo "❌ wp core download failed. Trying to restore files..."
  mv ../private_html/wp-content ../private_html/wp-config.php ./ 2>/dev/null
  echo "⚠️ Recovery attempted."
  exit 1
fi
