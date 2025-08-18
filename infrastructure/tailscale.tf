resource "tailscale_tailnet_key" "this" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 7776000 # 90 days
  description   = "Auth key for ${var.cluster_name} cluster"
}
