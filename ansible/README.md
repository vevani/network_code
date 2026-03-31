## Ansible Automation

This directory mirrors the OpenTofu module structure and provides Ansible playbooks and roles for the same three network technology stacks:

| Technology | Ansible Collection | Role |
|---|---|---|
| Cisco Meraki | `cisco.meraki` | `roles/cisco_meraki` |
| Cisco Catalyst SD-WAN | `cisco.catalystwan` | `roles/cisco_sdwan` |
| Palo Alto Networks PAN-OS | `paloaltonetworks.panos` | `roles/paloalto` |

### Directory layout

```
ansible/
├── ansible.cfg                    # Ansible defaults (inventory path, callbacks, etc.)
├── requirements.yml               # Galaxy collection requirements
├── inventory/
│   └── hosts.yml                  # Sample static inventory
├── group_vars/
│   ├── all/main.yml               # Variables common to all hosts
│   ├── cisco_meraki/main.yml      # Meraki-specific defaults
│   ├── cisco_sdwan/main.yml       # SD-WAN-specific defaults
│   └── paloalto/main.yml          # PAN-OS-specific defaults
├── roles/
│   ├── cisco_meraki/              # Tasks, defaults, and meta for Meraki
│   ├── cisco_sdwan/               # Tasks, defaults, and meta for Catalyst SD-WAN
│   └── paloalto/                  # Tasks, defaults, and meta for PAN-OS
└── playbooks/
    ├── cisco_meraki.yml           # Meraki end-to-end playbook
    ├── cisco_sdwan.yml            # SD-WAN end-to-end playbook
    └── paloalto.yml               # PAN-OS end-to-end playbook
```

### Prerequisites

1. Install Ansible (>= 2.15):

   ```
   pip install ansible
   ```

2. Install required Galaxy collections:

   ```
   ansible-galaxy collection install -r requirements.yml
   ```

3. Set required environment variables / vault secrets (see `group_vars/` for variable names):

   | Technology | Environment Variable |
   |---|---|
   | Cisco Meraki | `MERAKI_DASHBOARD_API_KEY` |
   | Cisco Catalyst SD-WAN | `SDWAN_USERNAME`, `SDWAN_PASSWORD` |
   | Palo Alto Networks | `PANOS_USERNAME`, `PANOS_PASSWORD` |

### Running a playbook

```bash
# Cisco Meraki
ansible-playbook playbooks/cisco_meraki.yml

# Cisco Catalyst SD-WAN
ansible-playbook playbooks/cisco_sdwan.yml

# Palo Alto Networks (all hosts)
ansible-playbook playbooks/paloalto.yml

# Palo Alto Networks (specific host)
ansible-playbook playbooks/paloalto.yml --limit pa_fw_01
```

### Using Ansible Vault for credentials

```bash
# Create an encrypted secrets file
ansible-vault create group_vars/all/vault.yml

# Run a playbook with vault
ansible-playbook playbooks/paloalto.yml --ask-vault-pass
```
