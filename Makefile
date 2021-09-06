STAGE ?= dev
BRANCH ?= master
APP_NAME ?= serverless-benthos

.PHONY: ci
ci: clean build archive

.PHONY: build
build:
	@echo "--- build all the things"
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -trimpath -o dist/benthos-lambda github.com/Jeffail/benthos/v3/cmd/serverless/benthos-lambda 

.PHONY: archive
archive:
	@echo "--- archive all the things"
	@cd dist && zip -X -9 -r ./handler.zip *-lambda

.PHONY: clean
clean:
	@echo "--- clean all the things"
	@rm -rf ./dist

.PHONY: package
package:
	@echo "--- package $(APP_NAME) stack to aws"
	@aws cloudformation package \
		--template-file sam/app/benthos.yaml \
		--s3-bucket $(PACKAGE_BUCKET) \
		--output-template-file dist/packaged-template.yaml

.PHONY: packagetest
packagetest:
	@echo "--- package test stack to aws"
	@aws cloudformation package \
		--template-file sam/testing/template.yaml \
		--s3-bucket $(PACKAGE_BUCKET) \
		--output-template-file dist/test-packaged-template.yaml

.PHONY: deploytest
deploytest:
	@echo "--- deploy $(APP_NAME) stack to aws"
	@aws cloudformation deploy \
		--template-file dist/test-packaged-template.yaml \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--stack-name $(APP_NAME)-$(STAGE)-$(BRANCH)

.PHONY: deployci
deployci:
	@echo "--- deploy $(APP_NAME) stack to aws"
	@aws cloudformation deploy \
		--template-file sam/ci/template.yaml \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
		--stack-name $(APP_NAME)-ci \
		--parameter-overrides GitHubRepo=$(APP_NAME) BuildSpecFilePath=buildspec-pipeline.yaml PublishToSAR=true
