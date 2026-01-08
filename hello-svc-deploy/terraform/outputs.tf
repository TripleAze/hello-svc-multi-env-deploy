output "app_server_ip" {
  description = "App Server public IP"
  value       = aws_eip.app_eip.public_ip
}

output "production_url" {
  description = "Production URL"
  value       = "https://abu-production.${var.domain_name}"
}

output "staging_url" {
  description = "Staging URL"
  value       = "https://abu-staging.${var.domain_name}"
}

output "ssh_command" {
  description = "SSH command to access instance"
  value       = "ssh ubuntu@${aws_eip.app_eip.public_ip}"
}
