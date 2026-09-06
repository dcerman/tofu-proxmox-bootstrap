output "opentofu_api_token" {
  description = "Paste this into tofu-talos-homelab's terraform.tfvars as proxmox_api_token"
  value       = "${proxmox_virtual_environment_user.opentofu.user_id}!${proxmox_virtual_environment_user_token.opentofu.token_name}=${proxmox_virtual_environment_user_token.opentofu.value}"
  sensitive   = true
}
