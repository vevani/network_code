# Architecture Overview

This repository organizes OpenTofu configuration and Ansible automation for multi-customer, multi-environment network deployments across three technology stacks: Cisco Meraki, Cisco Catalyst SD-WAN, and Palo Alto Networks PAN-OS.

## OpenTofu Layer (`opentofu/`)

- `opentofu/modules/` provide reusable, composable building blocks organized by vendor:
  - `opentofu/modules/cisco/meraki/` – Meraki networks, VLANs, switch port profiles, MX security, AutoVPN
  - `opentofu/modules/cisco/sdwan/` – Catalyst SD-WAN device templates and centralized VPN policy
  - `opentofu/modules/paloalto/` – PAN-OS address objects/groups, security policy, NAT policy
- Each customer has isolated `environments/` (dev, staging, prod) with separate state and provider initialization.
- Customer `shared/` resolves organization IDs by human-readable names and can be extended with other shared data/locals.

State management uses a simple `local` backend per environment by default; replace with a remote backend (e.g., S3/DynamoDB, GCS, AzureRM) for production.

Authentication:
- Meraki: `MERAKI_DASHBOARD_API_KEY` environment variable
- Catalyst SD-WAN: `SDWAN_USERNAME` / `SDWAN_PASSWORD` + vManage URL in `providers.tf`
- PAN-OS: `PANOS_HOSTNAME` / `PANOS_USERNAME` / `PANOS_PASSWORD` in `providers.tf`

## Ansible Layer (`ansible/`)

The `ansible/` directory mirrors the OpenTofu customer/environment structure with scalable, multi-vendor automation:

- **Inventories** (`ansible/inventories/`) — per-customer, per-environment inventory directories:
  - `ansible/inventories/customer-a/dev/` – dev hosts and group_vars
  - `ansible/inventories/customer-a/staging/` – staging hosts and group_vars
  - `ansible/inventories/customer-a/prod/` – prod hosts and group_vars
- **Roles** (`ansible/roles/`) — vendor-specific roles with modular sub-task files:
  - `ansible/roles/cisco_meraki/` – networks, firewall, content filtering, AutoVPN, VLANs
  - `ansible/roles/cisco_sdwan/` – auth, templates, attachments, centralized policy
  - `ansible/roles/paloalto/` – address objects, security rules, NAT rules, commit
- **Playbooks** (`ansible/playbooks/`) — end-to-end playbooks for each vendor plus a `site.yml` aggregator
- **Extension points** — `filter_plugins/` and `module_utils/` for custom logic

See [ansible/README.md](ansible/README.md) for setup and usage instructions.

## State Bootstrap from an Existing Meraki Org

For brownfield imports, use the helper script to populate the local state from an existing Meraki organization, aligning with the module structure:

```bash
pip install -r requirements.txt
export MERAKI_DASHBOARD_API_KEY=...
python scripts/meraki_to_state.py \
  --env-dir opentofu/customers/customer-a/environments/prod \
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

```bash
# List networks in an org (to discover exact names)
python scripts/meraki_to_state.py \
  --env-dir opentofu/customers/customer-a/environments/prod \
  --org-name "Customer A" \
  --list-networks

# Override expected names explicitly
python scripts/meraki_to_state.py \
  --env-dir opentofu/customers/customer-a/environments/prod \
  --org-name "Customer A" \
  --branch-network-name "cust-a-branch-prod" \
  --headquarters-network-name "cust-a-hq-prod"

# Or provide a JSON mapping
python scripts/meraki_to_state.py \
  --env-dir opentofu/customers/customer-a/environments/prod \
  --org-name "Customer A" \
  --network-map-json /absolute/path/network-map.json
```

## CI/CD Pipelines

GitHub Actions workflows automate validation and deployment:

- **`ci.yml`** — Continuous integration: OpenTofu format check, Ansible syntax check, Python lint and tests
- **`opentofu-deploy.yml`** — OpenTofu plan/apply with manual approval gates
- **`ansible-deploy.yml`** — Ansible playbook execution with customer/environment selection

See [`.github/workflows/`](.github/workflows/) for full configuration.

