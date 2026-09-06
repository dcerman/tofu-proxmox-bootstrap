# Privileges copied 1:1 from the original:
#   pveum role add TerraformProv -privs "..."
# in tofu-talos-homelab's README — nothing about what this role can do
# has changed, only how it's created.
resource "proxmox_virtual_environment_role" "opentofu" {
  role_id = var.opentofu_role_name

  privileges = [
    "Datastore.AllocateSpace",
    "Datastore.AllocateTemplate",
    "Datastore.Audit",
    "Pool.Allocate",
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
    "VM.Migrate",
    "VM.PowerMgmt",
    "SDN.Use",
  ]
}
