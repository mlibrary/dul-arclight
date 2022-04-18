SHELL = /bin/bash

build_tag ?= dul-arclight

ruby_version ?= $(shell cat .ruby-version)

cache_volume ?= bundle_cache

.PHONY : build
build:
	docker build -t $(build_tag) --build-arg ruby_version=$(ruby_version) .

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

.PHONY: lock
lock:
	docker run --rm -u "$(shell id -u):0" \
		-v "$(shell pwd)/Gemfile:/usr/src/app/Gemfile" \
		-v "$(shell pwd)/Gemfile.lock:/usr/src/app/Gemfile.lock" \
		gitlab-registry.oit.duke.edu/devops/docker-bundle:ruby-$(ruby_version) \
		lock

.PHONY: cache
cache:
	docker volume create $(cache_volume)

.PHONY: update
update:
	docker run --rm -u "$(shell id -u):0" \
		-v "$(shell pwd)/Gemfile:/usr/src/app/Gemfile" \
		-v "$(shell pwd)/Gemfile.lock:/usr/src/app/Gemfile.lock" \
		-v "bundle_cache:/usr/local/bundle" \
		gitlab-registry.oit.duke.edu/devops/docker-bundle:ruby-$(ruby_version) \
		update $(gems)

.PHONY: audit
audit:
	docker run --rm \
		-v "$(shell pwd)/Gemfile:/data/Gemfile" \
		-v "$(shell pwd)/Gemfile.lock:/data/Gemfile.lock" \
		gitlab-registry.oit.duke.edu/devops/containers/bundler-audit:main \
		check --update --ignore="CVE-2015-9284"
