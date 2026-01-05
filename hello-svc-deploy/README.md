# Hello-SVC Deployment with Custom Domain & SSL (Single Server)

## Architecture Overview

This deployment uses **a single EC2 server**. The application environment (**production or staging**) is controlled via an **environment variable**, not separate servers.

```
┌─────────────────────────────────────────────────────────────────┐
│                         Your Domain                              │
│                    (yourdomain.com with SSL)                     │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ DNS A Record
                            │
                            ▼
                   ┌───────────────────┐
                   │   EC2 Instance    │
                   │   Single Server   │
                   │   52.23.45.67     │
                   │                   │
                   │  ┌─────────────┐  │
                   │  │   Nginx     │  │
                   │  │ (SSL:443)   │  │
                   │  │ (HTTP:80)   │  │
                   │  └──────┬──────┘  │
                   │         │         │
                   │         ▼         │
                   │  ┌─────────────┐  │
                   │  │  hello-svc  │  │
                   │  │  (Docker)   │  │
                   │  │  ENV=prod   │  │
                   │  │  or ENV=stg │  │
                   │  │  Port 8080  │  │
                   │  └─────────────┘  │
                   └───────────────────┘
```

---

## Project Structure

```
hello-svc-deploy/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── scripts/
│   ├── setup-instance.sh
│   └── deploy-app.sh
├── nginx/
│   └── nginx.conf.template
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── hello-svc/
│   ├── main.go
│   └── go.mod
└── README.md
```

---

## Prerequisites

* Domain configured and pointing to the EC2 instance (e.g., `yourdomain.com`)
* SSL certificate installed via Let’s Encrypt (Certbot)
* AWS account with credentials configured
* Terraform installed locally
* SSH key pair created in AWS

---

## Step 1: Configure DNS Records

Add **one A record** to your domain DNS:

```
yourdomain.com   →   52.23.45.67 (EC2 Public IP)
```

Optional (if you prefer subdomains):

```
app.yourdomain.com → 52.23.45.67
```

---

## Step 2: Terraform Configuration

Run the following commands in the `terraform/` directory:

```bash
terraform init
terraform plan
terraform apply
```

Terraform provisions **one EC2 instance** and outputs:

* Public IP
* Application URL
* SSH command

---

## Step 3: Instance Setup

Terraform runs `scripts/setup-instance.sh` via `user_data`, which:

* Installs Docker
* Installs NGINX
* Installs Certbot (Let’s Encrypt)
* Prepares the host for application deployment

---

## Step 4: Application Deployment

Deployment targets **the same server**, changing only the environment variable.

### Deploy Production

```bash
APP_IP=$(terraform output -raw app_ip)
ssh ubuntu@$APP_IP "cd /opt/hello-svc && sudo ./scripts/deploy-app.sh production yourdomain.com"
```

### Deploy Staging (Same Server)

```bash
APP_IP=$(terraform output -raw app_ip)
ssh ubuntu@$APP_IP "cd /opt/hello-svc && sudo ./scripts/deploy-app.sh staging yourdomain.com"
```

The script restarts the container with the appropriate environment variable.

---

## Step 5: Verification

```bash
curl https://yourdomain.com
```

Expected responses:

* **Production:** `Hello! I am running in production.`
* **Staging:** `Hello! I am running in staging.`

---

## Key Design Decisions

* Single EC2 instance
* Environment-based deployment (no duplicate infrastructure)
* NGINX handles SSL termination and reverse proxying
* Dockerized Go application
* Let’s Encrypt for free, trusted HTTPS

---
