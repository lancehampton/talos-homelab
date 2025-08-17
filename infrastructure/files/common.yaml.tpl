machine:
  install:
    disk: ${install_disk}
    image: ${installer_url}
  network:
    hostname: ${hostname}
    interfaces:
      - interface: ${interface}
        addresses:
          - ${node_ip}/${netmask}
        routes:
          - network: 0.0.0.0/0
            gateway: ${gateway}
    nameservers:
      # https://github.com/siderolabs/talos/issues/10427#issuecomment-2684840653
      - 10.96.0.10
      - 1.1.1.1
      - 8.8.8.8
  kubelet:
    extraArgs:
      node-ip: ${node_ip}
  features:
    hostDNS:
      enabled: true

cluster:
  network:
    podSubnets:
      - 10.244.0.0/16
    serviceSubnets:
      - 10.96.0.0/12
