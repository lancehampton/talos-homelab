# Cluster GitOps Layout

This directory houses all Argo CD managed state for the Talos homelab.

## Structure
- `app-of-apps/` Root bootstrap Application + kustomization aggregating all others.
- `projects/` Argo CD `AppProject` definitions.
- `apps/` All managed Applications (infrastructure + homelab). Add one file per app.

## Bootstrap Flow
1. Apply `cluster/app-of-apps/bootstrap.yaml` to the cluster after Talos control plane is up.
2. Argo CD installs itself (wave 0) and then reconciles remaining Applications listed in `cluster/app-of-apps/kustomization.yaml`.
3. Add new Applications by committing manifests into `core/`, `platform/`, or `applications/` and referencing them in the app-of-apps kustomization.

## Sync Ordering (Optional)
Avoid waves until you encounter ordering needs. If required later, annotate specific Application manifests with `argocd.argoproj.io/sync-wave`.

## Expansion Plan
- Split into logical tiers (e.g., core/platform) only if app count grows large (>8 infra services).
- Introduce ApplicationSets if you need pattern-based generation (multi-env or many similar apps).
- Pin chart/app versions for stability.

## Security Notes
- Projects restrict source repos and destinations; expand carefully.
- Mark secrets using External Secrets or SOPS (future enhancement).

## Next Steps
- Add Traefik, cert-manager, external-dns, monitoring stack as individual `apps/*.yaml` Application manifests referencing their Helm charts.
- Migrate Argo CD Service to ClusterIP once ingress is functional.
