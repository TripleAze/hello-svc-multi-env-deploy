output "production_ip" {
  description = "Production instance public IP"
  value       = aws_instance.production.public_ip
}

output "staging_ip" {
  description = "Staging instance public IP"
  value       = aws_instance.staging.public_ip
}

output "production_url" {
  description = "Production URL"
  value       = "https://production.${var.domain_name}"
}

output "staging_url" {
  description = "Staging URL"
  value       = "https://staging.${var.domain_name}"
}
output "app_url" {
  description = "URL to access your app"
  value       = "https://production.${var.domain_name}"
}
output "staging_app_url" {
  description = "URL to access your app"
  value       = "https://staging.${var.domain_name}"
}

output "ssh_commands" {
  description = "SSH commands to access instances"
  value = <<-EOT
    Production: ssh ubuntu@${aws_instance.production.public_ip}
    Staging:    ssh ubuntu@${aws_instance.staging.public_ip}
  EOT
}
