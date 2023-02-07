SHELL = /bin/bash

build_tag ?= dul-arclight

ruby_version ?= $(shell cat .ruby-version)

cache_volume ?= bundle_cache

.PHONY : build
build:
	docker build -t $(build_tag) \
		--build-arg ruby_version=$(ruby_version) \
		--build-arg APP_VCS_REF=$(shell git rev-parse --short HEAD) \
		.

.PHONY : clean
clean:
	rm -rf ./tmp/*
	rm -f ./log/*.log

.PHONY : test
test:
	./.docker/test.sh -f docker-compose.test-default.yml up --exit-code-from app; \
	code=$$?; \
	./.docker/test.sh down; \
	exit $$code

.PHONY : accessibility
accessibility:
	./.docker/test.sh -f docker-compose.test-a11y.yml up --exit-code-from app; \
	code=$$?; \
	./.docker/test.sh down; \
	exit $$code

.PHONY : rubocop
rubocop:
	docker run --rm -v "$(shell pwd):/opt/app-root" $(build_tag) \
		bundle exec rubocop

.PHONY: bundler-image
bundler-image:
	echo -e "FROM ruby:$(ruby_version)\nRUN gem install bundler bundler-audit" \
		| docker build -t bundler-image -

.PHONY: lock
lock: bundler-image
	docker run --rm -u "$(shell id -u):0" -v "$(shell pwd):/app" -w /app bundler-image \
		bundle lock

.PHONY: cache
cache:
	docker volume create $(cache_volume)

.PHONY: update
update: bundler-image
	docker run --rm -u "$(shell id -u):0" -v "$(shell pwd):/app" -w /app \
		-v "bundle_cache:/usr/local/bundle" bundler-image \
		bundle update $(gems)

.PHONY: audit
audit: bundler-image
	docker run --rm -v "$(shell pwd):/data" -w /data bundler-image \
		bundle-audit check --update
