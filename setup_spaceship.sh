#!/usr/bin/env bash
set -euo pipefail

mode="dry-run"
if [[ "${1:-}" == "--apply" ]]; then
    mode="apply"
elif [[ "${1:-}" == "--dry-run" || -z "${1:-}" ]]; then
    mode="dry-run"
else
    echo "Usage: $0 [--dry-run|--apply]" >&2
    exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
theme_dir="$zsh_dir/custom/themes/spaceship-prompt"
theme_link="$zsh_dir/custom/themes/spaceship.zsh-theme"
config_dir="$HOME/.config/spaceship"
local_zsh_dir="$HOME/.config/zsh"
backup_dir="$HOME/.zsh_config_backup/$(date +%Y%m%d-%H%M%S)"

run() {
    if [[ "$mode" == "apply" ]]; then
        "$@"
    else
        printf '[dry-run]'
        for arg in "$@"; do
            printf ' %q' "$arg"
        done
        printf '\n'
    fi
}

copy_file() {
    local source="$1"
    local target="$2"
    if [[ "$mode" == "apply" ]]; then
        install -m 0644 "$source" "$target"
    else
        echo "[dry-run] install -m 0644 $source $target"
    fi
}

if ! command -v zsh >/dev/null 2>&1; then
    echo "Zsh is not installed. Install zsh first." >&2
    exit 1
fi

if [[ ! -d "$zsh_dir" ]]; then
    echo "oh-my-zsh not found at $zsh_dir. Install oh-my-zsh first." >&2
    exit 1
fi

echo "Mode: $mode"
echo "Repository: $repo_root"
echo "oh-my-zsh: $zsh_dir"

if [[ ! -d "$theme_dir" ]]; then
    run git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$theme_dir" --depth=1
fi

if [[ ! -L "$theme_link" ]]; then
    run ln -s "$theme_dir/spaceship.zsh-theme" "$theme_link"
elif [[ "$(readlink "$theme_link")" != "$theme_dir/spaceship.zsh-theme" ]]; then
    echo "Theme link exists but points elsewhere: $theme_link -> $(readlink "$theme_link")" >&2
fi

run mkdir -p "$config_dir" "$local_zsh_dir"
copy_file "$repo_root/spaceship/spaceship.zsh" "$config_dir/spaceship.zsh"

if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
    run mkdir -p "$backup_dir"
    run cp "$HOME/.zshrc" "$backup_dir/.zshrc"
fi

copy_file "$repo_root/.zshrc" "$HOME/.zshrc"

if [[ ! -f "$local_zsh_dir/local.zsh" ]]; then
    if [[ "$mode" == "apply" ]]; then
        cat >"$local_zsh_dir/local.zsh" <<'LOCAL'
# Machine-local zsh configuration.
# Keep host-specific PATH, pyenv, private tools, and secrets here.
LOCAL
    else
        echo "[dry-run] create $local_zsh_dir/local.zsh"
    fi
fi

echo "Setup complete. Run: zsh -lic 'echo ok'"
