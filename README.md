## OpenTofu Network Infrastructure

This repository provides a production-oriented OpenTofu (Terraform-compatible) structure for managing multi-customer, multi-environment network infrastructure with a focus on Cisco Meraki. It demonstrates:

- Modular design for reusability and composability
- Customer- and environment-scoped state separation
- Provider/version pinning and sensible defaults
- Real Meraki resources (networks, VLANs, MX security, AutoVPN)

Prerequisites:

- OpenTofu CLI installed
- Environment variable `MERAKI_DASHBOARD_API_KEY` exported with a valid API key for the target organization(s)

Quickstart (example for Customer A prod):

```
cd customers/customer-a/environments/prod
tofu init
tofu plan -var-file=terraform.tfvars
tofu apply -var-file=terraform.tfvars
```

Provider authentication uses `MERAKI_DASHBOARD_API_KEY`. Organization lookup is performed by name via the shared customer module.


