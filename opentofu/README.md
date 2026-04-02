# OpenTofu Network Infrastructure

This directory contains the OpenTofu (Terraform-compatible) configuration for managing multi-customer, multi-environment network infrastructure across three technology stacks:

- **Cisco Meraki** – networks, VLANs, MX security, AutoVPN, switch port profiles
- **Cisco Catalyst SD-WAN** – vEdge device templates and centralized VPN policy
- **Palo Alto Networks PAN-OS** – address objects/groups, security policy, NAT policy

## Directory Layout

```
opentofu/
├── modules/                              # Reusable, composable building blocks
│   ├── cisco/
│   │   ├── meraki/
│   │   │   ├── network/                  # Network + VLAN settings
│   │   │   ├── vlan/                     # MX appliance VLAN configuration
│   │   │   ├── switch-port-profile/      # Switch port profiles
│   │   │   ├── mx-security/
│   │   │   │   ├── firewall-rules/       # L3/L7 firewall rules
│   │   │   │   └── content-filtering/    # Content filtering
│   │   │   ├── autovpn/                  # AutoVPN site-to-site
│   │   │   ├── monitoring-network/       # Management and monitoring network
│   │   │   ├── wan-failover/             # Dual-WAN uplink failover
│   │   │   ├── guest-wifi/               # Isolated guest wireless network
│   │   │   └── dmz-network/              # DMZ network segmentation
│   │   └── sdwan/
│   │       ├── vedge-template/           # Feature device templates
│   │       └── vpn-policy/               # Centralized VPN policy
│   └── paloalto/
│       ├── address-object/               # Address objects and groups
│       ├── security-policy/              # Security policy rule groups
│       └── nat-policy/                   # NAT rule groups
└── customers/
    └── customer-a/
        ├── shared/                       # Shared data lookups (org IDs, etc.)
        └── environments/
            ├── dev/
            ├── staging/
            └── prod/
```

## Module Catalogue

| Vendor | Module Path | Purpose |
|---|---|---|
| Cisco Meraki | `modules/cisco/meraki/network` | Network + VLAN settings |
| Cisco Meraki | `modules/cisco/meraki/vlan` | MX appliance VLAN configuration |
| Cisco Meraki | `modules/cisco/meraki/switch-port-profile` | Switch port profiles |
| Cisco Meraki | `modules/cisco/meraki/mx-security/firewall-rules` | L3/L7 firewall rules |
| Cisco Meraki | `modules/cisco/meraki/mx-security/content-filtering` | Content filtering |
| Cisco Meraki | `modules/cisco/meraki/autovpn` | AutoVPN site-to-site |
| Cisco Meraki | `modules/cisco/meraki/monitoring-network` | Management and monitoring network |
| Cisco Meraki | `modules/cisco/meraki/wan-failover` | Dual-WAN uplink failover |
| Cisco Meraki | `modules/cisco/meraki/guest-wifi` | Isolated guest wireless network |
| Cisco Meraki | `modules/cisco/meraki/dmz-network` | DMZ network segmentation |
| Cisco Catalyst SD-WAN | `modules/cisco/sdwan/vedge-template` | Feature device templates |
| Cisco Catalyst SD-WAN | `modules/cisco/sdwan/vpn-policy` | Centralized VPN policy |
| Palo Alto | `modules/paloalto/address-object` | Address objects and groups |
| Palo Alto | `modules/paloalto/security-policy` | Security policy rule groups |
| Palo Alto | `modules/paloalto/nat-policy` | NAT rule groups |

## Prerequisites

- OpenTofu CLI (>= 1.11.5)
- Environment variables for provider authentication:

| Technology | Environment Variables |
|---|---|
| Cisco Meraki | `MERAKI_DASHBOARD_API_KEY` |
| Cisco Catalyst SD-WAN | `SDWAN_USERNAME`, `SDWAN_PASSWORD` + vManage URL in `providers.tf` |
| Palo Alto Networks | `PANOS_HOSTNAME`, `PANOS_USERNAME`, `PANOS_PASSWORD` in `providers.tf` |

## Quickstart

```bash
# Navigate to a customer environment
cd opentofu/customers/customer-a/environments/prod

# Initialise providers and modules
tofu init

# Preview changes
tofu plan -var-file=terraform.tfvars

# Apply configuration
tofu apply -var-file=terraform.tfvars
```

## Adding a New Customer

1. Create a new directory under `customers/`:
   ```
   mkdir -p customers/customer-b/environments/{dev,staging,prod}
   mkdir -p customers/customer-b/shared
   ```
2. Copy and adapt the `shared/` data lookups from an existing customer.
3. Copy an environment directory (e.g. `customer-a/environments/prod/`) as a template.
4. Update `terraform.tfvars` with customer-specific values.

## State Management

Each environment uses a `local` backend by default. For production deployments, replace with a remote backend (e.g. S3/DynamoDB, GCS, AzureRM) by updating `backend.tf`.

## Brownfield Import

For importing existing infrastructure into state, use the helper script:

```bash
pip install -r requirements.txt
export MERAKI_DASHBOARD_API_KEY=...
python scripts/meraki_to_state.py \
  --env-dir opentofu/customers/customer-a/environments/prod \
  --org-name "Customer A"
```

See [`scripts/meraki_to_state.py`](../scripts/meraki_to_state.py) for full usage documentation.
