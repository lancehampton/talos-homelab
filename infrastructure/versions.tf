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
  }
  required_version = ">= 1.6.0"
}

terraform {
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
