#!/bin/bash
set -e

ENVIRONMENT=$1
DOMAIN=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$DOMAIN" ]; then
  echo "Usage: ./deploy-app.sh <environment> <domain>"
  echo "Example: ./deploy-app.sh production production.yourdomain.com"
  exit 1
fi

echo "Deploying to $ENVIRONMENT ($DOMAIN)..."

# Build and start Docker container
cd /opt/hello-svc
export ENV=$ENVIRONMENT
docker-compose -f docker/docker-compose.yml up -d --build

# Configure Nginx
cat > /etc/nginx/sites-available/hello-svc <<EOF
# HTTP server - redirect to HTTPS
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        return 301 https://\$host\$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    # SSL Configuration - using existing certificates
    # If you have certificates in /etc/letsencrypt:
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # Or if you have custom certificates:
    # ssl_certificate /etc/ssl/certs/your-cert.pem;
    # ssl_certificate_key /etc/ssl/private/your-key.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Proxy to application
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/hello-svc /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx

echo "Deployment complete!"
echo "Application is now available at https://$DOMAIN"
