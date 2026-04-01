"""Tests for scripts/meraki_to_state.py."""

import json
import os
import sys
import textwrap
from pathlib import Path
from typing import Dict
from unittest import mock

import pytest

# Ensure the scripts package is importable
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import meraki_to_state as mts


# ---------------------------------------------------------------------------
# read_tfvars
# ---------------------------------------------------------------------------


class TestReadTfvars:
    """Tests for the read_tfvars helper."""

    def test_parses_valid_tfvars(self, tmp_path: Path) -> None:
        tfvars = tmp_path / "terraform.tfvars"
        tfvars.write_text(
            textwrap.dedent("""\
                meraki_org_name = "Acme Corp"
                customer_slug   = "acme"
                environment     = "dev"
            """),
            encoding="utf-8",
        )
        data = mts.read_tfvars(tfvars)
        assert data["meraki_org_name"] == "Acme Corp"
        assert data["customer_slug"] == "acme"
        assert data["environment"] == "dev"

    def test_missing_file_raises(self, tmp_path: Path) -> None:
        with pytest.raises(FileNotFoundError):
            mts.read_tfvars(tmp_path / "nonexistent.tfvars")

    def test_empty_file_returns_empty_dict(self, tmp_path: Path) -> None:
        tfvars = tmp_path / "terraform.tfvars"
        tfvars.write_text("", encoding="utf-8")
        data = mts.read_tfvars(tfvars)
        assert data == {}


# ---------------------------------------------------------------------------
# planned_network_names
# ---------------------------------------------------------------------------


class TestPlannedNetworkNames:
    """Tests for the planned_network_names helper."""

    def test_default_pattern(self) -> None:
        names = mts.planned_network_names("acme", "prod")
        assert names == {
            "branch_office_network": "acme-branch-office-prod",
            "headquarters_network": "acme-hq-prod",
        }

    def test_different_slug_and_env(self) -> None:
        names = mts.planned_network_names("corp-x", "staging")
        assert names["branch_office_network"] == "corp-x-branch-office-staging"
        assert names["headquarters_network"] == "corp-x-hq-staging"


# ---------------------------------------------------------------------------
# resolve_org_id
# ---------------------------------------------------------------------------


class TestResolveOrgId:

    def _mock_dashboard(self, orgs):
        dashboard = mock.MagicMock()
        dashboard.organizations.getOrganizations.return_value = orgs
        return dashboard

    def test_matches_by_name_case_insensitive(self) -> None:
        orgs = [
            {"id": "100", "name": "Alpha Corp"},
            {"id": "200", "name": "Beta Corp"},
        ]
        org_id, org_name = mts.resolve_org_id(self._mock_dashboard(orgs), "beta corp")
        assert org_id == "200"
        assert org_name == "Beta Corp"

    def test_defaults_to_first_org_when_no_name(self) -> None:
        orgs = [{"id": "100", "name": "First Org"}]
        org_id, org_name = mts.resolve_org_id(self._mock_dashboard(orgs), None)
        assert org_id == "100"
        assert org_name == "First Org"

    def test_raises_when_no_orgs(self) -> None:
        with pytest.raises(RuntimeError, match="No organizations"):
            mts.resolve_org_id(self._mock_dashboard([]), "anything")

    def test_raises_when_name_not_found(self) -> None:
        orgs = [{"id": "1", "name": "OnlyOrg"}]
        with pytest.raises(RuntimeError, match="not found"):
            mts.resolve_org_id(self._mock_dashboard(orgs), "NonExistent")


# ---------------------------------------------------------------------------
# fetch_networks_by_name
# ---------------------------------------------------------------------------


class TestFetchNetworksByName:

    def test_returns_dict_keyed_by_name(self) -> None:
        dashboard = mock.MagicMock()
        dashboard.organizations.getOrganizationNetworks.return_value = [
            {"name": "net-a", "id": "1"},
            {"name": "net-b", "id": "2"},
        ]
        result = mts.fetch_networks_by_name(dashboard, "org1")
        assert "net-a" in result
        assert result["net-a"]["id"] == "1"
        assert "net-b" in result

    def test_skips_entries_with_no_name(self) -> None:
        dashboard = mock.MagicMock()
        dashboard.organizations.getOrganizationNetworks.return_value = [
            {"name": "", "id": "1"},
            {"id": "2"},
        ]
        result = mts.fetch_networks_by_name(dashboard, "org1")
        assert result == {}


# ---------------------------------------------------------------------------
# build_import_plan
# ---------------------------------------------------------------------------


class TestBuildImportPlan:

    def _make_env_dir(self, tmp_path: Path) -> Path:
        env_dir = tmp_path / "env"
        env_dir.mkdir()
        return env_dir

    def test_branch_and_hq_imports(self, tmp_path: Path) -> None:
        env_dir = self._make_env_dir(tmp_path)
        tfvars: Dict[str, object] = {
            "customer_slug": "acme",
            "environment": "dev",
        }
        networks = {
            "acme-branch-office-dev": {"id": "N_br1", "name": "acme-branch-office-dev"},
            "acme-hq-dev": {"id": "N_hq1", "name": "acme-hq-dev"},
        }
        plan = mts.build_import_plan(env_dir, tfvars, networks)
        addresses = [addr for addr, _ in plan]

        # branch network core + security/content-filtering/autovpn
        assert "module.branch_office_network.meraki_networks.this" in addresses
        assert "module.branch_security_policies.meraki_networks_appliance_firewall_l3_firewall_rules.this" in addresses
        assert "module.branch_content_filtering.meraki_networks_appliance_content_filtering.this" in addresses
        assert "module.branch_autovpn.meraki_networks_appliance_vpn_site_to_site.this" in addresses

        # HQ network core
        assert "module.headquarters_network.meraki_networks.this" in addresses
        assert "module.headquarters_network.meraki_networks_settings.this" in addresses

    def test_no_matching_networks_produces_empty_plan(self, tmp_path: Path) -> None:
        env_dir = self._make_env_dir(tmp_path)
        tfvars: Dict[str, object] = {
            "customer_slug": "acme",
            "environment": "dev",
        }
        plan = mts.build_import_plan(env_dir, tfvars, {})
        assert plan == []

    def test_name_overrides_take_effect(self, tmp_path: Path) -> None:
        env_dir = self._make_env_dir(tmp_path)
        tfvars: Dict[str, object] = {
            "customer_slug": "acme",
            "environment": "dev",
        }
        networks = {
            "custom-branch": {"id": "N_custom", "name": "custom-branch"},
        }
        overrides = {"branch_office_network": "custom-branch"}
        plan = mts.build_import_plan(env_dir, tfvars, networks, name_overrides=overrides)
        ids = [iid for _, iid in plan]
        assert "N_custom" in ids

    def test_for_each_networks_from_tfvars(self, tmp_path: Path) -> None:
        env_dir = self._make_env_dir(tmp_path)
        tfvars: Dict[str, object] = {
            "customer_slug": "acme",
            "environment": "dev",
            "networks": {
                "dc01": {"name": "dc01-net", "include_security": True, "include_autovpn": True},
            },
        }
        networks = {
            "dc01-net": {"id": "N_dc01", "name": "dc01-net"},
        }
        plan = mts.build_import_plan(env_dir, tfvars, networks)
        addresses = [addr for addr, _ in plan]
        assert 'module.networks["dc01"].meraki_networks.this' in addresses
        assert 'module.networks_security["dc01"].meraki_networks_appliance_firewall_l3_firewall_rules.this' in addresses
        assert 'module.networks_autovpn["dc01"].meraki_networks_appliance_vpn_site_to_site.this' in addresses

    def test_vlans_disabled_skips_vlans_import(self, tmp_path: Path) -> None:
        env_dir = self._make_env_dir(tmp_path)
        tfvars: Dict[str, object] = {
            "customer_slug": "acme",
            "environment": "dev",
            "networks": {
                "vmx1": {"name": "vmx1-net", "enable_vlans": False},
            },
        }
        networks = {
            "vmx1-net": {"id": "N_vmx1", "name": "vmx1-net"},
        }
        plan = mts.build_import_plan(env_dir, tfvars, networks)
        addresses = [addr for addr, _ in plan]
        assert 'module.networks["vmx1"].meraki_networks.this' in addresses
        # vlans_settings should NOT be present
        vlans_addr = 'module.networks["vmx1"].meraki_networks_vlans_settings.this[0]'
        assert vlans_addr not in addresses


# ---------------------------------------------------------------------------
# run_cmd
# ---------------------------------------------------------------------------


class TestRunCmd:

    def test_runs_simple_command(self, tmp_path: Path) -> None:
        code, out, err = mts.run_cmd(["echo", "hello"], cwd=tmp_path)
        assert code == 0
        assert "hello" in out

    def test_nonexistent_command_raises(self, tmp_path: Path) -> None:
        with pytest.raises(FileNotFoundError):
            mts.run_cmd(["nonexistent_binary_xyz123"], cwd=tmp_path)

    def test_captures_stderr(self, tmp_path: Path) -> None:
        code, out, err = mts.run_cmd(
            ["python3", "-c", "import sys; sys.stderr.write('oops')"],
            cwd=tmp_path,
        )
        assert code == 0
        assert "oops" in err


# ---------------------------------------------------------------------------
# User-Agent sanitization
# ---------------------------------------------------------------------------


class TestUserAgentSanitization:

    def test_sanitize_strips_invalid_chars(self) -> None:
        # The sanitize function is a local closure in main(), so we test its logic directly
        import re
        def sanitize(value: str) -> str:
            return re.sub(r"[^A-Za-z0-9_.-]", "", value) or "X"

        assert sanitize("My App") == "MyApp"
        assert sanitize("version@2!") == "version2"
        assert sanitize("") == "X"
        assert sanitize("!!!") == "X"
        assert sanitize("valid_name-1.0") == "valid_name-1.0"

    def test_ua_pattern_rejects_invalid_strings(self) -> None:
        import re
        ua_pattern = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\s+[A-Za-z0-9_.-]+$")
        assert ua_pattern.match("App/1.0 Vendor") is not None
        assert ua_pattern.match("App 1.0 Vendor") is None
        assert ua_pattern.match("") is None
        assert ua_pattern.match("App/1.0") is None
        assert ua_pattern.match("App/1.0 Vendor Extra") is None


# ---------------------------------------------------------------------------
# main() – CLI integration tests
# ---------------------------------------------------------------------------


class TestMainCLI:

    def test_exits_when_api_key_missing(self, monkeypatch) -> None:
        monkeypatch.delenv("MERAKI_DASHBOARD_API_KEY", raising=False)
        with pytest.raises(SystemExit) as exc_info:
            mts.main.__wrapped__() if hasattr(mts.main, "__wrapped__") else mts.main()
        assert exc_info.value.code == 2

    def test_exits_when_env_dir_missing(self, monkeypatch, tmp_path: Path) -> None:
        monkeypatch.setenv("MERAKI_DASHBOARD_API_KEY", "test-key-000")
        monkeypatch.setattr(
            "sys.argv",
            ["meraki_to_state.py", "--env-dir", str(tmp_path / "nonexistent")],
        )
        with pytest.raises(SystemExit) as exc_info:
            mts.main()
        assert exc_info.value.code == 2

    def test_exits_when_tfvars_missing(self, monkeypatch, tmp_path: Path) -> None:
        monkeypatch.setenv("MERAKI_DASHBOARD_API_KEY", "test-key-000")
        env_dir = tmp_path / "env"
        env_dir.mkdir()
        monkeypatch.setattr(
            "sys.argv",
            ["meraki_to_state.py", "--env-dir", str(env_dir)],
        )
        with pytest.raises(SystemExit) as exc_info:
            mts.main()
        assert exc_info.value.code == 2

    def test_dry_run_succeeds(self, monkeypatch, tmp_path: Path) -> None:
        monkeypatch.setenv("MERAKI_DASHBOARD_API_KEY", "test-key-000")
        env_dir = tmp_path / "env"
        env_dir.mkdir()
        (env_dir / "terraform.tfvars").write_text(
            textwrap.dedent("""\
                meraki_org_name = "TestOrg"
                customer_slug   = "test"
                environment     = "dev"
            """),
            encoding="utf-8",
        )
        monkeypatch.setattr(
            "sys.argv",
            ["meraki_to_state.py", "--env-dir", str(env_dir), "--dry-run"],
        )

        mock_dashboard = mock.MagicMock()
        mock_dashboard.organizations.getOrganizations.return_value = [
            {"id": "org1", "name": "TestOrg"},
        ]
        mock_dashboard.organizations.getOrganizationNetworks.return_value = [
            {"name": "test-branch-office-dev", "id": "N_br"},
            {"name": "test-hq-dev", "id": "N_hq"},
        ]

        with mock.patch("meraki.DashboardAPI", return_value=mock_dashboard):
            mts.main()  # should not raise

    def test_list_networks_outputs_json(self, monkeypatch, tmp_path: Path, capsys) -> None:
        monkeypatch.setenv("MERAKI_DASHBOARD_API_KEY", "test-key-000")
        env_dir = tmp_path / "env"
        env_dir.mkdir()
        (env_dir / "terraform.tfvars").write_text(
            textwrap.dedent("""\
                meraki_org_name = "TestOrg"
                customer_slug   = "test"
                environment     = "dev"
            """),
            encoding="utf-8",
        )
        monkeypatch.setattr(
            "sys.argv",
            ["meraki_to_state.py", "--env-dir", str(env_dir), "--list-networks"],
        )

        mock_dashboard = mock.MagicMock()
        mock_dashboard.organizations.getOrganizations.return_value = [
            {"id": "org1", "name": "TestOrg"},
        ]
        mock_dashboard.organizations.getOrganizationNetworks.return_value = [
            {"name": "net-a", "id": "N1", "productTypes": ["appliance"]},
        ]

        with mock.patch("meraki.DashboardAPI", return_value=mock_dashboard):
            mts.main()

        captured = capsys.readouterr()
        output = json.loads(captured.out)
        assert output["organization_name"] == "TestOrg"
        assert len(output["networks"]) == 1
        assert output["networks"][0]["name"] == "net-a"
