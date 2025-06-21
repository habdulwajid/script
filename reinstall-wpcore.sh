
wp core verify-checksums --allow-root 2>&1 \
| grep 'should not exist' \
| sed -E 's/^Warning: File should not exist: //' \
| while read -r file; do
  full_path="$(pwd)/$file"
  echo "🧹 Attempting to delete: $full_path"
  if [ -f "$full_path" ]; then
    if rm -f "$full_path"; then
      echo "✅ Deleted: $full_path"
    else
      echo "❌ Failed to delete: $full_path"
    fi
  else
    echo "⚠️ File not found: $full_path"
  fi
done
