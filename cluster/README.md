# Cluster GitOps Layout

This directory houses all Argo CD managed state for the Talos homelab.

## Structure
- `app-of-apps/` Root bootstrap Application + kustomization aggregating all others.
- `projects/` Argo CD `AppProject` definitions (security boundaries, RBAC, destinations).
- `core/` Low-level cluster prerequisites (CNI, ingress controller, cert-manager, DNS, storage). (Traefik placeholder present.)
- `platform/` Shared platform services (Argo CD itself, monitoring, logging, backup, registry, etc.).
- `applications/` Homelab / user-facing workloads (to be added).

## Bootstrap Flow
1. Apply `cluster/app-of-apps/bootstrap.yaml` to the cluster after Talos control plane is up.
2. Argo CD installs itself (wave 0) and then reconciles remaining Applications listed in `cluster/app-of-apps/kustomization.yaml`.
3. Add new Applications by committing manifests into `core/`, `platform/`, or `applications/` and referencing them in the app-of-apps kustomization.

## Sync Ordering (Waves)
Use `metadata.annotations.argocd.argoproj.io/sync-wave`:
- 0: Argo CD, CRDs.
- 5: Core infra (ingress, cert-manager, storage).
- 10: Platform services (monitoring, logging, backup).
- 20+: User applications.

## Expansion Plan
- Introduce `applicationsets/` for dynamic generation (multi-env or per-app patterns) when needed.
- Add additional `AppProject` objects for multi-tenant or environment scoping.
- Pin chart/app versions for platform stability.

## Security Notes
- Projects restrict source repos and destinations; expand carefully.
- Mark secrets using External Secrets or SOPS (future enhancement).

## Next Steps
- Populate `core/traefik` with a real Helm chart reference or use upstream chart via an Application.
- Add cert-manager, external-dns, and monitoring stack.
- Migrate Argo CD Service to ClusterIP once ingress is functional.
