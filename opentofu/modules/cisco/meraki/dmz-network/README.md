# DMZ Network Module

Provisions a DMZ (demilitarized zone) network on Cisco Meraki with strict
segmentation between the DMZ, internal networks, and the internet.

## Use Case

Host public-facing services (web servers, mail relays, reverse proxies) in a
segmented network that prevents lateral movement to internal corporate
resources.

## Usage

```hcl
module "dmz" {
  source = "../../../../modules/cisco/meraki/dmz-network"

  organization_id = module.shared.meraki_org_id
  network_name    = "customer-a-dmz-prod"
  tags            = ["customer-a", "prod", "dmz"]

  dmz_vlan_id      = 50
  dmz_subnet       = "172.16.50.0/24"
  dmz_appliance_ip = "172.16.50.1"

  internal_subnets          = ["10.0.0.0/8", "192.168.0.0/16"]
  dmz_allowed_inbound_ports = ["443", "80"]
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `organization_id` | Meraki organization ID | `string` | — |
| `network_name` | Name of the DMZ network | `string` | — |
| `dmz_vlan_id` | VLAN ID for the DMZ | `number` | `50` |
| `dmz_subnet` | Subnet for the DMZ VLAN | `string` | `172.16.50.0/24` |
| `internal_subnets` | Internal subnets to isolate from DMZ | `list(string)` | RFC1918 |
| `dmz_allowed_inbound_ports` | Ports to allow inbound to DMZ | `list(string)` | `443, 80` |

## Outputs

| Name | Description |
|------|-------------|
| `dmz_network_id` | ID of the DMZ network |
| `dmz_vlan_id` | VLAN ID of the DMZ segment |
