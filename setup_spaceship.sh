#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -gt 1 ]]; then
    echo "Usage: $0 [--dry-run|--apply]" >&2
    exit 2
fi
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
custom_dir="${ZSH_CUSTOM:-$zsh_dir/custom}"
theme_dir="$custom_dir/themes/spaceship-prompt"
theme_link="$custom_dir/themes/spaceship.zsh-theme"
zshrc_dir="${ZDOTDIR:-$HOME}"
config_dir="$HOME/.config/spaceship"
local_zsh_dir="$HOME/.config/zsh"
backup_dir=""

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

backup_file() {
    local target="$1"
    local name="$2"
    [[ -e "$target" || -L "$target" ]] || return 0
    if [[ "$mode" == "apply" ]]; then
        if [[ -z "$backup_dir" ]]; then
            mkdir -p "$HOME/.zsh_config_backup"
            backup_dir="$(mktemp -d "$HOME/.zsh_config_backup/$(date +%Y%m%d-%H%M%S).XXXXXX")"
        fi
        # Preserve symlinks themselves; never overwrite their external targets.
        cp -pP "$target" "$backup_dir/$name"
    else
        printf '[dry-run] back up %s (including symlinks)\n' "$target"
    fi
}

copy_file() {
    local source="$1"
    local target="$2"
    local name="$3"
    if cmp -s "$source" "$target"; then
        printf 'Already current: %s\n' "$target"
        return
    fi
    backup_file "$target" "$name"
    if [[ -L "$target" ]]; then
        run rm -f "$target"
    fi
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

if [[ ! -r "$zsh_dir/oh-my-zsh.sh" ]]; then
    echo "oh-my-zsh not found at $zsh_dir. Install oh-my-zsh first." >&2
    exit 1
fi

echo "Mode: $mode"
echo "Repository: $repo_root"
echo "oh-my-zsh: $zsh_dir"

# Stop before making changes if a file destination is actually a directory.
for target in "$theme_link" "$config_dir/spaceship.zsh" "$zshrc_dir/.zshrc" "$local_zsh_dir/local.zsh"; do
    if [[ -d "$target" ]]; then
        echo "Expected a file, found a directory: $target" >&2
        exit 1
    fi
done

if [[ ! -d "$theme_dir" ]]; then
    run mkdir -p "$custom_dir/themes"
    run git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$theme_dir" --depth=1
elif [[ ! -r "$theme_dir/spaceship.zsh-theme" ]]; then
    echo "Spaceship theme is incomplete at $theme_dir." >&2
    exit 1
fi

if [[ ! -L "$theme_link" || "$(readlink "$theme_link")" != "$theme_dir/spaceship.zsh-theme" ]]; then
    backup_file "$theme_link" "spaceship.zsh-theme"
    if [[ -e "$theme_link" || -L "$theme_link" ]]; then
        run rm -f "$theme_link"
    fi
    run ln -s "$theme_dir/spaceship.zsh-theme" "$theme_link"
fi

run mkdir -p "$config_dir" "$local_zsh_dir" "$zshrc_dir"
copy_file "$repo_root/spaceship/spaceship.zsh" "$config_dir/spaceship.zsh" "spaceship.zsh"
copy_file "$repo_root/.zshrc" "$zshrc_dir/.zshrc" ".zshrc"

if [[ ! -e "$local_zsh_dir/local.zsh" && ! -L "$local_zsh_dir/local.zsh" ]]; then
    if [[ "$mode" == "apply" ]]; then
        (umask 077; cat >"$local_zsh_dir/local.zsh" <<'LOCAL'
# Machine-local zsh configuration.
# Keep host-specific PATH, pyenv, private tools, and secrets here.
LOCAL
        )
    else
        echo "[dry-run] create $local_zsh_dir/local.zsh"
    fi
fi

if [[ "$mode" == "apply" ]]; then
    [[ -z "$backup_dir" ]] || echo "Previous files saved to: $backup_dir"
    echo "Setup complete. Run: zsh -lic 'echo ok'"
else
    echo "Preview complete. Apply with: $0 --apply"
fi
