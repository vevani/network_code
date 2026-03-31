## OpenTofu Network Infrastructure

This repository provides a production-oriented OpenTofu (Terraform-compatible) structure for managing multi-customer, multi-environment network infrastructure across three technology stacks:

- **Cisco Meraki** – networks, VLANs, MX security, AutoVPN, switch port profiles
- **Cisco Catalyst SD-WAN** – vEdge device templates and centralized VPN policy
- **Palo Alto Networks PAN-OS** – address objects/groups, security policy, NAT policy

It also contains an equivalent **Ansible** directory (`ansible/`) with roles and playbooks for the same three stacks (see [ansible/README.md](ansible/README.md)).

Core principles:

- Modular design for reusability and composability
- Customer- and environment-scoped state separation
- Provider/version pinning and sensible defaults

### OpenTofu – module catalogue

| Vendor | Module path | Purpose |
|---|---|---|
| Cisco Meraki | `modules/cisco/meraki/network` | Network + VLAN settings |
| Cisco Meraki | `modules/cisco/meraki/vlan` | MX appliance VLAN configuration |
| Cisco Meraki | `modules/cisco/meraki/switch-port-profile` | Switch port profiles |
| Cisco Meraki | `modules/cisco/meraki/mx-security/firewall-rules` | L3/L7 firewall rules |
| Cisco Meraki | `modules/cisco/meraki/mx-security/content-filtering` | Content filtering |
| Cisco Meraki | `modules/cisco/meraki/autovpn` | AutoVPN site-to-site |
| Cisco Catalyst SD-WAN | `modules/cisco/sdwan/vedge-template` | Feature device templates |
| Cisco Catalyst SD-WAN | `modules/cisco/sdwan/vpn-policy` | Centralized VPN policy |
| Palo Alto | `modules/paloalto/address-object` | Address objects and groups |
| Palo Alto | `modules/paloalto/security-policy` | Security policy rule groups |
| Palo Alto | `modules/paloalto/nat-policy` | NAT rule groups |

### OpenTofu – prerequisites

- OpenTofu CLI installed (>= 1.6)
- `MERAKI_DASHBOARD_API_KEY` – for Meraki modules
- `SDWAN_USERNAME` / `SDWAN_PASSWORD` + vManage URL configured in `providers.tf` – for SD-WAN modules
- `PANOS_HOSTNAME` / `PANOS_USERNAME` / `PANOS_PASSWORD` configured in `providers.tf` – for PAN-OS modules

### OpenTofu – quickstart (Customer A prod)

```
cd customers/customer-a/environments/prod
tofu init
tofu plan -var-file=terraform.tfvars
tofu apply -var-file=terraform.tfvars
```

Provider authentication uses `MERAKI_DASHBOARD_API_KEY`. Organization lookup is performed by name via the shared customer module.


