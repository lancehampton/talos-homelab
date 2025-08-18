---
apiVersion: v1alpha1
kind: ExtensionServiceConfig
name: tailscale
environment:
  - TS_AUTHKEY=${auth_key}
  - TS_ROUTES=10.96.0.0/12
