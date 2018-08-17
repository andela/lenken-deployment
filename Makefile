.PHONY: help

## Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo '${YELLOW} make ${RESET} ${GREEN}<target> [options]${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		message = match(lastLine, /^## (.*)/); \
		if (message) { \
			command = substr($$1, 0, index($$1, ":")-1); \
			message = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} %s\n", command, message; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ''

## Create backend image, export ENVIRONMENT variable to specify environment
backend-image:
	@ ${INFO} "Creating $(ENVIRONMENT) image for the backend"
ifeq ($(ENVIRONMENT),production)
	packer build \
	-var 'project_id=lenken-app' \
	-var 'commit_id=production' \
	-var 'environment=production' \
	-var ‘env_variable=lenken_backend_production_env' \
	-var ‘domain=lenken-api.andela.com' \
	-var ‘backend_build_commit=production_backend_build_commit' \
	-var 'new_relic_licence=af00fe8a7b04ba5f36788c568a2981fcd191f64e' \
	-var 'new_relic_app=lenken_production_beta' \
	-var 'provisioner-file=prod-provisioner.yml' \
	-force Packer/backend-api/packer.json
endif
ifeq ($(ENVIRONMENT),staging)
	packer build \
	-var 'project_id=lenken-app' \
	-var 'commit_id=develop' \
	-var 'environment=staging \
	-var ‘env_variable=lenken_backend_env' \
	-var ‘domain=lenken-api-staging.andela.com' \
	-var ‘backend_build_commit=backend_build_commit' \
	-var 'new_relic_licence=af00fe8a7b04ba5f36788c568a2981fcd191f64e' \
	-var 'new_relic_app=lenken_production_beta' \
	-var 'provisioner-file=provisioner.yml' \
	-force Packer/backend-api/packer.json
endif
ifeq ($(ENVIRONMENT),sandbox)
	packer build \
	-var 'project_id=lenken-app' \
	-var 'commit_id=develop' \
	-var 'environment=sandbox' \
	-var ‘env_variable=lenken_backend_sandbox_env' \
	-var ‘domain=lenken-api-sandbox.andela.com' \
	-var ‘backend_build_commit=sandbox_backend_build_commit' \
	-var 'new_relic_licence=af00fe8a7b04ba5f36788c568a2981fcd191f64e' \
	-var 'new_relic_app=lenken_production_beta' \
	-var 'provisioner-file=provisioner.yml' \
	-force Packer/backend-api/packer.json
endif

## Create frontend image, export ENVIRONMENT variable to specify environment
frontend-image:
	@ ${INFO} "Creating $(ENVIRONMENT) image for the frontend"
ifeq ($(ENVIRONMENT),production)
	packer build \
	-var 'project_id=lenken-app' \
	-var 'commit_id=production' \
	-var 'environment=production' \
	-var ‘env_variable=lenken_frontend_production_env_prod' \
	-var ‘frontend_env_prod=lenken_frontend_production_env_prod' \
	-var ‘domain=lenken.andela.com' \
	-var ‘frontend_build_commit=production_frontend_build_commit' \
	-var ‘frontend_env_variable=lenken_frontend_production_env_ts' \
	-var 'new_relic_licence=af00fe8a7b04ba5f36788c568a2981fcd191f64e' \
	-var 'new_relic_app=lenken_production_beta' \
	-var 'provisioner-file=prod-provisioner.yml' \
	-force Packer/frontend/packer.json
endif
ifeq ($(ENVIRONMENT),staging)
	packer build \
	-var 'project_id=lenken-app' \
	-var 'commit_id=develop' \
	-var 'environment=staging' \
	-var ‘env_variable=lenken_frontend_env_prod' \
	-var ‘frontend_env_prod=lenken_frontend_env_prod' \
	-var ‘domain=lenken-staging.andela.com' \
	-var ‘frontend_build_commit=frontend_build_commit' \
	-var ‘frontend_env_variable=lenken_frontend_env_ts' \
	-var 'new_relic_licence=af00fe8a7b04ba5f36788c568a2981fcd191f64e' \
	-var 'new_relic_app=lenken_production_beta' \
	-var 'provisioner-file=provisioner.yml' \
	-force Packer/frontend/packer.json
endif
ifeq ($(ENVIRONMENT),sandbox)
	packer build \
	-var 'project_id=lenken-app' \
	-var 'commit_id=develop' \
	-var 'environment=sandbox' \
	-var ‘env_variable=lenken_frontend_sandbox_env_prod' \
	-var ‘frontend_env_prod=lenken_frontend_sandbox_env_prod' \
	-var ‘domain=lenken-sandbox.andela.com' \
	-var ‘frontend_build_commit=sandbox_frontend_build_commit' \
	-var ‘frontend_env_variable=lenken_frontend_sandbox_env_ts' \
	-var 'new_relic_licence=af00fe8a7b04ba5f36788c568a2981fcd191f64e' \
	-var 'new_relic_app=lenken_production_beta' \
	-var 'provisioner-file=provisioner.yml' \
	-force Packer/frontend/packer.json
endif

## Create nat image
nat-image:
	@ ${INFO} "Creating NAT image"
	@ packer build -force Packer/nat/packer.json



# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
NC := "\e[0m"
RESET  := $(shell tput -Txterm sgr0)
# Shell Functions
INFO := @bash -c 'printf $(YELLOW); echo "===> $$1"; printf $(NC)' SOME_VALUE
SUCCESS := @bash -c 'printf $(GREEN); echo "===> $$1"; printf $(NC)' SOME_VALUE
