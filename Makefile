SHELL_UID ?= $(shell id -u)
COMPOSE=SHELL_UID=$(SHELL_UID) docker-compose

.PHONY: docker-build
docker-build:
	$(COMPOSE) build

.PHONY: docker-down
docker-down:
	$(COMPOSE) down

.PHONY: bundle
bundle:
	$(COMPOSE) run --rm app bundle

.PHONY: setup
setup: docker-build bundle

.PHONY: serve
serve:
	-rm tmp/pids/server.pid &> /dev/null
	$(COMPOSE) up

.PHONY: test
test:
	$(COMPOSE) run --rm app rspec

.PHONY: shell
shell:
	$(COMPOSE) run --rm app /bin/bash

.PHONY: lint
lint:
	$(COMPOSE) run --rm app rubocop

.PHONY: check
check: lint test
	echo 'Deployable!'

guard:
	$(COMPOSE) run --rm app guard
