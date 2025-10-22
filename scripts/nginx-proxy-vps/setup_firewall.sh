#!/bin/bash
set -e

echo "🛡️ Setting up UFW firewall..."

sudo apt install -y ufw

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

# Activate without confirmation
sudo ufw --force enable

sudo ufw status verbose
echo "✅ Firewall configured (22, 80, 443 open) successfully!"
