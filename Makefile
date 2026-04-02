.PHONY: fmt init plan apply destroy validate lint test ansible-lint ansible-syntax

TF ?= tofu

# --- OpenTofu targets ---

fmt:
	cd opentofu && $(TF) fmt -recursive

init:
	cd $(DIR) && $(TF) init -upgrade

plan:
	cd $(DIR) && $(TF) plan $(ARGS)

apply:
	cd $(DIR) && $(TF) apply $(ARGS)

destroy:
	cd $(DIR) && $(TF) destroy $(ARGS)

validate:
	cd opentofu && $(TF) fmt -check -recursive

# --- Python targets ---

lint:
	python -m py_compile scripts/meraki_to_state.py

test:
	python -m pytest tests/ -v

# --- Ansible targets ---

ansible-lint:
	cd ansible && ansible-playbook --syntax-check playbooks/*.yml

ansible-syntax:
	cd ansible && ansible-playbook --syntax-check playbooks/*.yml

