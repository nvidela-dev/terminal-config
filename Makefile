SHELL := /bin/bash

.PHONY: help install verify check-shell check-tmux check-neovim sync-lazyvim tmux-plugins

help:
	@printf '%s\n' 'Targets:'
	@printf '  %-14s %s\n' 'install' 'Install packages, link dotfiles, install tmux plugins, and sync LazyVim'
	@printf '  %-14s %s\n' 'verify' 'Run local syntax/startup checks'
	@printf '  %-14s %s\n' 'sync-lazyvim' 'Install/update LazyVim and configured Neovim plugins'
	@printf '  %-14s %s\n' 'tmux-plugins' 'Install/update tmux plugins through TPM'

install:
	./install.sh

verify: check-shell check-tmux check-neovim

check-shell:
	bash -n install.sh
	zsh -n .zshrc .zprofile .local/bin/tmux-startup-banner

check-tmux:
	tmux -L codex-terminal-config-check -f .tmux.conf start-server \; source-file .tmux.conf \; kill-server

check-neovim:
	nvim --headless '+qa'

sync-lazyvim:
	nvim --headless '+Lazy! sync' +qa

tmux-plugins:
	~/.tmux/plugins/tpm/bin/install_plugins
