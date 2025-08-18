###############################
# Cloudflare Tunnel & Access  #
###############################

locals {
  protected_apps = { for k, v in var.apps : k => v if v.protected }
  app_fqdn       = { for k, v in var.apps : k => "${v.subdomain}.${var.domain}" }
  tunnel_cname   = "${var.tunnel_id}.cfargotunnel.com"
  tunnel_ingress = [for k, v in var.apps : { hostname = local.app_fqdn[k], service = v.service_url }]
  tunnel_config = {
    ingress = concat(
      [for r in local.tunnel_ingress : { hostname = r.hostname, service = r.service }],
      [{ service = "http_status:404" }]
    )
  }
}

resource "cloudflare_dns_record" "apps" {
  for_each = var.apps
  zone_id  = var.cloudflare_zone_id
  name     = local.app_fqdn[each.key]
  ttl      = 1
  type     = "CNAME"
  comment  = "Tunnel route for ${each.key}"
  content  = local.tunnel_cname
  proxied  = true
}

resource "cloudflare_zero_trust_access_application" "apps" {
  for_each                  = local.protected_apps
  zone_id                   = var.cloudflare_zone_id
  name                      = each.key
  domain                    = local.app_fqdn[each.key]
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true

  policies = [
    { id = cloudflare_zero_trust_access_policy.apps_access[each.key].id },
  ]
}

# Manage tunnel public hostnames (replaces any manual dashboard edits for this tunnel).
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel" {
  account_id = var.cloudflare_account_id
  tunnel_id  = var.tunnel_id
  config     = local.tunnel_config
}

resource "cloudflare_zero_trust_access_policy" "apps_access" {
  for_each   = local.protected_apps
  account_id = var.cloudflare_account_id
  name       = "allowed-users"
  decision   = "allow"
  include    = [for e in each.value.emails : { email = { email = e } }]
}

###########
# Outputs #
###########

output "cloudflare_tunnel_id" {
  description = "External tunnel ID (variable supplied)."
  value       = var.tunnel_id
}

# output "cloudflare_tunnel_cname" {
#   description = "Derived CNAME target for the tunnel."
#   value       = local.tunnel_cname
# }

# output "cloudflare_access_protected_apps" {
#   description = "List of protected app hostnames."
#   value       = [for k, v in local.protected_apps : local.app_fqdn[k]]
# }


