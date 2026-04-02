# Ansible Network Automation

This directory provides Ansible playbooks and roles for managing multi-customer, multi-environment network infrastructure across three technology stacks:

| Technology | Ansible Collection | Role |
|---|---|---|
| Cisco Meraki | `cisco.meraki` | `roles/cisco_meraki` |
| Cisco Catalyst SD-WAN | `cisco.catalystwan` | `roles/cisco_sdwan` |
| Palo Alto Networks PAN-OS | `paloaltonetworks.panos` | `roles/paloalto` |

## Directory Layout

```
ansible/
├── ansible.cfg                          # Ansible defaults (inventory path, callbacks, etc.)
├── requirements.yml                     # Galaxy collection requirements
├── inventories/                         # Multi-customer, multi-environment inventories
│   └── customer-a/
│       ├── dev/
│       │   ├── hosts.yml               # Inventory for dev environment
│       │   └── group_vars/
│       │       ├── all.yml             # Common variables (env name, customer name)
│       │       ├── cisco_meraki.yml    # Meraki-specific variables
│       │       ├── cisco_sdwan.yml     # SD-WAN-specific variables
│       │       └── paloalto.yml        # PAN-OS-specific variables
│       ├── staging/
│       │   ├── hosts.yml
│       │   └── group_vars/
│       └── prod/
│           ├── hosts.yml
│           └── group_vars/
├── roles/
│   ├── cisco_meraki/
│   │   ├── defaults/main.yml           # Role defaults
│   │   ├── handlers/main.yml           # Notification-driven tasks
│   │   ├── meta/main.yml               # Galaxy metadata
│   │   └── tasks/
│   │       ├── main.yml                # Orchestrator — includes sub-tasks
│   │       ├── networks.yml            # Network provisioning
│   │       ├── firewall.yml            # MX L3 firewall rules
│   │       ├── content_filtering.yml   # MX content filtering
│   │       ├── autovpn.yml             # AutoVPN site-to-site
│   │       └── vlans.yml               # VLAN configuration
│   ├── cisco_sdwan/
│   │   ├── defaults/main.yml
│   │   ├── handlers/main.yml
│   │   ├── meta/main.yml
│   │   └── tasks/
│   │       ├── main.yml                # Orchestrator — includes sub-tasks
│   │       ├── auth.yml                # vManage authentication
│   │       ├── templates.yml           # Device template management
│   │       ├── attachments.yml         # Template-to-device attachments
│   │       └── policy.yml              # Centralized VPN policy
│   └── paloalto/
│       ├── defaults/main.yml
│       ├── handlers/main.yml
│       ├── meta/main.yml
│       └── tasks/
│           ├── main.yml                # Orchestrator — includes sub-tasks
│           ├── address_objects.yml      # Address objects and groups
│           ├── security_policy.yml      # Security policy rules
│           ├── nat_policy.yml           # NAT rules
│           └── commit.yml               # Commit configuration
├── playbooks/
│   ├── site.yml                        # Run all vendor playbooks
│   ├── cisco_meraki.yml                # Meraki end-to-end playbook
│   ├── cisco_sdwan.yml                 # SD-WAN end-to-end playbook
│   ├── paloalto.yml                    # PAN-OS end-to-end playbook
│   ├── backup_configs.yml              # Backup network configurations
│   ├── network_audit.yml               # Configuration audit and compliance
│   ├── security_hardening.yml          # Security best-practice hardening
│   ├── vlan_management.yml             # VLAN lifecycle management
│   └── incident_response.yml           # Emergency containment and response
├── filter_plugins/                     # Custom Jinja2 filters
└── module_utils/                       # Shared module utilities
```

## Prerequisites

1. Install Ansible (>= 2.15):

   ```bash
   pip install ansible
   ```

2. Install required Galaxy collections:

   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

   The following collections will be installed:

   | Collection | Version |
   |---|---|
   | `cisco.meraki` | >= 2.18.0 |
   | `cisco.catalystwan` | >= 0.3.0 |
   | `paloaltonetworks.panos` | >= 2.19.0 |

3. Set required environment variables or vault secrets (see `inventories/` `group_vars` for variable names):

   | Technology | Environment Variables |
   |---|---|
   | Cisco Meraki | `MERAKI_DASHBOARD_API_KEY` |
   | Cisco Catalyst SD-WAN | `SDWAN_USERNAME`, `SDWAN_PASSWORD` |
   | Palo Alto Networks | `PANOS_USERNAME`, `PANOS_PASSWORD` |

## Running a Playbook

Specify the inventory for the target customer and environment with `-i`:

```bash
# Cisco Meraki — customer-a prod
ansible-playbook playbooks/cisco_meraki.yml -i inventories/customer-a/prod/

# Cisco Catalyst SD-WAN — customer-a dev
ansible-playbook playbooks/cisco_sdwan.yml -i inventories/customer-a/dev/

# Palo Alto Networks — customer-a prod, specific host
ansible-playbook playbooks/paloalto.yml -i inventories/customer-a/prod/ --limit pa_fw_01

# All vendors — customer-a staging
ansible-playbook playbooks/site.yml -i inventories/customer-a/staging/

# All vendors — only Meraki (using tags)
ansible-playbook playbooks/site.yml -i inventories/customer-a/prod/ --tags meraki
```

### Operational Playbooks

```bash
# Backup configurations — customer-a prod
ansible-playbook playbooks/backup_configs.yml -i inventories/customer-a/prod/

# Network audit — customer-a prod
ansible-playbook playbooks/network_audit.yml -i inventories/customer-a/prod/

# Security hardening — customer-a prod
ansible-playbook playbooks/security_hardening.yml -i inventories/customer-a/prod/

# VLAN lifecycle management — customer-a prod
ansible-playbook playbooks/vlan_management.yml -i inventories/customer-a/prod/

# Incident response — customer-a prod
ansible-playbook playbooks/incident_response.yml -i inventories/customer-a/prod/
```

## Adding a New Customer

1. Create a new customer directory under `inventories/`:
   ```bash
   mkdir -p inventories/customer-b/{dev,staging,prod}/group_vars
   ```
2. Copy and adapt the inventory files from an existing customer:
   ```bash
   cp inventories/customer-a/prod/hosts.yml inventories/customer-b/prod/hosts.yml
   cp inventories/customer-a/prod/group_vars/*.yml inventories/customer-b/prod/group_vars/
   ```
3. Update host addresses, credentials, and customer-specific variables.

## Using Ansible Vault for Credentials

```bash
# Create an encrypted secrets file for a specific customer/environment
ansible-vault create inventories/customer-a/prod/group_vars/vault.yml

# Run a playbook with vault
ansible-playbook playbooks/paloalto.yml -i inventories/customer-a/prod/ --ask-vault-pass
```
