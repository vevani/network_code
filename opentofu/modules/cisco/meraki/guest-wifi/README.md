# Guest WiFi Module

Provisions an isolated guest wireless network on Cisco Meraki with:

- Dedicated VLAN for guest traffic isolation
- Content filtering to block inappropriate URL categories
- L3 firewall rules preventing access to internal RFC1918 networks
- Bandwidth limiting per client

## Usage

```hcl
module "guest_wifi" {
  source = "../../../../modules/cisco/meraki/guest-wifi"

  organization_id = module.shared.meraki_org_id
  network_name    = "customer-a-guest-wifi-prod"
  tags            = ["customer-a", "prod", "guest"]

  guest_vlan_id      = 200
  guest_subnet       = "10.200.0.0/24"
  guest_appliance_ip = "10.200.0.1"

  bandwidth_limit_up   = 5000
  bandwidth_limit_down = 10000
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `organization_id` | Meraki organization ID | `string` | — |
| `network_name` | Name of the guest WiFi network | `string` | — |
| `guest_vlan_id` | VLAN ID for the guest network | `number` | `200` |
| `guest_subnet` | Subnet for the guest VLAN | `string` | `10.200.0.0/24` |
| `guest_appliance_ip` | Gateway IP for the guest VLAN | `string` | `10.200.0.1` |
| `blocked_url_categories` | URL categories to block | `list(object)` | Adult, Proxy |
| `guest_firewall_rules` | L3 firewall rules | `list(object)` | Deny RFC1918, allow web |

## Outputs

| Name | Description |
|------|-------------|
| `guest_network_id` | ID of the created guest network |
| `guest_vlan_id` | VLAN ID of the guest network |
