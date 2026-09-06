# tofu-proxmox-bootstrap

One-time (or rarely-run) OpenTofu project that creates the scoped Proxmox
role, service-account user, and API token that `tofu-talos-homelab` uses
for everything else.

Kept as a separate project on purpose: this is the only place a
root-level Proxmox credential is ever needed. It never touches SSH or
the OS-level `root` account — that stays confined to `tofu-talos-homelab`,
which needs it for an unrelated reason (disk-image import has no
non-SSH API path today).

## What this replaces

| Manual command (old README) | This project's resource |
|---|---|
| `pveum role add TerraformProv -privs "..."` | `proxmox_virtual_environment_role.opentofu` |
| `pveum user add terraform@pve` | `proxmox_virtual_environment_user.opentofu` |
| `pveum aclmod / -user terraform@pve -role TerraformProv` | `proxmox_acl.opentofu` |
| `pveum user token add terraform@pve opentofu --privsep 0` | `proxmox_user_token.opentofu` |

The privilege list in `role.tf` is copied verbatim from the original
`pveum role add` command — the permission surface hasn't changed, only
how it's created and tracked.

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
4. Get the token `tofu-talos-homelab` actually needs:
   ```sh
   tofu output -raw opentofu_api_token
   ```
   Paste that into `tofu-talos-homelab`'s `terraform.tfvars` as
   `proxmox_api_token`.
5. Optional but recommended: go back to Datacenter → Permissions →
   API Tokens and revoke `root@pam!bootstrap`. Nothing here needs it
   again unless you're re-applying this project later.

## Re-running this project

Because this is now code, changing the role's privileges or rotating the
`opentofu` token is a `tofu apply` away instead of a retyped `pveum`
session — but any apply of *this* project still needs a root-scoped
token, since managing users/roles/tokens is inherently a root-level
operation in Proxmox. Repeat step 1 when you need one.

## Naming note

`bpg/proxmox` is renaming several resources ahead of a 1.0 release. On
the pinned `~> 0.112.0`, `tofu plan` confirmed two of ours are affected:
`proxmox_virtual_environment_user_token` → `proxmox_user_token` (used
directly, see `token.tf`), and the inline `acl` block that used to live
on `proxmox_virtual_environment_user` is now the standalone `proxmox_acl`
resource (see `user.tf`). `proxmox_virtual_environment_role` and
`proxmox_virtual_environment_user` themselves didn't warn on this
version, so they're left as-is — check `tofu plan` output again after
any future provider version bump rather than assuming this list is
final.

## State handling

State here holds the role definition, the user object, and the token's
*identifier* — Proxmox doesn't return a token's secret on read, so it
only appears in state right after creation. Don't commit
`terraform.tfstate` regardless, same as any project touching credentials.
