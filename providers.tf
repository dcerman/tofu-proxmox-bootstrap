provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_bootstrap_api_token

  # Self-signed pve.lan cert on this homelab host — expected, not a
  # misconfiguration.
  insecure = true

  # No ssh block here on purpose. Unlike tofu-talos-homelab, this project
  # only ever touches role/user/token objects through the PVE API — it
  # never needs the OS-level root SSH access that disk-image import
  # requires. That constraint stays fully confined to the other project.
}
