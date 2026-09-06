# Creates the isolated internal network that tofu-talos-homelab's VMs
# attach to. Previously just assumed to exist (see that repo's README
# step 1) but never actually provisioned anywhere — this is the fix.
#
# Proxmox SDN changes are staged, not applied immediately. The
# `finalizer` applier commits any prior pending state before these
# resources are created; the trailing `network` applier commits these
# changes. Pattern is copied verbatim from the provider's own docs for
# proxmox_sdn_applier, not homelab-specific.

resource "proxmox_sdn_applier" "finalizer" {}

resource "proxmox_sdn_zone_simple" "talos" {
  id = var.network_zone_id

  depends_on = [proxmox_sdn_applier.finalizer]
}

resource "proxmox_sdn_vnet" "talos" {
  id   = var.network_vnet_id
  zone = proxmox_sdn_zone_simple.talos.id

  depends_on = [proxmox_sdn_applier.finalizer]
}

resource "proxmox_sdn_subnet" "talos" {
  cidr    = var.network_subnet_cidr
  vnet    = proxmox_sdn_vnet.talos.id
  gateway = var.network_gateway
  snat    = true # outbound NAT only — no inbound routing from your LAN

  depends_on = [proxmox_sdn_applier.finalizer]
}

resource "proxmox_sdn_applier" "network" {
  depends_on = [
    proxmox_sdn_zone_simple.talos,
    proxmox_sdn_vnet.talos,
    proxmox_sdn_subnet.talos,
  ]
}
