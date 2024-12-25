# Makefile for OpenVPN Server Automation

.PHONY: all install test lint clean build-image deploy help

# Variables
ANSIBLE_PLAYBOOK := ansible-playbook
PACKER := packer
ANSIBLE_LINT := ansible-lint
INSTANCE_NAME ?= vpn-test-instance
MACHINE_TYPE ?= e2-medium

# Default variables - can be overridden via environment variables
GCP_PROJECT ?= your-project-id
GCP_REGION ?= us-central1
GCP_ZONE ?= us-central1-a
NETWORK ?= default
DOMAIN ?= vpn.example.com

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install Ansible dependencies
	ansible-galaxy collection install -r requirements.yml
	ansible-galaxy role install -r requirements.yml

init: ## Initialize project and copy example configs
	make install
	cp -n inventory/group_vars/all.yml.example inventory/group_vars/all.yml || true
	cp -n packer/vars.pkr.hcl.example packer/vars.pkr.hcl || true

validate: ## Run all validation checks
	$(ANSIBLE_LINT) playbooks/*.yml roles/*
	cd packer && $(PACKER) validate .

clean: ## Clean up generated files
	rm -rf packer/packer_cache
	rm -rf generated/*

build-image: ## Build the GCP image with Packer
	cd packer && $(PACKER) init .
	cd packer && $(PACKER) build \
		-var="project_id=$(GCP_PROJECT)" \
		-var="zone=$(GCP_ZONE)" \
		-var="network=$(NETWORK)" \
		build.pkr.hcl

build-image-debug: ## Build the GCP image with debug output
	cd packer && PACKER_LOG=1 $(PACKER) build \
		-var="project_id=$(GCP_PROJECT)" \
		-var="zone=$(GCP_ZONE)" \
		-var="network=$(NETWORK)" \
		build.pkr.hcl

quick-build: ## Build image without initialization
	cd packer && $(PACKER) build \
		-var="project_id=$(GCP_PROJECT)" \
		-var="zone=$(GCP_ZONE)" \
		-var="network=$(NETWORK)" \
		build.pkr.hcl

launch-test: ## Launch a test instance from the latest image
	@echo "Creating test instance $(INSTANCE_NAME)..."
	gcloud compute instances create $(INSTANCE_NAME) \
		--project=$(GCP_PROJECT) \
		--zone=$(GCP_ZONE) \
		--machine-type=$(MACHINE_TYPE) \
		--network=$(NETWORK) \
		--image-family=vpn-server \
		--image-project=$(GCP_PROJECT)

delete-test: ## Delete the test instance
	@echo "Deleting test instance $(INSTANCE_NAME)..."
	-gcloud compute instances delete $(INSTANCE_NAME) \
		--project=$(GCP_PROJECT) \
		--zone=$(GCP_ZONE) \
		--quiet

ssh-test: ## SSH into the test instance
	gcloud compute ssh $(INSTANCE_NAME) \
		--project=$(GCP_PROJECT) \
		--zone=$(GCP_ZONE)

logs-test: ## View logs from test instance
	gcloud compute ssh $(INSTANCE_NAME) \
		--project=$(GCP_PROJECT) \
		--zone=$(GCP_ZONE) \
		--command="sudo journalctl -f -u nginx -u openvpn -u vpn-web"

cycle-test: clean quick-build delete-test launch-test ## Rebuild image and recreate test instance

tail-serial: ## Tail the serial port output of the test instance
	gcloud compute instances tail-serial-port-output $(INSTANCE_NAME) \
		--project=$(GCP_PROJECT) \
		--zone=$(GCP_ZONE)

status-test: ## Check status of key services on test instance
	@echo "Checking service status on $(INSTANCE_NAME)..."
	gcloud compute ssh $(INSTANCE_NAME) \
		--project=$(GCP_PROJECT) \
		--zone=$(GCP_ZONE) \
		--command="sudo systemctl status nginx openvpn@server vpn-web"