#!/usr/bin/env python3
"""
Populate local OpenTofu (Terraform-compatible) state from an existing Meraki organization.

This utility discovers networks and singleton settings in a given Meraki organization
and imports them into the local state for a specific environment directory, aligning
with module/resource addresses defined in this repository.

Requirements:
- Environment variable MERAKI_DASHBOARD_API_KEY must be set
- Python packages: meraki, python-hcl2
- OpenTofu CLI available on PATH (defaults to 'tofu')

Example:
  python network-infra/scripts/meraki_to_state.py \
    --env-dir /home/user/projects/network_code/network-infra/customers/customer-a/environments/prod

Notes:
- This script targets the module structure in this repository (branch + HQ networks
  and related MX settings for the branch network). Adjust or extend mappings as needed.
"""
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
import re
import platform
from typing import Dict, List, Optional, Tuple

import meraki  # type: ignore
import hcl2  # type: ignore


class CommandError(RuntimeError):
    pass


def run_cmd(command: List[str], cwd: Path, env: Optional[Dict[str, str]] = None) -> Tuple[int, str, str]:
    process = subprocess.Popen(
        command,
        cwd=str(cwd),
        env=env or os.environ.copy(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    out, err = process.communicate()
    return process.returncode, out, err


def ensure_tofu_initialized(env_dir: Path, tofu_bin: str) -> None:
    if not (env_dir / ".terraform").exists():
        code, out, err = run_cmd([tofu_bin, "init", "-input=false", "-upgrade"], cwd=env_dir)
        if code != 0:
            raise CommandError(f"tofu init failed: {err or out}")


def import_state(env_dir: Path, tofu_bin: str, address: str, import_id: str) -> None:
    command = [tofu_bin, "import", "-input=false", "-lock=false", address, import_id]
    code, out, err = run_cmd(command, cwd=env_dir)
    # idempotency: treat already-managed as success
    already_msg = "Resource already managed by state" in (out + err)
    if code != 0 and not already_msg:
        raise CommandError(f"tofu import failed for {address} with id {import_id}: {err or out}")


def read_tfvars(tfvars_path: Path) -> Dict[str, object]:
    with tfvars_path.open("r", encoding="utf-8") as f:
        content = f.read()
    # hcl2 loads to python types
    data = hcl2.loads(content)
    return data


def resolve_org_id(dashboard: meraki.DashboardAPI, target_org_name: Optional[str]) -> Tuple[str, str]:
    orgs = dashboard.organizations.getOrganizations()
    if not orgs:
        raise RuntimeError("No organizations available to the API key.")
    if target_org_name:
        for org in orgs:
            if org.get("name", "").lower() == target_org_name.lower():
                return org["id"], org["name"]
        raise RuntimeError(f"Organization named '{target_org_name}' not found for the API key.")
    # default to first if not provided
    return orgs[0]["id"], orgs[0]["name"]


def fetch_networks_by_name(dashboard: meraki.DashboardAPI, org_id: str) -> Dict[str, Dict[str, object]]:
    networks: List[Dict[str, object]] = dashboard.organizations.getOrganizationNetworks(org_id, total_pages="all")
    by_name: Dict[str, Dict[str, object]] = {}
    for net in networks:
        name = str(net.get("name", ""))
        if name:
            by_name[name] = net
    return by_name


def planned_network_names(customer_slug: str, environment: str) -> Dict[str, str]:
    # Default naming patterns used by this repo's modules
    return {
        "branch_office_network": f"{customer_slug}-branch-office-{environment}",
        "headquarters_network": f"{customer_slug}-hq-{environment}",
    }


def build_import_plan(
    env_dir: Path,
    tfvars: Dict[str, object],
    networks_by_name: Dict[str, Dict[str, object]],
    name_overrides: Optional[Dict[str, str]] = None,
) -> List[Tuple[str, str]]:
    """Return list of (address, import_id) pairs to import.

    Assumes all singleton resources import by network_id.
    """
    customer_slug = str(tfvars.get("customer_slug"))
    environment = str(tfvars.get("environment"))
    enable_vlans_default = True  # modules set this true by default; safe to try import

    names = planned_network_names(customer_slug, environment)
    if name_overrides:
        names.update({k: v for k, v in name_overrides.items() if v})

    plan: List[Tuple[str, str]] = []

    def add_network_module_imports(module_name: str, network_id: str, enable_vlans: bool = enable_vlans_default) -> None:
        # meraki_networks
        plan.append((f"module.{module_name}.meraki_networks.this", network_id))
        # settings singletons
        plan.append((f"module.{module_name}.meraki_networks_settings.this", network_id))
        # vlans settings is count-based
        if enable_vlans:
            plan.append((f"module.{module_name}.meraki_networks_vlans_settings.this[0]", network_id))

    # Branch office network (and downstream MX settings modules)
    branch_name = names["branch_office_network"]
    branch = networks_by_name.get(branch_name)
    if branch:
        branch_id = str(branch.get("id"))
        add_network_module_imports("branch_office_network", branch_id)
        # MX L3/L7 firewall, content filtering, AutoVPN are singletons keyed by network_id
        plan.append(("module.branch_security_policies.meraki_networks_appliance_firewall_l3_firewall_rules.this", branch_id))
        plan.append(("module.branch_security_policies.meraki_networks_appliance_firewall_l7_firewall_rules.this", branch_id))
        plan.append(("module.branch_content_filtering.meraki_networks_appliance_content_filtering.this", branch_id))
        plan.append(("module.branch_autovpn.meraki_networks_appliance_vpn_site_to_site.this", branch_id))

    # Headquarters network
    hq_name = names["headquarters_network"]
    hq = networks_by_name.get(hq_name)
    if hq:
        hq_id = str(hq.get("id"))
        add_network_module_imports("headquarters_network", hq_id)

    # Networks declared via unified for_each (module.networks[<key>])
    networks_var = tfvars.get("networks")
    # Backward-compat: if only additional_networks exists, use it
    if not isinstance(networks_var, dict):
        networks_var = tfvars.get("additional_networks") if isinstance(tfvars.get("additional_networks"), dict) else {}
    if isinstance(networks_var, dict):
        for key, spec in networks_var.items():
            net_name = None
            if isinstance(spec, dict) and "name" in spec and spec["name"]:
                net_name = str(spec["name"])
            else:
                net_name = str(key)
            net = networks_by_name.get(net_name)
            if not net:
                continue
            net_id = str(net.get("id"))
            # Base network resources
            plan.append((f"module.networks[\"{key}\"].meraki_networks.this", net_id))
            plan.append((f"module.networks[\"{key}\"].meraki_networks_settings.this", net_id))
            if bool(spec.get("enable_vlans", True)) if isinstance(spec, dict) else True:
                plan.append((f"module.networks[\"{key}\"].meraki_networks_vlans_settings.this[0]", net_id))
            # Optional security/content filtering/autovpn
            if isinstance(spec, dict) and bool(spec.get("include_security", False)):
                plan.append((f"module.networks_security[\"{key}\"].meraki_networks_appliance_firewall_l3_firewall_rules.this", net_id))
                plan.append((f"module.networks_security[\"{key}\"].meraki_networks_appliance_firewall_l7_firewall_rules.this", net_id))
            if isinstance(spec, dict) and bool(spec.get("include_content_filtering", False)):
                plan.append((f"module.networks_content_filtering[\"{key}\"].meraki_networks_appliance_content_filtering.this", net_id))
            if isinstance(spec, dict) and bool(spec.get("include_autovpn", False)):
                plan.append((f"module.networks_autovpn[\"{key}\"].meraki_networks_appliance_vpn_site_to_site.this", net_id))

    return plan


def main() -> None:
    parser = argparse.ArgumentParser(description="Import existing Meraki org resources into local OpenTofu state for a given environment.")
    parser.add_argument("--env-dir", required=True, help="Absolute path to environment directory (contains main.tf, terraform.tfvars, backend.tf)")
    parser.add_argument("--org-name", default=None, help="Meraki organization name (defaults to value in terraform.tfvars if present)")
    parser.add_argument("--tofu-bin", default=os.environ.get("TOFU_BIN", "tofu"), help="OpenTofu binary name or absolute path. Default: tofu")
    parser.add_argument("--dry-run", action="store_true", help="Print planned imports without executing")
    parser.add_argument("--branch-network-name", default=None, help="Explicit name for the branch office network (overrides naming convention)")
    parser.add_argument("--headquarters-network-name", default=None, help="Explicit name for the headquarters network (overrides naming convention)")
    parser.add_argument("--network-map-json", default=None, help="Path to JSON with name overrides: { 'branch_office_network': '...', 'headquarters_network': '...' }")
    parser.add_argument("--list-networks", action="store_true", help="List networks in the resolved organization and exit")
    args = parser.parse_args()

    api_key = os.environ.get("MERAKI_DASHBOARD_API_KEY")
    if not api_key:
        print("MERAKI_DASHBOARD_API_KEY is not set", file=sys.stderr)
        sys.exit(2)

    env_dir = Path(args.env_dir).resolve()
    if not env_dir.exists():
        print(f"Environment directory does not exist: {env_dir}", file=sys.stderr)
        sys.exit(2)

    tfvars_path = env_dir / "terraform.tfvars"
    if not tfvars_path.exists():
        print(f"terraform.tfvars not found in {env_dir}", file=sys.stderr)
        sys.exit(2)

    try:
        tfvars = read_tfvars(tfvars_path)
    except Exception as ex:
        print(f"Failed to parse terraform.tfvars: {ex}", file=sys.stderr)
        sys.exit(2)

    # Allow overriding org-name via CLI; otherwise use tfvars
    org_name: Optional[str] = args.org_name or (
        str(tfvars.get("meraki_org_name")) if tfvars.get("meraki_org_name") is not None else None
    )

    # Initialize Meraki SDK
    # Meraki SDK requires a well-formed User-Agent: "Application/Version Vendor" (single words)
    # Allow full override via MERAKI_SDK_CALLER. Otherwise, compose from parts with sanitation.
    ua_pattern = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\s+[A-Za-z0-9_.-]+$")

    caller_str = os.environ.get("MERAKI_SDK_CALLER")
    if not caller_str:
        app = os.environ.get("MERAKI_SDK_APP", "NetworkImporter")
        version = os.environ.get("MERAKI_SDK_VERSION", "1.0.0")
        vendor = os.environ.get("MERAKI_SDK_VENDOR", (platform.node() or "Local"))
        # sanitize to allowed chars
        def sanitize(value: str) -> str:
            return re.sub(r"[^A-Za-z0-9_.-]", "", value) or "X"
        app = sanitize(app)
        version = sanitize(version)
        vendor = sanitize(vendor)
        caller_str = f"{app}/{version} {vendor}"

    if not ua_pattern.match(caller_str):
        print(
            "Invalid Meraki SDK caller string. Expected 'Application/Version Vendor' with single-word tokens.\n"
            "You can set MERAKI_SDK_CALLER explicitly (e.g., 'NetImporter/1.0 AcmeCorp') or parts via MERAKI_SDK_APP, MERAKI_SDK_VERSION, MERAKI_SDK_VENDOR.",
            file=sys.stderr,
        )
        print(f"Current value: '{caller_str}'", file=sys.stderr)
        sys.exit(2)
    dashboard = meraki.DashboardAPI(
        api_key,
        print_console=False,
        suppress_logging=True,
        caller=caller_str,
    )

    try:
        org_id, resolved_org_name = resolve_org_id(dashboard, org_name)
    except Exception as ex:
        print(f"Failed to resolve organization: {ex}", file=sys.stderr)
        sys.exit(2)

    networks_by_name = fetch_networks_by_name(dashboard, org_id)

    if args.list_networks:
        printable = [
            {"name": name, "id": data.get("id"), "productTypes": data.get("productTypes")}
            for name, data in sorted(networks_by_name.items())
        ]
        print(json.dumps({
            "organization_name": resolved_org_name,
            "organization_id": org_id,
            "networks": printable,
        }, indent=2))
        return

    # optional name overrides
    name_overrides: Dict[str, str] = {}
    if args.network_map_json:
        try:
            with open(args.network_map_json, "r", encoding="utf-8") as f:
                name_overrides.update(json.load(f))
        except Exception as ex:
            print(f"Failed to read --network-map-json: {ex}", file=sys.stderr)
            sys.exit(2)
    if args.branch_network_name:
        name_overrides["branch_office_network"] = args.branch_network_name
    if args.headquarters_network_name:
        name_overrides["headquarters_network"] = args.headquarters_network_name

    import_plan = build_import_plan(env_dir, tfvars, networks_by_name, name_overrides=name_overrides)
    if not import_plan:
        expected = planned_network_names(str(tfvars.get("customer_slug")), str(tfvars.get("environment")))
        expected.update({k: v for k, v in name_overrides.items() if v})
        preview_names = ", ".join(list(networks_by_name.keys())[:20])
        print(
            "No imports to perform (no matching networks found).\n" \
            f"Expected names: branch='{expected.get('branch_office_network')}', hq='{expected.get('headquarters_network')}'.\n" \
            f"Available (first 20): {preview_names}",
            file=sys.stderr,
        )
        sys.exit(3)

    print(json.dumps({
        "environment_dir": str(env_dir),
        "organization_name": resolved_org_name,
        "organization_id": org_id,
        "planned_imports": [
            {"address": addr, "id": iid} for (addr, iid) in import_plan
        ],
    }, indent=2))

    if args.dry_run:
        return

    try:
        ensure_tofu_initialized(env_dir, args.tofu_bin)
    except Exception as ex:
        print(f"Init failed: {ex}", file=sys.stderr)
        sys.exit(2)

    failures: List[Tuple[str, str, str]] = []
    for address, import_id in import_plan:
        try:
            import_state(env_dir, args.tofu_bin, address, import_id)
            print(f"Imported: {address} <= {import_id}")
        except Exception as ex:
            failures.append((address, import_id, str(ex)))

    if failures:
        print("Some imports failed:", file=sys.stderr)
        for address, import_id, error in failures:
            print(f"- {address} <= {import_id}: {error}", file=sys.stderr)
        sys.exit(4)

    print("All planned imports completed successfully.")


if __name__ == "__main__":
    main()


