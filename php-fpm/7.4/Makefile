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
BUILD_PLATFORM=linux/amd64


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help build build-nc test run up stop release publish tag repo-login version

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	@echo 'Building image for $(BUILD_PLATFORM)'
	docker build --platform $(BUILD_PLATFORM) --target base -t $(APP_NAME) .

build-nc: ## Build the container without caching
	@echo 'Building image for $(BUILD_PLATFORM) (no cache)'
	docker build --platform $(BUILD_PLATFORM) --target base --no-cache --pull -t $(APP_NAME) .

test: ## Check the built image (PHP + backport, extensions, ini, tools)
	./tests/image-test.sh $(APP_NAME)

run: ## Run container on port configured in `config.env`
	docker run -i -t --rm --env-file=./config.env -p=$(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME)


up: build run ## Run container on port configured in `config.env` (Alias to run)

stop: ## Stop and remove a running container
	docker stop $(APP_NAME); docker rm $(APP_NAME)

# Sequential sub-makes, not prerequisites: with `make -j` or `-k`, prerequisites could
# publish an image that hasn't been rebuilt or hasn't passed `test`.
release: ## Make a release: build without cache, test, publish to ECR
	$(MAKE) build-nc && $(MAKE) test && $(MAKE) publish

# Docker publish
# Only the immutable `{version}` tag is published. App images pin it by tag + digest,
# so there are deliberately no `latest`, `MAJOR` or `MAJOR.MINOR` tags.
# Publishing continues only on an explicit ImageNotFoundException; any other lookup
# error (expired credentials, denied access, network) aborts.
publish: repo-login tag ## Publish the `{version}` tagged container to ECR and print its digest
	@out=$$(aws ecr describe-images $(AWS_CLI_FLAGS) --repository-name $(APP_NAME) --image-ids imageTag=$(VERSION) 2>&1); rc=$$?; \
	if [ $$rc -eq 0 ]; then \
		echo 'ERROR: $(DOCKER_REPO)/$(APP_NAME):$(VERSION) already exists in ECR; bump the version in $(cnf)'; exit 1; \
	elif ! printf '%s\n' "$$out" | grep -q ImageNotFoundException; then \
		echo 'ERROR: could not confirm that $(APP_NAME):$(VERSION) is absent from ECR:'; printf '%s\n' "$$out"; exit 1; \
	fi
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)
	@echo 'Pin App images to:'
	@docker inspect --format '{{index .RepoDigests 0}}' $(DOCKER_REPO)/$(APP_NAME):$(VERSION) | sed 's/@/:$(VERSION)@/'

# Docker tagging
tag: ## Generate container `{version}` tag
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# HELPERS

AWS_CLI_FLAGS :=
ifdef AWS_CLI_PROFILE
AWS_CLI_FLAGS += --profile $(AWS_CLI_PROFILE)
endif
ifdef AWS_CLI_REGION
AWS_CLI_FLAGS += --region $(AWS_CLI_REGION)
endif

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
