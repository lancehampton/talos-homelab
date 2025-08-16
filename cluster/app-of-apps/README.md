# App of Apps Root

This directory contains the root (bootstrap) Argo CD Application and supporting kustomization.

## Files
- `bootstrap.yaml` - Root Application applied manually (kubectl/talosctl) to install Argo CD + recurse.
- `kustomization.yaml` - Lists all Argo CD Application manifests (platform, core, apps, projects).

## Sync Waves
- Wave 0: Argo CD itself and required CRDs.
- Wave 5: Core infrastructure (ingress, cert-manager, DNS, storage drivers, etc.).
- Wave 10+: Platform services (monitoring, logging, GitOps addons).
- Wave 20+: Homelab applications.

## Expansion
Add new Applications under `cluster/core`, `cluster/platform`, or `cluster/applications` and reference them here via kustomize. Optionally migrate to ApplicationSet when patterns emerge.
