# Talos Homelab

A bare-metal Kubernetes homelab using [Talos Linux](https://www.talos.dev/docs/) for secure, immutable cluster management and OpenTofu for infrastructure as code.

## Overview

This project provisions a Talos-based Kubernetes cluster on bare metal, using OpenTofu for declarative infrastructure management. It is designed for single-node or multi-node clusters and follows best practices for reproducibility and security.

## Quick Start

1. Clone this repository.
2. Copy and edit `infrastructure/terraform.tfvars.example` to `terraform.tfvars` with your environment details.
3. Initialize and apply the OpenTofu configuration:

	 ```sh
	 cd infrastructure
	 tofu init
	 tofu plan
	 tofu apply
	 ```
4. Patch the system extension configurations for Tailscale and Cloudflared:

	 ```sh
	 tofu output -raw tailscale_patch | talosctl patch mc --mode=no-reboot --patch @-
   tofu output -raw cloudflared_patch | talosctl patch mc --mode=no-reboot --patch @-
	 ```

## Directory Structure

```
infrastructure/
├── cloudflare.tf            # Cloudflare resource configuration
├── outputs.tf               # Output values (e.g., kubeconfig)
├── providers.tf              # Provider and OpenTofu version constraints
├── talos.tf                 # Talos resource configuration
├── terraform.tfvars.example # Example variable values for customization
├── terraform.tfvars         # User-specific variable values (not committed)
├── variables.tf             # Variable definitions and defaults
├── templates/               # Talos config and patch templates
└── files/                   # Additional files (e.g., config patches)
```

## Architecture

```mermaid
graph TB
	DEV["User Workstation<br/>(OpenTofu, talosctl, kubectl)"]
	ROUTER["Home Router/Switch<br/>(DHCP + LAN + Local DNS)"]
	NODE["Bare Metal Node<br/>(Talos OS, Control Plane + Worker)"]

	DEV -- SSH/API --> NODE
	DEV -- LAN --> ROUTER
	ROUTER -- Ethernet/DHCP --> NODE
```

## References

- [Talos documentation](https://www.talos.dev/docs/)
- [OpenTofu documentation](https://opentofu.org/docs/)
- [Talos OpenTofu provider](https://registry.opentofu.org/providers/siderolabs/talos/latest/docs)
- [Kubernetes documentation](https://kubernetes.io/docs/)
