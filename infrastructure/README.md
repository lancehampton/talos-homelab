## Infrastructure Module

This directory manages Talos cluster bootstrap, system extensions, and Cloudflare Zero Trust exposure using OpenTofu.

### Cloudflare Tunnel Pattern

Single external tunnel (created by Talos system extension) fronting all externally reachable apps:

* DNS: Each app gets a `CNAME` pointing at the tunnel's UUID hostname.
* Access: Only apps with `protected = true` in `var.apps` receive a Cloudflare Access Application + allow policy.
* Ingress: Terraform builds the ordered ingress rule list ending with a `http_status:404` catch-all.

No in-cluster ingress controller is required initially; Talos system extension `cloudflared` connects using the token provided via machine config patch. Terraform does NOT own the tunnel object; it only derives the tunnel CNAME via `tunnel_id` and (optionally) manages DNS and Access when those resources are enabled.

> [!NOTE]
> Unused locals and ingress rule generation were removed to reduce drift. Reintroduce them only if you later want Terraform-managed ingress (`cloudflare_zero_trust_tunnel_config`).

### Key Variables

* `domain` – Base domain (e.g. example.com)
* `cloudflare_account_id` / `cloudflare_zone_id` – Identify the Cloudflare zone
* `apps` – Map defining all published services
* `tunnel_name` – Optional override for tunnel naming

### Adding an App

1. Define the Kubernetes Service (ClusterIP) inside the cluster.
2. Append a new entry to `var.apps` (subdomain, internal service URL, protected flag).
3. `tofu plan && tofu apply` – DNS + tunnel config + (optional) Access policy are created.
4. Test the new hostname via browser or curl.

No Talos machine config change is required for app CRUD.

### Protecting an App Later

Flip `protected` to `true`, add allowed `emails` (or `groups` IDs), apply. Users will be challenged by Cloudflare Access SSO on next visit.

### Removing an App

Delete it from `var.apps` and apply; its DNS record, tunnel ingress rule, and Access resources are destroyed. Requests fall through to the 404 rule.

### Scaling Connectors

Enable the `cloudflared` Talos system extension on additional nodes (reusing the same token). Cloudflare automatically load-balances across healthy connectors.

### Future Path Routing / Ingress Controller

If you later need path-based fan-out or advanced HTTP middleware, introduce an ingress controller and point the tunnel at its ClusterIP Service instead of individual app Services. Until then, keep the stack lean.

### Security Notes

* Terraform state contains the tunnel secret; secure backend credentials (R2) are required.
* Use least-privilege Cloudflare API token (DNS:Edit, Zero Trust Tunnels & Access:Edit).
* Catch-all 404 prevents accidental exposure of unintended internal services.

### Rotation

`taint random_id.tunnel_secret && tofu apply` to rotate the tunnel secret; re-apply Talos machine configs so connectors pick up the new token.

### Importing an Existing Tunnel

If Talos already created the tunnel (name often matches `cluster_name`):

1. Retrieve the tunnel ID from Cloudflare Zero Trust dashboard.
2. Run:
	```bash
	tofu import cloudflare_tunnel.homelab <account_id>/<tunnel_id>
	```
3. Run `tofu plan` to verify only config/DNS/Access resources will be added.
4. Apply.

The resource omits `secret` so Terraform will not try to replace the imported tunnel. Rotation remains a manual action (update token in Talos + Cloudflare dashboard).

### Outputs

* `cloudflare_tunnel_id` – Tunnel identifier
* `cloudflare_tunnel_cname` – CNAME target for all app hostnames
* `cloudflare_access_protected_apps` – List of protected hostnames for quick audits

---

> [!NOTE]
> This setup intentionally avoids managing Cloudflare from within Kubernetes to keep lifecycle single-sourced in Terraform.
