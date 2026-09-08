# Privileges started as a verbatim copy of the original:
#   pveum role add TerraformProv -privs "..."
# in tofu-talos-homelab's README, but has since grown — see this repo's
# README ("What this replaces") for the running list of additions and why.
resource "proxmox_virtual_environment_role" "opentofu" {
  role_id = var.opentofu_role_name

  privileges = [
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.AllocateTemplate",
    "Datastore.Audit",
    "Pool.Allocate",
    "SDN.Allocate",
    "SDN.Audit",
    "SDN.Use",
    "Sys.Audit",
    "Sys.Console",
    "Sys.Modify",
    "VM.Allocate",
    "VM.Audit",
    "VM.Clone",
    "VM.Config.CDROM",
    "VM.Config.Cloudinit",
    "VM.Config.CPU",
    "VM.Config.Disk",
    "VM.Config.HWType",
    "VM.Config.Memory",
    "VM.Config.Network",
    "VM.Config.Options",
    "VM.GuestAgent.Audit",
    "VM.GuestAgent.Unrestricted",
    "VM.Migrate",
    "VM.PowerMgmt",
  ]
}
