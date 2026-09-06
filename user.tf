# Equivalent to:
#   pveum user add terraform@pve
resource "proxmox_virtual_environment_user" "opentofu" {
  user_id = var.opentofu_user_id
  comment = "Service account for tofu-talos-homelab. Managed by tofu-proxmox-bootstrap."
  enabled = true
}

# Equivalent to:
#   pveum aclmod / -user terraform@pve -role TerraformProv
#
# A standalone resource rather than an inline `acl` block on the user
# above — the inline block is deprecated as of provider 0.112.x (it's no
# longer kept in sync on refresh/import).
resource "proxmox_acl" "opentofu" {
  path      = "/"
  role_id   = proxmox_virtual_environment_role.opentofu.role_id
  user_id   = proxmox_virtual_environment_user.opentofu.user_id
  propagate = true
}
