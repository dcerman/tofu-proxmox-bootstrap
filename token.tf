# Equivalent to:
#   pveum user token add terraform@pve opentofu --privsep 0
resource "proxmox_virtual_environment_user_token" "opentofu" {
  user_id    = proxmox_virtual_environment_user.opentofu.user_id
  token_name = var.opentofu_token_name
  comment    = "Used by tofu-talos-homelab. Managed by tofu-proxmox-bootstrap."

  # privsep 0 in the original pveum command == false here: the token
  # inherits the user's role directly rather than needing its own ACL.
  privileges_separation = false
}
