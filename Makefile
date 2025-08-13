.PHONY: fmt init plan apply destroy validate

TF ?= tofu

fmt:
	$(TF) fmt -recursive

init:
	cd $(DIR) && $(TF) init -upgrade

plan:
	cd $(DIR) && $(TF) plan $(ARGS)

apply:
	cd $(DIR) && $(TF) apply -auto-approve $(ARGS)

destroy:
	cd $(DIR) && $(TF) destroy -auto-approve $(ARGS)

validate:
	$(TF) fmt -check -recursive && $(TF) validate


