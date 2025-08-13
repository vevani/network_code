# Customer A

Environments live under `environments/{dev,staging,prod}` and use local state by default.

Usage (example: prod):

```
export MERAKI_DASHBOARD_API_KEY=... # required
cd environments/prod
tofu init
tofu plan -var-file=terraform.tfvars
tofu apply -var-file=terraform.tfvars
```

Adjust `terraform.tfvars` per environment to set `meraki_org_name`, `customer_slug`, and `environment`.


