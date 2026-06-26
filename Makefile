SHELL := /usr/bin/env bash

CLUSTER_NAME ?= cloudops-gitops
GIT_REPO_URL ?= git://host.docker.internal:9418/cloudops-gitops-platform

.PHONY: test lint render validate aws-preflight build-images load-images install-argocd bootstrap-project bootstrap-dev bootstrap-all

test:
	python3 -m unittest discover -s app/tests -v

lint:
	helm lint charts/cloudops-demo-app -f environments/dev/values.yaml
	helm lint charts/cloudops-demo-app -f environments/staging/values.yaml
	helm lint charts/cloudops-demo-app -f environments/prod/values.yaml

render:
	./scripts/render-helm.sh
	./scripts/render-argocd.sh

validate: test lint render
	bash -n scripts/*.sh
	terraform -chdir=terraform fmt -check -recursive

aws-preflight:
	./scripts/aws-preflight.sh

build-images:
	docker build -t cloudops-demo-app:0.1.0-dev ./app
	docker tag cloudops-demo-app:0.1.0-dev cloudops-demo-app:0.1.0-staging
	docker tag cloudops-demo-app:0.1.0-dev cloudops-demo-app:0.1.0-prod

load-images:
	kind load docker-image cloudops-demo-app:0.1.0-dev --name $(CLUSTER_NAME)
	kind load docker-image cloudops-demo-app:0.1.0-staging --name $(CLUSTER_NAME)
	kind load docker-image cloudops-demo-app:0.1.0-prod --name $(CLUSTER_NAME)

install-argocd:
	./scripts/install-argocd.sh

bootstrap-project:
	GIT_REPO_URL=$(GIT_REPO_URL) PROJECT_ONLY=true ./scripts/local-bootstrap.sh

bootstrap-dev:
	GIT_REPO_URL=$(GIT_REPO_URL) APP_ENV=dev ./scripts/local-bootstrap.sh

bootstrap-all:
	GIT_REPO_URL=$(GIT_REPO_URL) APP_ENV=all ./scripts/local-bootstrap.sh
