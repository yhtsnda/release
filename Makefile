SHELL := /bin/bash

default: help
.PHONY: help
help:  ## this help
		@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: all
all: rainbond base ## build all

.PHONY: rainbond
rainbond: ## build rainbond
	hack/rainbond.sh


.PHONY: base
base: ## build base
	hack/base.sh


.PHONY: clean
clean:
	hack/clean.sh