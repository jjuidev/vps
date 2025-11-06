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

echo "🌐 Installing Nginx HTTP/HTTPS for: $TARGET_DOMAIN"

# Install Nginx and Certbot
sudo apt update -y
sudo apt install -y nginx certbot python3-certbot-nginx

sudo systemctl enable nginx
sudo systemctl start nginx

# Create default HTTP config (for Certbot verification)
NGINX_CONF="/etc/nginx/sites-available/$TARGET_DOMAIN"

echo "🧩 Creating Nginx HTTP config at: $NGINX_CONF"

sudo bash -c "cat > $NGINX_CONF" <<EOF
server {
  listen 80;
  listen [::]:80;
  server_name $TARGET_DOMAIN;
}
EOF

# Enable Nginx config
echo "🔗 Enabling $TARGET_DOMAIN site..."
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

if [ "$VPS_ENV" = "vps" ]; then
  # Request new SSL certificate
  if [ -d "/etc/letsencrypt/live/$TARGET_DOMAIN" ]; then
    echo "✅ SSL certificate already exists for $TARGET_DOMAIN, skipping certbot request."
  else
    echo "🔐 Requesting new SSL certificate for $TARGET_DOMAIN..."
    sudo certbot -d "$TARGET_DOMAIN" -m $CERTBOT_EMAIL --nginx --agree-tos --non-interactive
  fi
  sudo certbot renew --dry-run

  # Override nginx config to use SSL
  sudo bash -c "cat > $NGINX_CONF" <<EOF
  server {
    listen 80;
    listen [::]:80;
    server_name $TARGET_DOMAIN;

    location / {
      return 301 https://\$server_name\$request_uri;
    }
  }

  server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $TARGET_DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$TARGET_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$TARGET_DOMAIN/privkey.pem;

    location / {
      proxy_pass http://localhost:8080;
    }
  }
EOF
  sudo systemctl reload nginx
  echo "✅ Nginx HTTPS setup successfully!"
  echo "🌍 Visit: https://$TARGET_DOMAIN"
else
  echo "✅ Nginx HTTP setup successfully!"
  echo "🌍 Visit: http://$TARGET_DOMAIN"
fi
