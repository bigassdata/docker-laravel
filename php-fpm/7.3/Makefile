# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

VERSION=$(MAJOR).$(MINOR).$(PATCH)


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	docker build -t $(APP_NAME) .

build-nc: ## Build the container without caching
	docker build --no-cache -t $(APP_NAME) .

run: ## Run container on port configured in `config.env`
	docker run -i -t --rm --env-file=./config.env -p=$(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME)


up: build run ## Run container on port configured in `config.env` (Alias to run)

stop: ## Stop and remove a running container
	docker stop $(APP_NAME); docker rm $(APP_NAME)

release: build-nc publish ## Make a release by building and publishing tagged containers to ECR

# Docker publish
publish: repo-login publish-latest publish-version publish-major publish-major-minor ## Publish `latest` and semantic version tagged containers to ECR

publish-latest: tag-latest ## Publish the `latest` tagged container to ECR
	@echo 'publish latest to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` tagged container to ECR
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

publish-major: tag-major ## Publish the `MAJOR` tagged container to ECR
	@echo 'publish $(MAJOR) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(MAJOR)

publish-major-minor: tag-major-minor ## Publish the `MAJOR.MINOR` tagged container to ECR
	@echo 'publish $(MAJOR).$(MINOR) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(MAJOR).$(MINOR)

# Docker tagging
tag: tag-latest tag-version tag-major tag-major-minor## Generate container tags for the `{version}` and `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

tag-major: ## Generate container `major` tag
	@echo 'create tag $(MAJOR)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(MAJOR)

tag-major-minor: ## Generate container `major.minor` tag
	@echo 'create tag $(MAJOR).$(MINOR)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(MAJOR).$(MINOR)

# HELPERS

# generate script to login to aws docker repo
CMD_REPOLOGIN := "aws ecr get-login-password"
ifdef AWS_CLI_PROFILE
CMD_REPOLOGIN += " --profile $(AWS_CLI_PROFILE)"
endif
ifdef AWS_CLI_REGION
CMD_REPOLOGIN += " --region $(AWS_CLI_REGION)"
endif
CMD_REPOLOGIN += " | docker login --username AWS --password-stdin $(DOCKER_REPO)"

# login to AWS-ECR
repo-login: ## Auto login to AWS-ECR unsing aws-cli
	@echo $(CMD_REPOLOGIN)
	@eval $(CMD_REPOLOGIN)

version: ## Output the current version
	@echo $(VERSION)