#!/bin/bash

echo "==============================================="
echo "📦 Disk Usage Overview"
echo "==============================================="
df -h
echo ""

echo "==============================================="
echo "🧾 Ansible Backup Facts (/etc/ansible/facts.d/backup.fact)"
echo "==============================================="
cat /etc/ansible/facts.d/backup.fact 2>/dev/null || echo "No backup.fact found."
echo ""

echo "==============================================="
echo "🚨 Backup Errors (/etc/sensu/plugins/data/backup_errors.json)"
echo "==============================================="
cat /etc/sensu/plugins/data/backup_errors.json 2>/dev/null || echo "No backup_errors.json found."
echo ""

echo "==============================================="
echo "🔍 Duplicity Processes"
echo "==============================================="
ps aux | grep '[d]uplicity'
echo ""

echo "==============================================="
echo "📁 Root Directory Usage (Top-level folders)"
echo "==============================================="
du -shc /* 2>/dev/null | grep G
echo ""

echo "==============================================="
echo "📁 /var/ Directory Usage"
echo "==============================================="
du -shc /var/* 2>/dev/null | grep G
echo ""

echo "==============================================="
echo "📁 Applications Directory Usage (/home/master/applications/)"
echo "==============================================="
du -shc /home/master/applications/* 2>/dev/null | grep G
echo ""
