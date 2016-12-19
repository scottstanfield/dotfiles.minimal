DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
FOLDERS    := bin
FILES      := $(wildcard ??*) 
EXCLUSIONS := .DS_Store .git .gitmodules .travis.yml Makefile $(FOLDERS)
DOTFILES   := $(filter-out $(EXCLUSIONS), $(FILES))

.DEFAULT_GOAL := help

all:

list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), /bin/ls -ldF $(val);)
	@$(foreach val, $(FOLDERS), /bin/ls -ldF $(val);)

debug: ## just echo what deploy would do
	@echo 'make deploy will link the following:'
	@$(foreach val, $(DOTFILES), echo $(abspath $(val)) "-->" $(HOME)/.$(val) ;)
	@$(foreach val, $(FOLDERS), echo $(abspath $(val))/ "-->" $(HOME)/$(val) ;)

deploy: ## Create symlink to home directory
	@echo '==> Deploy dotfiles to home directory.'
	@$(foreach val, $(DOTFILES), ln -sfnv $(abspath $(val)) $(HOME)/.$(val);)
	@$(foreach val, $(FOLDERS),  ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

init: ## Setup environment settings
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/etc/init/init.sh

update: ## Fetch changes for this repo
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

install: update deploy init ## Run make update, deploy, init
	@exec $$SHELL

clean: ## Remove the dot files and this repo
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)
	-rm -rf $(DOTPATH)

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
