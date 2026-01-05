variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
  default     = "abu-app.chickenkiller.com"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "ssl_cert_path" {
  description = "Path to SSL certificate on local machine"
  type        = string
  default     = "/etc/letsencrypt/live/abu-app.chickenkiller.com/fullchain.pem"
}

variable "ssl_key_path" {
  description = "Path to SSL private key on local machine"
  type        = string
  default     = "/etc/letsencrypt/live/abu-app.chickenkiller.com/privkey.pem"
}
