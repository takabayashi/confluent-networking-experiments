# Makefile for managing Confluent Platform and Confluent Cloud

# Display help for each rule
help:
	@echo "Available rules:"
	@echo "  cc                - Create Confluent Cloud using Terraform"
	@echo "  create-cc         - Initialize and apply Terraform for Confluent Cloud"
	@echo "  destroy-cc        - Destroy Confluent Cloud resources"
	@echo "  cc-latency-metrics- Run latency metrics on Confluent Cloud"

########### Confluent Cloud Rules
# Create Confluent Cloud using Terraform
cc: create-cc

# Initialize and apply Terraform for Confluent Cloud
create-cc:
	terraform -chdir=./platforms/cc/tf init
	terraform -chdir=./platforms/cc/tf plan -var-file="secret.tfvars"
	terraform -chdir=./platforms/cc/tf apply -var-file="secret.tfvars"

# Destroy Confluent Cloud resources
destroy-cc:
	terraform -chdir=./platforms/cc/tf destroy -var-file="secret.tfvars"

# Run latency metrics on Confluent Cloud
cc-latency-metrics:
	python kafka_latency_checker.py check-latency --platform=cc
cc-metrics: cc-latency-metrics

