.PHONY: help test coverage clean all

.DEFAULT_GOAL := test

CYAN := \033[36m
GREEN := \033[32m
RESET := \033[0m

help: ## Show this help
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "$(CYAN)%-30s$(RESET) %s\n", $$1, $$2}'

test: ## Run tests [default command]
	@echo -e "$(GREEN)Running tests$(RESET)"
	@dune build
	@dune runtest test

coverage: ## Estimate coverage
	@echo -e "$(GREEN)Estimating coverage$(RESET)"
	-rm -f `find . -name 'bisect*.out'`
	@BISECT_ENABLE=YES dune runtest --force
	@bisect-ppx-report -I _build/default/ -html _coverage/ \
		`find . -name 'bisect*.out'`

all: test coverage ## Do test and coverage

clean: ## Clean projects
	@dune clean
