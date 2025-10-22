#!/bin/bash
set -e

echo "🚀 VPS Nginx-Proxy Bootstrap Script — Initial Setup"
echo "----------------------------------------"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$BASE_DIR/update_system.sh"
bash "$BASE_DIR/install_docker.sh"
bash "$BASE_DIR/install_nginx_certbot.sh"
bash "$BASE_DIR/setup_firewall.sh"
bash "$BASE_DIR/install_zsh.sh"

echo "✅ Setup complete!"
