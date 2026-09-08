# tofu-proxmox-bootstrap

One-time (or occasionally-run) OpenTofu project that creates the scoped
Proxmox role, service-account user, API token, and internal network that
`tofu-talos-homelab` uses for everything else.
Kept as a separate project on purpose: this is the only place a
root-level Proxmox credential is ever needed. It never touches SSH or the
OS-level `root` account — that stays confined to `tofu-talos-homelab`,
which needs it for an unrelated reason (disk-image import has no
non-SSH API path today).

## What this replaces

| Manual command (old README) | This project's resource |
|---|---|
| `pveum role add TerraformProv -privs "..."` | `proxmox_virtual_environment_role.opentofu` |
| `pveum user add terraform@pve` | `proxmox_virtual_environment_user.opentofu` |
| `pveum aclmod / -user terraform@pve -role TerraformProv` | `proxmox_acl.opentofu` |
| `pveum user token add terraform@pve opentofu --privsep 0` | `proxmox_user_token.opentofu` |

The privilege list in `role.tf` started as a verbatim copy of the original
`pveum role add` command, but has since grown: `SDN.Allocate`/`SDN.Audit`
for the network resources below, `VM.GuestAgent.Audit`/
`VM.GuestAgent.Unrestricted` to quiet a permission warning during
`tofu-talos-homelab`'s apply, and `Datastore.Allocate` after a
`tofu destroy` failed to remove the downloaded Talos ISO with only
`Datastore.AllocateSpace`/`Datastore.AllocateTemplate` granted. Treat
`role.tf` as the source of truth going forward, not the original command.

## Internal network (SDN)

`network.tf` provisions the isolated network `tofu-talos-homelab`'s VMs
attach to: a Proxmox SDN simple zone (`talos`), VNet (`talosnet`), and
subnet (`10.10.10.0/24`, gateway `10.10.10.1`, SNAT for outbound). This
was previously just assumed to exist in that project's README — it
never did, which is why the Talos nodes were unreachable after its
first apply.

`proxmox_sdn_applier` is marked **EXPERIMENTAL** in the provider's docs
as of `~> 0.112.0` — it's the only sanctioned way to commit pending SDN
changes today, but worth knowing going in. The `finalizer`/`network`
two-applier pattern is copied from the provider's own docs, not
homelab-specific.

SNAT provides outbound internet access only — nothing on your home LAN
can reach `10.10.10.0/24` directly by default. To manage the cluster
from a machine other than the Proxmox host itself, add a static route
on that machine for `10.10.10.0/24` via the Proxmox host's LAN address
(e.g. `192.168.1.20`) — that's what makes `talosctl`/`kubectl` reachable
from a laptop in practice.

### Administrative workstation networking

The route above belongs to the administrator's workstation network
configuration, not to this OpenTofu project. It should therefore be
configured using the workstation's native network-management tools
rather than an OpenTofu provisioner.

On a Linux workstation using NetworkManager:

```sh
nmcli connection show
sudo nmcli connection modify "<connection>"   +ipv4.routes "10.10.10.0/24 192.168.1.20"
sudo nmcli connection up "<connection>"
```

Replace `192.168.1.20` with the Proxmox host's LAN address and
`<connection>` with the active NetworkManager connection.

Verify the route with:

```sh
ip route get 10.10.10.11
```

The route is required for direct administration with `talosctl` and for
OpenTofu's Talos provider, as well as for `kubectl` access to the cluster.

## One-time setup

1. In the Proxmox web UI: **Datacenter → Permissions → API Tokens → Add**
   - User: `root@pam`
   - Token ID: anything, e.g. `bootstrap`
   - Uncheck "Privilege Separation" (so the token can actually create
     users/roles/tokens for this one apply)
   - Copy the secret shown — it's only displayed once.
2. `cp terraform.tfvars.example terraform.tfvars` and fill in your
   endpoint and that token as `proxmox_bootstrap_api_token`.
3. `tofu init && tofu plan && tofu apply`
4. Get what `tofu-talos-homelab` needs:
   ```sh
   tofu output -raw opentofu_api_token   # → proxmox_api_token
   tofu output -raw network_vnet_id      # → network_bridge
   ```
   Paste each into that project's `terraform.tfvars`.
5. Optional but recommended once you're done iterating: go back to
   Datacenter → Permissions → API Tokens and revoke `root@pam!bootstrap`.
   If you're still actively making changes to this project, an expiring
   token (rather than an immediate revoke) avoids re-authentication
   errors on your next `tofu plan`.

## Re-running this project

Because this is now code, changing the role's privileges, the internal
network, or rotating the `opentofu` token is a `tofu apply` away instead
of a retyped `pveum`/manual-network session — but any apply of *this*
project still needs a root-scoped token, since managing users/roles/
tokens is inherently a root-level operation in Proxmox. Repeat step 1
when you need one.

## Naming note

`bpg/proxmox` is renaming several resources ahead of a 1.0 release. On
the pinned `~> 0.112.0`, `tofu plan` confirmed two of ours are affected:
`proxmox_virtual_environment_user_token` → `proxmox_user_token` (used
directly, see `token.tf`), and the inline `acl` block that used to live
on `proxmox_virtual_environment_user` is now the standalone
`proxmox_acl` resource (see `user.tf`). `proxmox_virtual_environment_role`
and `proxmox_virtual_environment_user` themselves didn't warn on this
version, so they're left as-is — check `tofu plan` output again after
any future provider version bump rather than assuming this list is
final. The SDN resources in `network.tf` already use the short-form
names (`proxmox_sdn_zone_simple`, `proxmox_sdn_vnet`, etc.), which never
had a deprecated long form to begin with.

## State handling

State here holds the role definition, the user object, the token's
*identifier*, and the SDN network config — Proxmox doesn't return a
token's secret on read, so it only appears in state right after
creation. Don't commit `terraform.tfstate` regardless, same as any
project touching credentials.
