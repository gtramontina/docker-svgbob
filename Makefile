SHELL := bash -eu -o pipefail -c
.DELETE_ON_ERROR:

# ---

container-registry := ghcr.io
image-owner := gtramontina
image-name := svgbob
image := $(container-registry)/$(image-owner)/$(image-name)
tag = $(shell grep "svgbob_cli = " Cargo.toml | cut -d '"' -f2)

# ---

build.log: Cargo.toml Dockerfile Makefile
	@docker build --build-arg version=$(tag) -t $(image):$(tag) . | tee $@
to-clobber += $(image):$(tag)
to-clean += build.log

test.log: build.log
	@grep -q "$(tag)" <<< `docker run --rm $(image):$(tag) --version`  | tee $@
to-clean += test.log

# ---

.PHONY: build
build: build.log

.PHONY: test
test: test.log

.PHONY: push
push: test
	@docker push $(image):$(tag)

.PHONY: clean
clean:; @rm -rf $(to-clean)

.PHONY: clobber
clobber: clean
	@docker rmi $(to-clobber) --force
