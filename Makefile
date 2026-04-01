.PHONY: fmt init plan apply destroy validate lint test

TF ?= tofu

fmt:
	$(TF) fmt -recursive

init:
	cd $(DIR) && $(TF) init -upgrade

plan:
	cd $(DIR) && $(TF) plan $(ARGS)

apply:
	cd $(DIR) && $(TF) apply $(ARGS)

destroy:
	cd $(DIR) && $(TF) destroy $(ARGS)

validate:
	$(TF) fmt -check -recursive && $(TF) validate

lint:
	python -m py_compile scripts/meraki_to_state.py

test:
	python -m pytest tests/ -v

