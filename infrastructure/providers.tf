terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.8"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.21.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
  required_version = ">= 1.6.0"

  # https://developers.cloudflare.com/terraform/advanced-topics/remote-backend/
  backend "s3" {
    bucket                      = var.r2_bucket_name
    key                         = "talos/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    access_key                  = var.r2_access_key_id
    secret_key                  = var.r2_secret_access_key
    endpoints                   = { s3 = var.r2_endpoint }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_tailnet
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}
