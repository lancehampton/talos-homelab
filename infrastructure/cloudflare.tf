###############################
# Cloudflare Tunnel & Access  #
###############################

locals {
  protected_apps = { for k, v in var.apps : k => v if v.protected }

  # Effective user and admin lists per protected app. App-specific emails override; else fall back to global lists.
  app_user_emails = {
    for name, app in local.protected_apps :
    name => (length(try(app.emails, [])) > 0 ? app.emails : var.user_access_emails)
  }
  app_admin_emails = distinct(concat(var.admin_access_emails, [var.admin_email]))
}

# Build ingress entries for tunnel config from all apps (protected or not)
locals {
  tunnel_ingress = [
    for k, v in var.apps : {
      hostname = "${v.subdomain}.${var.domain}"
      service  = v.service_url
    }
  ]
}

## Tunnel is external (Talos-created). Use var.tunnel_id + derived CNAME target.
locals {
  tunnel_cname = "${var.tunnel_id}.cfargotunnel.com"
}

locals {
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
  name     = each.value.subdomain
  type     = "CNAME"
  content  = local.tunnel_cname
  proxied  = true
  ttl      = 1
  comment  = "Tunnel route for ${each.key}"
}

resource "cloudflare_zero_trust_access_application" "apps" {
  for_each                  = local.protected_apps
  zone_id                   = var.cloudflare_zone_id
  name                      = each.key
  domain                    = "${each.value.subdomain}.${var.domain}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true

  # Ordered policies (first match wins). Admin precedes user.
  policies = [
    { id = cloudflare_zero_trust_access_policy.apps_admin[each.key].id },
    { id = cloudflare_zero_trust_access_policy.apps_user[each.key].id },
  ]
}

# Manage tunnel public hostnames (replaces any manual dashboard edits for this tunnel).
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel" {
  account_id = var.cloudflare_account_id
  tunnel_id  = var.tunnel_id
  # Remote cloudflared config (object form expected by provider).
  config = local.tunnel_config
}

resource "cloudflare_zero_trust_access_policy" "apps_user" {
  for_each   = local.protected_apps
  account_id = var.cloudflare_account_id
  name       = "user-${each.key}"
  decision   = "allow"
  # Users allowed by email list
  include = [for e in local.app_user_emails[each.key] : { email = { email = e } }]
}

resource "cloudflare_zero_trust_access_policy" "apps_admin" {
  for_each   = local.protected_apps
  account_id = var.cloudflare_account_id
  name       = "admin-${each.key}"
  decision   = "allow"
  # Admins allowed (higher precedence)
  include = [for e in local.app_admin_emails : { email = { email = e } }]
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
#   value       = [for k, v in local.protected_apps : "${v.subdomain}.${var.domain}"]
# }


