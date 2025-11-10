#!/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/.env"

# Determine domain and base domain
if [ "$NGINX_DOMAIN_TYPE" = "domain" ]; then
  TARGET_DOMAIN="$NGINX_DOMAIN"
else
  TARGET_DOMAIN="$NGINX_SUB_DOMAIN"
fi

echo "🌐 Installing Nginx HTTP/HTTPS for: $TARGET_DOMAIN"

# Install Nginx and Certbot
sudo apt update -y
sudo apt install -y nginx certbot python3-certbot-nginx python3-certbot-dns-cloudflare

sudo systemctl enable nginx
sudo systemctl start nginx

# Create default HTTP config (for Certbot verification)
NGINX_CONF="/etc/nginx/sites-available/$TARGET_DOMAIN.nginx.conf"
SSL_CERT_DIR="/etc/letsencrypt/live/$NGINX_DOMAIN"

if [ ! -f "$NGINX_CONF" ]; then
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
  sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
else
  echo "✅ Nginx config already exists for $TARGET_DOMAIN"
fi

if [ ! -d "$SSL_CERT_DIR" ]; then
  echo "🔐 Requesting new SSL certificate for: $NGINX_DOMAIN..."

  if [ "$NGINX_DOMAIN_TYPE" = "domain" ]; then
    sudo certbot certonly --dns-cloudflare --dns-cloudflare-propagation-seconds 60 --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -d $NGINX_DOMAIN -d *.$NGINX_DOMAIN --email $CERTBOT_EMAIL --agree-tos --non-interactive
  else
    sudo certbot certonly --dns-cloudflare --dns-cloudflare-propagation-seconds 60 --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -d *.$NGINX_DOMAIN -d *.$NGINX_SUB_DOMAIN --email $CERTBOT_EMAIL --agree-tos --non-interactive
  fi
  sudo certbot renew --dry-run

  # Update nginx config to use SSL (using base domain certificate for subdomains)
  echo "🔧 Updating Nginx config to use SSL..."
  sudo bash -c "cat > $NGINX_CONF" <<EOF
# Define a map to handle WebSocket connections
map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}

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

  ssl_certificate $SSL_CERT_DIR/fullchain.pem;
  ssl_certificate_key $SSL_CERT_DIR/privkey.pem;

  # Common proxy headers
  proxy_set_header Host $http_host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header Upgrade $http_upgrade;

  # WebSocket specific proxy headers
  proxy_http_version 1.1;
  proxy_ssl_server_name on;
  proxy_set_header Connection $connection_upgrade;
  proxy_buffering off;
  proxy_read_timeout 3600s;

  location / {
    proxy_pass http://localhost:8080;
  }
}
EOF

  sudo systemctl reload nginx
  echo "✅ Nginx HTTPS setup successfully!"
  echo "🌍 Visit: https://$TARGET_DOMAIN"
fi

sudo nginx -t
sudo systemctl reload nginx