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

variable "network_zone_id" {
  type        = string
  default     = "talos"
  description = "Proxmox SDN zone ID (max 8 chars, lowercase, no dashes)"
}

variable "network_vnet_id" {
  type        = string
  default     = "talosnet"
  description = "Proxmox SDN VNet ID (max 8 chars, lowercase, no dashes) — becomes the bridge name Talos VMs attach to"
}

variable "network_subnet_cidr" {
  type        = string
  default     = "10.10.10.0/24"
  description = "Must match tofu-talos-homelab's network_gateway/network_cidr_suffix"
}

variable "network_gateway" {
  type    = string
  default = "10.10.10.1"
}
