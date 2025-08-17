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
      # Use cluster CoreDNS for DNS resolution
      - 10.96.0.10
      - 1.1.1.1
      - 1.0.0.1
  kubelet:
    extraArgs:
      node-ip: ${node_ip}
  features:
    hostDNS:
      enabled: false

cluster:
  network:
    podSubnets:
      - 10.244.0.0/16
    serviceSubnets:
      - 10.96.0.0/12
