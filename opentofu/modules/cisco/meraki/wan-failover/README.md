# WAN Failover Module

Configures dual-WAN uplinks on a Cisco Meraki MX appliance for automatic
failover and optional load balancing.

## Use Case

Ensure business continuity by configuring a secondary ISP connection that
activates automatically when the primary WAN link fails. Optionally distribute
traffic across both links for better utilisation.

## Usage

```hcl
module "wan_failover" {
  source = "../../../../modules/cisco/meraki/wan-failover"

  network_id = module.branch_office_network.network_id

  wan1_enabled       = true
  wan1_using_static_ip = true
  wan1_static_ip         = "203.0.113.10"
  wan1_static_gateway_ip = "203.0.113.1"
  wan1_static_subnet_mask = "255.255.255.0"

  wan2_enabled       = true
  wan2_using_static_ip = false  # DHCP on secondary link

  load_balancing_enabled = false
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `network_id` | Target Meraki network ID | `string` | — |
| `wan1_enabled` | Enable WAN 1 uplink | `bool` | `true` |
| `wan1_using_static_ip` | Use static IP on WAN 1 | `bool` | `false` |
| `wan2_enabled` | Enable WAN 2 for failover | `bool` | `true` |
| `wan2_using_static_ip` | Use static IP on WAN 2 | `bool` | `false` |
| `load_balancing_enabled` | Load balance across uplinks | `bool` | `false` |
| `traffic_shaping_rules` | Traffic shaping rules | `list(object)` | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| `wan1_enabled` | Whether WAN 1 is enabled |
| `wan2_enabled` | Whether WAN 2 is enabled |
