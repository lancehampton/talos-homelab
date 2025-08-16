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
  kubelet:
    extraArgs:
      node-ip: ${node_ip}

cluster:
  network:
    podSubnets:
      - 10.244.0.0/16
    serviceSubnets:
      - 10.96.0.0/12
