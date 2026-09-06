variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint, e.g. https://192.168.1.20:8006"
}

variable "proxmox_bootstrap_api_token" {
  type        = string
  sensitive   = true
  description = <<-EOT
    A root-scoped API token used ONLY to run this project. Generate it by
    hand, once, via the Proxmox web UI: Datacenter -> Permissions ->
    API Tokens -> Add, User = root@pam, Token ID = anything (e.g.
    "bootstrap"), uncheck "Privilege Separation". Format:
    "root@pam!bootstrap=<uuid>". Safe to revoke from the web UI after
    the first successful apply — see README.
  EOT
}

variable "opentofu_role_name" {
  type        = string
  default     = "TerraformProv"
  description = "Name of the scoped role granted to the OpenTofu service account"
}

variable "opentofu_user_id" {
  type        = string
  default     = "terraform@pve"
  description = "PVE-realm service account that tofu-talos-homelab authenticates as"
}

variable "opentofu_token_name" {
  type        = string
  default     = "opentofu"
  description = "Name of the API token minted for the service account"
}
