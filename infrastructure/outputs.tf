output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "schematic_id" {
  value = talos_image_factory_schematic.this.id
}

output "tailscale_patch" {
  sensitive = true
  value     = templatefile("${path.module}/files/tailscale-config.yaml.tpl", { auth_key = var.tailscale_auth_key })
}

output "cloudflared_patch" {
  sensitive = true
  value     = templatefile("${path.module}/files/cloudflared-config.yaml.tpl", { tunnel_token = var.cloudflared_tunnel_token })
}
