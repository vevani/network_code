# Branch Baseline – Standardised Branch Office Deployment

This use-case configuration composes several OpenTofu modules to roll out a
complete branch office with a single `tofu apply`. It is designed as a
repeatable template: copy the directory, change `terraform.tfvars`, and deploy
another branch.

## What Gets Deployed

| # | Component | Module |
|---|-----------|--------|
| 1 | Core branch network + VLANs (workstation, server, VoIP) | `network`, `vlan` |
| 2 | MX security policies (L3/L7 firewall, content filtering) | `firewall-rules`, `content-filtering` |
| 3 | AutoVPN spoke → HQ hub | `autovpn` |
| 4 | Guest WiFi with full isolation | `guest-wifi` |
| 5 | Monitoring/management network (SNMP, syslog, restricted access) | `monitoring-network` |

## Quick Start

```bash
# 1. Initialise
cd opentofu/use-cases/branch-baseline
tofu init

# 2. Edit terraform.tfvars with your values
vim terraform.tfvars

# 3. Plan
tofu plan

# 4. Apply
tofu apply
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `meraki_org_name` | Meraki organization name | — |
| `customer_slug` | Customer identifier (kebab-case) | — |
| `environment` | Environment (dev/staging/prod) | — |
| `branch_name` | Branch office identifier | — |
| `hub_network_id` | HQ network ID for AutoVPN | — |
| `workstation_subnet` | Workstation VLAN subnet | `192.168.10.0/24` |
| `server_subnet` | Server VLAN subnet | `192.168.20.0/24` |
| `voip_subnet` | VoIP VLAN subnet | `192.168.40.0/24` |
| `guest_subnet` | Guest WiFi VLAN subnet | `10.200.0.0/24` |
| `mgmt_subnet` | Management VLAN subnet | `10.255.0.0/24` |
