# Hello-SVC Deployment with Custom Domain & SSL

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Your Domain                              │
│                    (yourdomain.com with SSL)                     │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ DNS A Records
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
┌───────────────────┐                 ┌───────────────────┐
│  production       │                 │  staging          │
│  .yourdomain.com  │                 │  .yourdomain.com  │
│                   │                 │                   │
│  EC2 Instance     │                 │  EC2 Instance     │
│  52.23.45.67      │                 │  54.89.12.34      │
│                   │                 │                   │
│  ┌─────────────┐  │                 │  ┌─────────────┐  │
│  │   Nginx     │  │                 │  │   Nginx     │  │
│  │ (SSL:443)   │  │                 │  │ (SSL:443)   │  │
│  │ (HTTP:80)   │  │                 │  │ (HTTP:80)   │  │
│  └──────┬──────┘  │                 │  └──────┬──────┘  │
│         │         │                 │         │         │
│         ▼         │                 │         ▼         │
│  ┌─────────────┐  │                 │  ┌─────────────┐  │
│  │  hello-svc  │  │                 │  │  hello-svc  │  │
│  │  (Docker)   │  │                 │  │  (Docker)   │  │
│  │  ENV=prod   │  │                 │  │  ENV=stg    │  │
│  │  Port 8080  │  │                 │  │  Port 8080  │  │
│  └─────────────┘  │                 │  └─────────────┘  │
└───────────────────┘                 └───────────────────┘
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

✅ Domain purchased and configured (e.g., yourdomain.com)
✅ SSL certificate (either already installed or we'll use existing)
✅ AWS account with credentials configured
✅ Terraform installed locally
✅ SSH key pair created in AWS

---

## Step 1: Configure DNS Records

Add these A records to your domain's DNS:

```
production.yourdomain.com   →   52.23.45.67 (Production EC2 IP)
staging.yourdomain.com      →   54.89.12.34 (Staging EC2 IP)
```

**Note:** We'll get these IPs after Terraform creates the instances.

---

## Step 2: Terraform Configuration

Run the following commands in the `terraform/` directory:

```bash
terraform init
terraform plan
terraform apply
```

Note the output IPs for the next step.

---

## Step 3: Instance Setup

Terraform will automatically run the `scripts/setup-instance.sh` script via `user_data`, which installs Docker, Nginx, and essential tools.

---

## Step 4: Application Deployment

Use the deployment script to deploy to your environments.

**Production:**
```bash
# Get production IP
PROD_IP=$(terraform output -raw production_ip)

# Deploy
# Deploy
ssh ubuntu@$PROD_IP "cd /opt/hello-svc && sudo ./scripts/deploy-app.sh production production.yourdomain.com"
```

**Staging:**
```bash
# Get staging IP
STG_IP=$(terraform output -raw staging_ip)

# Deploy
# Deploy
ssh ubuntu@$STG_IP "cd /opt/hello-svc && sudo ./scripts/deploy-app.sh staging staging.yourdomain.com"
```

(Note: You may need to copy the repo first or clone it as per the instructions in the `setup-instance.sh` script).

---

## Step 5: Verification

- `curl https://production.yourdomain.com` -> "Hello! I am running in production."
- `curl https://staging.yourdomain.com` -> "Hello! I am running in staging."
