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
SUBNETWORK ?= default
DOMAIN ?= vpn.example.com
IMAGE_VERSION ?= ""

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install Ansible dependencies
	ansible-galaxy collection install -r playbooks/requirements.yml
	ansible-galaxy role install -r playbooks/requirements.yml

validate: ## Run all validation checks
	$(ANSIBLE_LINT) playbooks/*.yml
	cd packer && $(PACKER) validate \
		-var="project_id=$(GCP_PROJECT)" \
		-var="region=$(GCP_REGION)" \
		-var="zone=$(GCP_ZONE)" \
		-var="network=$(NETWORK)" \
		.

generate-certs:
	./config/gen_test_certs.sh

clean: ## Clean up generated files
	rm -rf packer/packer_cache
	rm -rf generated/*

clean-images: ## Remove all built images except the latest
	gcloud compute images list --filter="family:vpn-server" --sort-by=~creationTimestamp --format="value(name)" | tail -n +2 | xargs -I {} gcloud compute images delete {} --quiet

list-images:
	gcloud compute images list --filter="family:vpn-server" --format="table(name,family,creationTimestamp)"

build-image: ## Build the GCP image with Packer
	cd packer && $(PACKER) init .
	cd packer && $(PACKER) build \
		-var="project_id=$(GCP_PROJECT)" \
		-var="region=$(GCP_REGION)" \
		-var="image_version=$(IMAGE_VERSION)" \
		-var="zone=$(GCP_ZONE)" \
		.

build-image-debug: ## Build the GCP image with debug output
	cd packer && PACKER_LOG=1 $(PACKER) build \
		-var="project_id=$(GCP_PROJECT)" \
		-var="region=$(GCP_REGION)" \
		-var="zone=$(GCP_ZONE)" \
		.

quick-build: ## Build image without initialization
	cd packer && $(PACKER) build  \
		-var="project_id=$(GCP_PROJECT)" \
		-var="image_version=$(IMAGE_VERSION)" \
		-var="region=$(GCP_REGION)" \
		-var="zone=$(GCP_ZONE)" \
		.

launch-test: ## Launch a test instance from the latest image
	@echo "Creating test instance $(INSTANCE_NAME)..."
	gcloud compute instances create $(INSTANCE_NAME) \
		--project=$(GCP_PROJECT) \
		--zone=$(GCP_ZONE) \
		--machine-type=$(MACHINE_TYPE) \
		--network=$(NETWORK) \
		--image-family=vpn-server \
		--image-project=$(GCP_PROJECT) \
    --metadata=\
client_id=$(CLIENT_ID),\
domain_name=$(DOMAIN_NAME),\
support_email=$(SERVER_ADMIN),\
allowed_domain=$(ALLOWED_DOMAIN)

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