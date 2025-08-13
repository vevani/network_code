## Architecture Overview

This repository organizes OpenTofu configuration for multi-customer, multi-environment network deployments with Cisco Meraki.

- Top-level `modules/` provide reusable building blocks (Meraki networks, MX security, AutoVPN).
- Each customer has isolated `environments/` (dev, staging, prod) with separate state and provider initialization.
- Customer `shared/` resolves organization IDs by human-readable names and can be extended with other shared data/locals.

State management uses a simple `local` backend per environment by default; replace with a remote backend (e.g., S3/DynamoDB, GCS, AzureRM) for production.

Authentication is through `MERAKI_DASHBOARD_API_KEY` environment variable, injected via provider block defaults.

### State bootstrap from an existing Meraki org

For brownfield imports, use the helper script to populate the local state from an existing Meraki organization, aligning with the module structure:

```
pip install -r requirements.txt
export MERAKI_DASHBOARD_API_KEY=... # API key with org read access (and ideally write for later applies)
python scripts/meraki_to_state.py \
  --env-dir customers/customer-a/environments/prod \
  --org-name "Customer A" 
```

Notes:
- The script looks for networks named `${customer_slug}-branch-office-${environment}` and `${customer_slug}-hq-${environment}` and imports:
  - `meraki_networks` for each matching network
  - Singleton settings: `meraki_networks_settings`, `meraki_networks_vlans_settings` (if enabled)
  - For the branch network: MX L3/L7 firewall rules, content filtering, and AutoVPN
- It uses OpenTofu CLI (`tofu`). Override with `--tofu-bin` if needed.
- Use `--dry-run` to preview planned imports.

Advanced usage:

```
# List networks in an org (to discover exact names)
python scripts/meraki_to_state.py \
  --env-dir customers/customer-a/environments/prod \
  --org-name "Customer A" \
  --list-networks

# Override expected names explicitly
python scripts/meraki_to_state.py \
  --env-dir customers/customer-a/environments/prod \
  --org-name "Customer A" \
  --branch-network-name "cust-a-branch-prod" \
  --headquarters-network-name "cust-a-hq-prod"

# Or provide a JSON mapping
python scripts/meraki_to_state.py \
  --env-dir customers/customer-a/environments/prod \
  --org-name "Customer A" \
  --network-map-json /absolute/path/network-map.json
```


