#!/usr/bin/env bash
set -euo pipefail

TERMINAL_REPO_URL="${TERMINAL_REPO_URL:-git@github.com:nvidela-dev/terminal-config.git}"
NVIM_REPO_URL="${NVIM_REPO_URL:-git@github.com:nvidela-dev/neovim-config.git}"
TERMINAL_CONFIG_DIR="${TERMINAL_CONFIG_DIR:-$HOME/Hangar/terminal-config}"
NVIM_CONFIG_DIR="${NVIM_CONFIG_DIR:-$HOME/.config/nvim}"
BACKUP_SUFFIX="$(date +%Y%m%d%H%M%S)"

log() {
  printf '\n==> %s\n' "$*"
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_packages() {
  log "Installing Homebrew packages"
  brew update
  brew install \
    fd \
    gh \
    git \
    glow \
    jq \
    lazygit \
    neovim \
    nvm \
    ripgrep \
    tmux \
    zsh \
    zsh-autosuggestions
  brew install --cask ghostty
  mkdir -p "$HOME/.nvm"
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    return
  fi

  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

wire_zsh_autosuggestions() {
  local brew_prefix omz_custom plugin_dir source_file

  brew_prefix="$(brew --prefix)"
  omz_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  plugin_dir="$omz_custom/plugins/zsh-autosuggestions"
  source_file="$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

  mkdir -p "$plugin_dir"
  ln -sf "$source_file" "$plugin_dir/zsh-autosuggestions.plugin.zsh"
}

set_brew_zsh_as_login_shell() {
  local zsh_path

  zsh_path="$(brew --prefix zsh)/bin/zsh"
  if ! grep -qx "$zsh_path" /etc/shells; then
    log "Adding Homebrew zsh to /etc/shells"
    printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  if [[ "${SHELL:-}" != "$zsh_path" ]]; then
    log "Changing login shell to Homebrew zsh"
    chsh -s "$zsh_path"
  fi
}

sync_repo() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "$target_dir/.git" ]]; then
    log "Updating $target_dir"
    git -C "$target_dir" fetch --all --prune
    git -C "$target_dir" pull --ff-only
    return
  fi

  if [[ -e "$target_dir" ]]; then
    printf 'Refusing to clone %s because %s already exists and is not a git repo.\n' "$repo_url" "$target_dir" >&2
    return 1
  fi

  log "Cloning $repo_url to $target_dir"
  mkdir -p "$(dirname "$target_dir")"
  git clone "$repo_url" "$target_dir"
}

link_file() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    if cmp -s "$source_path" "$target_path"; then
      rm -f "$target_path"
    else
      mv "$target_path" "$target_path.backup.$BACKUP_SUFFIX"
    fi
  fi

  ln -s "$source_path" "$target_path"
}

install_dotfiles() {
  log "Linking terminal configuration"
  link_file "$TERMINAL_CONFIG_DIR/.zshrc" "$HOME/.zshrc"
  link_file "$TERMINAL_CONFIG_DIR/.zprofile" "$HOME/.zprofile"
  link_file "$TERMINAL_CONFIG_DIR/.tmux.conf" "$HOME/.tmux.conf"
  link_file "$TERMINAL_CONFIG_DIR/.config/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
  link_file "$TERMINAL_CONFIG_DIR/.local/bin/tmux-startup-banner" "$HOME/.local/bin/tmux-startup-banner"
  chmod +x "$TERMINAL_CONFIG_DIR/.local/bin/tmux-startup-banner"
}

install_tmux_plugins() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  if [[ -d "$tpm_dir/.git" ]]; then
    log "Updating TPM"
    git -C "$tpm_dir" pull --ff-only
  else
    log "Installing TPM"
    mkdir -p "$(dirname "$tpm_dir")"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi

  log "Installing tmux plugins"
  "$tpm_dir/bin/install_plugins"
}

main() {
  ensure_homebrew
  eval "$(brew shellenv)"

  install_packages
  install_oh_my_zsh
  wire_zsh_autosuggestions
  set_brew_zsh_as_login_shell
  sync_repo "$TERMINAL_REPO_URL" "$TERMINAL_CONFIG_DIR"
  sync_repo "$NVIM_REPO_URL" "$NVIM_CONFIG_DIR"
  install_dotfiles
  install_tmux_plugins

  log "Done"
  printf 'Terminal config: %s\n' "$TERMINAL_CONFIG_DIR"
  printf 'Neovim config:   %s\n' "$NVIM_CONFIG_DIR"
}

main "$@"
