# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

.PHONY: bash clean dev help sdist test

IMAGE:=jupyter/minimal-notebook:4.0

DOCKER_ARGS?=
define DOCKER
docker run -it --rm \
	--workdir '/srv/kernel_gateway' \
	-e PYTHONPATH='/srv/kernel_gateway' \
	-v `pwd`:/srv/kernel_gateway $(DOCKER_ARGS)
endef

help:
	@cat Makefile

bash:
	@$(DOCKER) -p 8888:8888 $(IMAGE) bash

clean:
	@-rm -rf dist
	@-rm -rf *.egg-info
	@-find . -name __pycache__ -exec rm -fr {} \;

dev: ARGS?=
dev:
	@$(DOCKER) -p 8888:8888 $(IMAGE) \
		python kernel_gateway --KernelGatewayApp.ip='0.0.0.0' $(ARGS)

install:
	$(DOCKER) $(IMAGE) pip install --no-use-wheel dist/*.tar.gz

sdist:
	$(DOCKER) $(IMAGE) python setup.py sdist && rm -rf *.egg-info

test: TEST?=
test:
ifeq ($(TEST),)
	$(DOCKER) $(IMAGE) python -B -m unittest discover
else
# e.g., make test TEST="kernel_gateway.tests.test_gatewayapp.TestGatewayAppConfig"
	@$(DOCKER) $(IMAGE) python -B -m unittest $(TEST)
endif