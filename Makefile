ANSIBLE_INV=inventory/pi-cluster.ini
ANSIBLE_DIR=ansible
TERRAFORM_DIR=terraform

.PHONY: setup-base setup-k3s plan apply destroy full

setup-base:
	@echo "Running base setup via Ansible..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(ANSIBLE_INV) playbooks/setup-base.yml

setup-k3s:
	@echo "Installing K3s on all nodes..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(ANSIBLE_INV) playbooks/setup-k3s.yml

setup-telegraf:
	@echo "Setting up Telegraf on all nodes..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(ANSIBLE_INV) playbooks/setup-telegraf.yml

plan:
	@echo "Running terraform plan..."
	cd $(TERRAFORM_DIR) && terraform plan

apply:
	@echo "Applying terraform configuration (stage=$$(jq -r .stage $(TERRAFORM_DIR)/scripts/stage.json))..."
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

destroy:
	@echo "Destroying infrastructure (only safe with stage=1)..."
	@if [ "$$(jq -r .stage $(TERRAFORM_DIR)/scripts/stage.json)" != "1" ]; then \
		echo "You must set stage=1 in scripts/stage.json before destroying."; \
		exit 1; \
	fi
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

full: setup-base setup-k3s apply apply