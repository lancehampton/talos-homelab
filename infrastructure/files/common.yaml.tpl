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
      # Include CoreDNS Service IP for in-cluster *.svc resolution (cloudflared needs this), then public resolvers.
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
  inlineManifests:
    - name: coredns-config
      contents: |
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: coredns
          namespace: kube-system
        data:
          Corefile: |-
            .:53 {
                errors
                health {
                    lameduck 5s
                }
                ready
                log . {
                    class error
                }
                prometheus :9153

                kubernetes cluster.local in-addr.arpa ip6.arpa {
                    pods insecure
                    fallthrough in-addr.arpa ip6.arpa
                    ttl 30
                }

                # Explicit upstream resolvers to avoid recursive loop via /etc/resolv.conf
                forward . 1.1.1.1 1.0.0.1 {
                  max_concurrent 1000
                }

                cache 30 {
                  disable success cluster.local
                  disable denial cluster.local
                }
                loop
                reload
                loadbalance
            }
