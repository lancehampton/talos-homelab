##########
# Talos  #
##########

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
}

variable "gateway" {
  description = "The default gateway for the nodes"
  type        = string
}

variable "netmask" {
  description = "The default netmask for the nodes"
  type        = string
}

variable "controlplane_nodes" {
  description = "Map of control plane hostnames to their parameters"
  type = map(object({
    node_ip      = string
    interface    = optional(string)
    install_disk = string
  }))
  default = {
    "cp-1" = {
      node_ip      = "172.31.0.10"
      install_disk = "/dev/nvme0n1"
    }
    "cp-2" = {
      node_ip      = "172.31.0.11"
      install_disk = "/dev/nvme0n1"
    }
    "cp-3" = {
      node_ip      = "172.31.0.12"
      install_disk = "/dev/nvme0n1"
    }
    # Add more control plane nodes here as needed
  }
}

variable "worker_nodes" {
  description = "Map of worker hostnames to their parameters"
  type = map(object({
    node_ip      = string
    interface    = optional(string)
    install_disk = string
  }))
  default = {
    "w-1" = {
      node_ip      = "172.31.0.30"
      install_disk = "/dev/nvme0n1"
    }
    "w-2" = {
      node_ip      = "172.31.0.31"
      install_disk = "/dev/nvme0n1"
    }
    # Add more worker nodes here
  }
}

variable "talos_version" {
  description = "Talos version to deploy"
  type        = string
  default     = "v1.10.6"
}

variable "talosconfig_path" {
  description = "Full path to write the Talos configuration file, e.g. ~/.talos/config"
  type        = string
}

variable "kubeconfig_path" {
  description = "Full path to write the kubeconfig file, e.g. ~/.kube/config"
  type        = string
}

# # https://github.com/siderolabs/extensions/blob/main/network/cloudflared/README.md
# variable "cloudflared_tunnel_token" {
#   type        = string
#   description = "Cloudflared token for Talos system extension. Create this in the Cloudflare dashboard."
#   sensitive   = true
# }

# # https://github.com/siderolabs/extensions/blob/main/network/tailscale/README.md
# variable "tailscale_auth_key" {
#   type        = string
#   description = "Tailscale auth key for Talos system extension. Create a reusable auth key in Tailscale admin console."
#   sensitive   = true
# }

###############
# Cloudflare  #
###############

variable "cloudflare_api_token" {
  sensitive   = true
  type        = string
  description = "Account API token for Cloudflare."
}

variable "cloudflare_account_id" {
  sensitive   = true
  type        = string
  description = "Cloudflare account ID owning the zone used for homelab apps."
}

variable "cloudflare_zone_id" {
  sensitive   = true
  type        = string
  description = "Cloudflare zone ID (root DNS zone) for homelab apps."
}

variable "domain" {
  type        = string
  description = "Base domain (e.g. example.com) used for application hostnames."
}

variable "tunnel_id" {
  type        = string
  description = "Existing Cloudflare tunnel UUID. Get it from the Cloudflare dashboard."
}

variable "apps" {
  description = <<EOT
Map of app definitions exposed via Cloudflare Tunnel. Keys are logical app names. Values:
  subdomain   - left part of FQDN (without base domain)
  service_url - internal cluster URL cloudflared should connect to (http://svc.namespace.svc.cluster.local:port)
  protected   - if true create a Cloudflare Access Application + allow policy
  emails      - optional list of explicit email addresses allowed (overrides global_access_emails if set)
  groups      - (future) list of Access Group logical names; currently unused
EOT
  type = map(object({
    subdomain   = string
    service_url = string
    protected   = bool
    emails      = optional(list(string), [])
    groups      = optional(list(string), [])
  }))
  default = {}
}

variable "r2_bucket_name" {
  type        = string
  description = "The name of the R2 bucket used for storing Terraform state files."
}

variable "r2_access_key_id" {
  sensitive   = true
  type        = string
  description = "The access key ID for the R2 bucket."
}

variable "r2_secret_access_key" {
  sensitive   = true
  type        = string
  description = "The secret access key for the R2 bucket."
}

variable "r2_endpoint" {
  type        = string
  description = "The endpoint for the R2 bucket used for storing Terraform state files."
}

#############
# Tailscale #
#############

variable "tailscale_api_key" {
  sensitive   = true
  type        = string
  description = "API key for Tailscale."
}

variable "tailscale_tailnet" {
  sensitive   = true
  type        = string
  description = "Tailscale tailnet name."
}
