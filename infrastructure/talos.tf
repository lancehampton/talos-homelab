resource "talos_machine_secrets" "this" { talos_version = var.talos_version }

data "talos_machine_configuration" "controlplane" {
  for_each         = var.controlplane_nodes
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
  config_patches = [
    file("${path.module}/files/cp-scheduling.yaml"),
    templatefile("${path.module}/files/common.yaml.tpl", {
      hostname      = each.key
      node_ip       = each.value.node_ip
      gateway       = var.gateway
      netmask       = var.netmask
      interface     = each.value.interface
      install_disk  = each.value.install_disk
      installer_url = data.talos_image_factory_urls.this.urls.installer
    }),
    templatefile("${path.module}/files/tailscale-config.yaml.tpl", {
      auth_key = var.tailscale_auth_key
    }),
    # templatefile("${path.module}/files/cloudflared-config.yaml.tpl", {
    #   tunnel_token = var.cloudflared_tunnel_token
    # }),
  ]
}

# TODO: consider separate template for worker nodes
data "talos_machine_configuration" "worker" {
  for_each         = var.worker_nodes
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
  config_patches = [
    templatefile("${path.module}/files/common.yaml.tpl", {
      hostname      = each.key
      node_ip       = each.value.node_ip
      gateway       = each.value.gateway
      netmask       = var.netmask
      interface     = each.value.interface
      install_disk  = each.value.install_disk
      installer_url = data.talos_image_factory_urls.this.urls.installer
    }),
    templatefile("${path.module}/files/tailscale-config.yaml.tpl", {
      auth_key = var.tailscale_auth_key
    }),
    # templatefile("${path.module}/files/cloudflared-config.yaml.tpl", {
    #   tunnel_token = var.cloudflared_tunnel_token
    # }),
  ]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.controlplane_nodes : v.node_ip]
}

# Declare the system extensions we want to include
data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = [
      "tailscale",
    ]
  }
}

# Get the schematic id that includes the desired extensions
resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

# Get the image URL that includes the desired extensions
data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "metal"
  architecture  = "amd64"
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = var.controlplane_nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane[each.key].machine_configuration
  node                        = each.key
  endpoint                    = each.value.node_ip
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = var.worker_nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration
  node                        = each.key
  endpoint                    = each.value.node_ip
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.controlplane_nodes : k][0]
  endpoint             = [for k, v in var.controlplane_nodes : v.node_ip][0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.controlplane_nodes : k][0]
  endpoint             = [for k, v in var.controlplane_nodes : v.node_ip][0]
}

resource "local_file" "talosconfig" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = var.talosconfig_path
  file_permission = "0644"
}

resource "local_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = var.kubeconfig_path
  file_permission = "0644"
}
