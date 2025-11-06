#!/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/.env"

# Determine domain
if [ "$NGINX_DOMAIN_TYPE" = "domain" ]; then
  TARGET_DOMAIN="$NGINX_DOMAIN"
else
  TARGET_DOMAIN="$NGINX_SUB_DOMAIN"
fi

echo "🐳 Installing Docker and Docker Compose..."

# Remove old packages if exists
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt remove -y $pkg 2>/dev/null || true
done

# Add Docker's official GPG key:
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Allow user to run docker without sudo
sudo usermod -aG docker $USER

# Run docker nginx
docker run -d --name $TARGET_DOMAIN -p 8080:80 nginx:alpine

echo "✅ Docker & Compose installed successfully!"
docker --version
docker compose version
