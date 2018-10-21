SHELL := /bin/bash

default: help
.PHONY: help
help:  ## this help
		@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


define ALL_HELP_INFO
# Build code.
#
# Example:
# make
# make all
endef
.PHONY: all
ifeq ($(PRINT_HELP),y)
all: 
	@echo "$$ALL_HELP_INFO"
else
all: ui cni rainbond ## build all image
endif

define PRINT_UI_HELP
# Build rbd-app-ui
#
# Example:
# make ui
endef
.PHONY: ui
ifeq ($(PRINT_UI_HELP),y)
ui:
	@echo "$$PRINT_UI_HELP"
else:
ui: ## build ui
	hack/build_rbd-app-ui.sh
endif

define PRINT_CNI_HELP
# Build node,grctl,certutil
# 
# Example:
# make cni
#
endef
.PHONY: cni
ifeq ($(PRINT_CNI_HELP),y)
cni:
	@echo "$$PRINT_CNI_HELP"
else
cni:  ## build cni tools
	hack/build_rbd.sh
endif

define PRINT_ALL_HELP
# Build plugins
# 
# Example:
# make rainbond
#
endef
.PHONY: rainbond
ifeq ($(PRINT_ALL_HELP),y)
rainbond:
	@echo "$$PRINT_ALL_HELP"
else
rainbond: ## build rainbond plugins
	hack/build_rbd_all.sh $(WHAT)
endif

define CLEAN_HELP_INFO
# Remove all build artifacts.
#
# Example:
#   make clean
#
# TODO(thockin): call clean_generated when we stop committing generated code.
endef
.PHONY: clean
ifeq ($(PRINT_HELP),y)
clean:
	@echo "$$CLEAN_HELP_INFO"
else
clean:
	hack/clean.sh
endif

