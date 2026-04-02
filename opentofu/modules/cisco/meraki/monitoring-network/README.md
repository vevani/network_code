# Monitoring / Management Network Module

Provisions a dedicated management and monitoring network on Cisco Meraki.

## Use Case

Provide a secure, dedicated management plane for network monitoring tools
(Zabbix, PRTG, LibreNMS, etc.) and jump hosts. Includes SNMP configuration,
syslog forwarding, and strict firewall rules.

## Usage

```hcl
module "monitoring_network" {
  source = "../../../../modules/cisco/meraki/monitoring-network"

  organization_id = module.shared.meraki_org_id
  network_name    = "customer-a-monitoring-prod"
  tags            = ["customer-a", "prod", "monitoring"]

  mgmt_vlan_id      = 999
  mgmt_subnet       = "10.255.0.0/24"
  mgmt_appliance_ip = "10.255.0.1"

  snmp_enabled   = true
  snmp_access    = "community"
  snmp_community = var.snmp_community_string  # from vault / env var

  syslog_servers = [
    {
      host  = "10.255.0.10"
      port  = 514
      roles = ["Flows", "Security events", "Appliance event log"]
    }
  ]

  monitoring_allowed_subnets = [
    "10.0.100.0/24",  # NOC subnet
    "10.0.200.0/24",  # Jump host subnet
  ]
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `organization_id` | Meraki organization ID | `string` | — |
| `network_name` | Name of the monitoring network | `string` | — |
| `mgmt_vlan_id` | VLAN ID for the management segment | `number` | `999` |
| `mgmt_subnet` | Subnet for the management VLAN | `string` | `10.255.0.0/24` |
| `snmp_enabled` | Enable SNMP | `bool` | `true` |
| `snmp_community` | SNMP community string | `string` | `""` |
| `syslog_servers` | Syslog server list | `list(object)` | `[]` |
| `monitoring_allowed_subnets` | Subnets allowed management access | `list(string)` | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| `monitoring_network_id` | ID of the monitoring network |
| `mgmt_vlan_id` | VLAN ID of the management segment |
