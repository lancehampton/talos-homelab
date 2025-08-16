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
    "thor-cp-01" = {
      node_ip      = "192.168.50.200"
      install_disk = "/dev/nvme0n1"
    }
    "loki-cp-02" = {
      node_ip      = "192.168.50.201"
      install_disk = "/dev/nvme0n1"
    }
    "odin-cp-03" = {
      node_ip      = "192.168.50.202"
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
    "sif-w-01" = {
      node_ip      = "192.168.50.210"
      install_disk = "/dev/nvme0n1"
    }
    "valkyrie-w-02" = {
      node_ip      = "192.168.50.211"
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

# https://github.com/siderolabs/extensions/blob/main/network/cloudflared/README.md
variable "cloudflared_tunnel_token" {
  type        = string
  description = "Cloudflared token for Talos system extension"
  sensitive   = true
}

# https://github.com/siderolabs/extensions/blob/main/network/tailscale/README.md
variable "tailscale_auth_key" {
  type        = string
  description = "Tailscale auth key for Talos system extension"
  sensitive   = true
}

###############
# Cloudflare  #
###############

variable "cloudflare_api_token" {
  type        = string
  description = "Account API token for Cloudflare."
}

variable "r2_bucket_name" {
  type        = string
  description = "The name of the R2 bucket used for storing Terraform state files."
}

variable "r2_access_key_id" {
  type        = string
  description = "The access key ID for the R2 bucket."
}

variable "r2_secret_access_key" {
  type        = string
  description = "The secret access key for the R2 bucket."
}

variable "r2_endpoint" {
  type        = string
  description = "The endpoint for the R2 bucket used for storing Terraform state files."
}
