# Equivalent to:
#   pveum user add terraform@pve
#   pveum aclmod / -user terraform@pve -role TerraformProv
resource "proxmox_virtual_environment_user" "opentofu" {
  user_id = var.opentofu_user_id
  comment = "Service account for tofu-talos-homelab. Managed by tofu-proxmox-bootstrap."
  enabled = true

  acl {
    path      = "/"
    role_id   = proxmox_virtual_environment_role.opentofu.role_id
    propagate = true
  }

  # If your pinned provider version rejects an inline `acl` block on this
  # resource, delete it here and add a standalone resource instead:
  #
  # resource "proxmox_virtual_environment_acl" "opentofu" {
  #   path      = "/"
  #   role_id   = proxmox_virtual_environment_role.opentofu.role_id
  #   user_id   = proxmox_virtual_environment_user.opentofu.user_id
  #   propagate = true
  # }
}
