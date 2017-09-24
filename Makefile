MAKEFLAGS += --warn-undefined-variables -j1
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.PHONY: shell install test

DOCKER ?= docker
GEM ?= gem
GIT ?= git
RAKE ?= rake

BIN_DIR ?= bin

DOCKER_IMAGE ?= jack12816/plankton
DOCKER_VERSION ?= $(shell $(GIT) describe)

all:
	# Plankton
	#
	# install           Install the dependencies
	# shell             Start an interactive shell session
	# test              Run the whole test suite
	#
	# release           Alias to release-minor
	# release-major     Release a major version
	# release-minor     Release a minor version
	# release-patch     Release a patch version
	#
	# build             Build the Docker image
	# publish           Push the Docker image

install:
	# Install the dependencies
	@$(BIN_DIR)/setup

shell:
	# Start an interactive shell session
	@$(BIN_DIR)/console

test: install
	# Run the whole test suite
	@$(RAKE) spec

build:
	# Build the Docker image
	@$(DOCKER) build -t $(DOCKER_IMAGE):$(DOCKER_VERSION) .
	@$(DOCKER) tag $(DOCKER_IMAGE):$(DOCKER_VERSION) $(DOCKER_IMAGE):latest

publish:
	# Push the Docker image
	@$(DOCKER) push $(DOCKER_IMAGE):$(DOCKER_VERSION)
	@$(DOCKER) push $(DOCKER_IMAGE):latest

release: release-minor

release-major:
	# Release a major version
	@$(GEM) bump --commit --tag --release --version major

release-minor:
	# Release a minor version
	@$(GEM) bump --commit --tag --release --version minor

release-patch:
	# Release a patch version
	@$(GEM) bump --commit --tag --release --version patch
