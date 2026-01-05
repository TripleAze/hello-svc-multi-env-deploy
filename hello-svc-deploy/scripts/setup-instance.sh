#!/bin/bash
set -e

ENVIRONMENT="${environment}"
DOMAIN="${domain}"

echo "Setting up $ENVIRONMENT environment on $DOMAIN"

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Nginx
apt-get install -y nginx

# Install Certbot for Let's Encrypt (if SSL not already configured)
apt-get install -y certbot python3-certbot-nginx

# Create app directory
mkdir -p /opt/hello-svc
cd /opt/hello-svc

# Clone hello-svc repository
# Replace with your actual repo URL
git clone https://github.com/yourusername/hello-svc.git .

# Install CloudWatch agent for logs
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/$ENVIRONMENT-hello-svc",
            "log_stream_name": "nginx-access"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/$ENVIRONMENT-hello-svc",
            "log_stream_name": "nginx-error"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

echo "Setup complete for $ENVIRONMENT!"
echo "Next steps:"
echo "1. Update DNS to point $DOMAIN to this instance"
echo "2. Configure SSL certificate"
echo "3. Deploy application"
