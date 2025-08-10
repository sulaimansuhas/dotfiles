# ~/.bashrc - Minimal path setup

# Homebrew
[[ -f "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -f "/usr/local/bin/brew" ]] && eval "$(/usr/local/bin/brew shellenv)"

# Cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Local bin
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
