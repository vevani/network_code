## Architecture Overview

This repository organizes OpenTofu configuration and Ansible automation for multi-customer, multi-environment network deployments across three technology stacks: Cisco Meraki, Cisco Catalyst SD-WAN, and Palo Alto Networks PAN-OS.

### OpenTofu layer

- Top-level `modules/` provide reusable, composable building blocks organized by vendor:
  - `modules/cisco/meraki/` – Meraki networks, VLANs, switch port profiles, MX security, AutoVPN
  - `modules/cisco/sdwan/` – Catalyst SD-WAN device templates and centralized VPN policy
  - `modules/paloalto/` – PAN-OS address objects/groups, security policy, NAT policy
- Each customer has isolated `environments/` (dev, staging, prod) with separate state and provider initialization.
- Customer `shared/` resolves organization IDs by human-readable names and can be extended with other shared data/locals.

State management uses a simple `local` backend per environment by default; replace with a remote backend (e.g., S3/DynamoDB, GCS, AzureRM) for production.

Authentication:
- Meraki: `MERAKI_DASHBOARD_API_KEY` environment variable
- Catalyst SD-WAN: `SDWAN_USERNAME` / `SDWAN_PASSWORD` + vManage URL in `providers.tf`
- PAN-OS: `PANOS_HOSTNAME` / `PANOS_USERNAME` / `PANOS_PASSWORD` in `providers.tf`

### Ansible layer

The `ansible/` directory mirrors the OpenTofu module structure:

- `ansible/roles/cisco_meraki/` – Meraki networks, security, content filtering, AutoVPN, VLANs
- `ansible/roles/cisco_sdwan/` – vManage device templates and centralized policy
- `ansible/roles/paloalto/` – PAN-OS address objects, security rules, NAT rules, commit
- `ansible/playbooks/` – end-to-end playbooks for each vendor
- `ansible/group_vars/` – per-vendor variable defaults (credentials via Vault)

See [ansible/README.md](ansible/README.md) for setup and usage instructions.

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


