# Network Infrastructure as Code

This monorepo manages multi-customer, multi-environment network infrastructure using two complementary automation tools:

| Tool | Directory | Purpose |
|---|---|---|
| **OpenTofu** | [`opentofu/`](opentofu/README.md) | Declarative infrastructure provisioning and state management |
| **Ansible** | [`ansible/`](ansible/README.md) | Imperative configuration management, orchestration, and day-2 operations |

Both tools support the same three vendor stacks:

- **Cisco Meraki** – Dashboard-managed networks, VLANs, MX security, AutoVPN
- **Cisco Catalyst SD-WAN** – vManage device templates and centralized VPN policy
- **Palo Alto Networks PAN-OS** – Address objects, security policy, NAT policy

## When to Use OpenTofu vs. Ansible

| Scenario | Recommended Tool | Reason |
|---|---|---|
| **Greenfield provisioning** — spinning up new networks, VLANs, or policies from scratch | OpenTofu | Declarative state tracking ensures reproducibility and drift detection |
| **Brownfield import** — adopting existing infrastructure into code | OpenTofu | `tofu import` and the helper script align live state with module definitions |
| **Day-2 configuration changes** — updating firewall rules, content filtering, or NAT policies | Either | OpenTofu for state-tracked changes; Ansible for ad-hoc or rolling updates |
| **Multi-device orchestration** — pushing config to many firewalls or routers in sequence | Ansible | Inventory-driven execution with `--limit` and rolling update strategies |
| **Compliance audits / drift detection** — verifying infrastructure matches desired state | OpenTofu | `tofu plan` highlights any drift from the declared configuration |
| **Emergency break-glass changes** — rapid config pushes outside normal workflow | Ansible | Playbook execution is immediate without state-file locking |
| **Template-driven device onboarding** — SD-WAN or switch templates to many devices | Ansible | Loop-based task execution scales well across large inventories |
| **Secret rotation** — rotating API keys, passwords, or certificates | Ansible | Vault integration and `no_log` provide secure credential handling |

## Repository Structure

```
.
├── README.md                       # This file
├── ARCHITECTURE.md                 # Detailed architecture documentation
├── Makefile                        # Top-level automation targets
├── requirements.txt                # Python dependencies (for scripts and tests)
├── .github/
│   └── workflows/                  # CI/CD pipelines
│       ├── ci.yml                  # Validation: lint, format, test
│       ├── opentofu-deploy.yml     # OpenTofu plan and apply
│       └── ansible-deploy.yml      # Ansible playbook execution
├── opentofu/                       # OpenTofu modules and customer environments
│   ├── README.md
│   ├── modules/                    # Reusable modules by vendor
│   │   ├── cisco/meraki/           # Networks, VLANs, MX security, AutoVPN, guest-wifi, DMZ, monitoring, WAN failover
│   │   ├── cisco/sdwan/
│   │   └── paloalto/
│   └── customers/                  # Per-customer, per-environment configs
│       └── customer-a/
│           ├── shared/
│           └── environments/{dev,staging,prod}/
├── ansible/                        # Ansible roles, playbooks, and inventories
│   ├── README.md
│   ├── roles/                      # Vendor-specific roles
│   │   ├── cisco_meraki/
│   │   ├── cisco_sdwan/
│   │   └── paloalto/
│   ├── playbooks/                  # End-to-end, site-wide, and operational playbooks
│   │   ├── site.yml                # Run all vendor playbooks
│   │   ├── cisco_meraki.yml        # Meraki end-to-end
│   │   ├── cisco_sdwan.yml         # SD-WAN end-to-end
│   │   ├── paloalto.yml            # PAN-OS end-to-end
│   │   ├── backup_configs.yml      # Backup network configurations
│   │   ├── network_audit.yml       # Configuration audit and compliance
│   │   ├── security_hardening.yml  # Security best-practice hardening
│   │   ├── vlan_management.yml     # VLAN lifecycle management
│   │   └── incident_response.yml   # Emergency containment and response
│   └── inventories/                # Per-customer, per-environment inventories
│       └── customer-a/{dev,staging,prod}/
├── scripts/                        # Helper utilities
│   └── meraki_to_state.py          # Brownfield import for Meraki → OpenTofu state
└── tests/                          # Python unit tests
    └── test_meraki_to_state.py
```

## Quick Start

### OpenTofu

```bash
cd opentofu/customers/customer-a/environments/prod
tofu init
tofu plan -var-file=terraform.tfvars
tofu apply -var-file=terraform.tfvars
```

### Ansible

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/site.yml -i inventories/customer-a/prod/
```

## Prerequisites

| Requirement | Version |
|---|---|
| OpenTofu CLI | >= 1.11.5 |
| Ansible | >= 2.15 |
| Python | >= 3.12 |

### Ansible Collection Requirements

| Collection | Version |
|---|---|
| `cisco.meraki` | >= 2.18.0 |
| `cisco.catalystwan` | >= 0.3.0 |
| `paloaltonetworks.panos` | >= 2.19.0 |

### Environment Variables

| Technology | Variables |
|---|---|
| Cisco Meraki | `MERAKI_DASHBOARD_API_KEY` |
| Cisco Catalyst SD-WAN | `SDWAN_USERNAME`, `SDWAN_PASSWORD` |
| Palo Alto Networks | `PANOS_HOSTNAME`, `PANOS_USERNAME`, `PANOS_PASSWORD` |

> **Security**: Never hardcode credentials. Use environment variables, Ansible Vault, or an external secrets manager.

## CI/CD

The repository includes GitHub Actions workflows:

- **`ci.yml`** — Runs on every push and pull request. Validates OpenTofu formatting, Ansible syntax, and Python tests.
- **`opentofu-deploy.yml`** — Manually triggered. Runs `tofu plan` and optionally `tofu apply` for a specified customer/environment.
- **`ansible-deploy.yml`** — Manually triggered. Executes an Ansible playbook against a specified customer/environment.

See [`.github/workflows/`](.github/workflows/) for configuration details.

## Contributing

1. Create a feature branch from `main`.
2. Make changes and ensure CI passes (`make validate`, `make test`).
3. Submit a pull request for review.

