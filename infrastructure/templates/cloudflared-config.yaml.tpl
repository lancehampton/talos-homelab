---
apiVersion: v1alpha1
kind: ExtensionServiceConfig
name: cloudflared
environment:
  - TUNNEL_TOKEN=${token}
