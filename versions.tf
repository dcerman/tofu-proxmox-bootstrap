terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      # Match whatever version tofu-talos-homelab pins in its own
      # versions.tf — the two projects don't share state, but keeping
      # the provider version consistent avoids surprises if resource
      # names change between them (see README "Naming note").
      version = ">= 0.66, < 1.0.0"
    }
  }
}
