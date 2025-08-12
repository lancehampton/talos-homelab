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

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
    workers = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
  })
  default = {
    controlplanes = {
      "10.5.0.2" = {
        install_disk = "/dev/sda"
      },
      "10.5.0.3" = {
        install_disk = "/dev/sda"
      },
      "10.5.0.4" = {
        install_disk = "/dev/sda"
      }
    }
    workers = {
      "10.5.0.5" = {
        install_disk = "/dev/nvme0n1"
        hostname     = "worker-1"
      },
      "10.5.0.6" = {
        install_disk = "/dev/nvme0n1"
        hostname     = "worker-2"
      }
    }
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

###############
# Cloudflare  #
###############

variable "cloudflare_api_token" {
  type        = string
  description = "Account API token for Cloudflare."
}

variable "r2_access_key_id" {
  type        = string
  description = "The access key ID for the R2 bucket."
}

variable "r2_secret_access_key" {
  type        = string
  description = "The secret access key for the R2 bucket."
}

variable "r2_bucket_name" {
  type        = string
  description = "The name of the R2 bucket used for storing Terraform state files."
}

variable "r2_endpoint" {
  type        = string
  description = "The endpoint for the R2 bucket used for storing Terraform state files."
}
