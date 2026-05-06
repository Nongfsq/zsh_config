# zsh_config managed shell entrypoint.
# Machine-specific settings belong in ~/.config/zsh/local.zsh.

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
plugins=(git)

# Keep completion and path arrays deterministic when external tools append duplicates.
typeset -U fpath path cdpath

if [[ -r "$HOME/.config/spaceship/spaceship.zsh" ]]; then
    source "$HOME/.config/spaceship/spaceship.zsh"
fi

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
else
    print -u2 "zsh_config: oh-my-zsh not found at $ZSH"
fi

if [[ -r "$HOME/.config/envman/load.sh" ]]; then
    source "$HOME/.config/envman/load.sh"
fi

if command -v thefuck >/dev/null 2>&1; then
    eval "$(thefuck --alias)"
fi

if [[ -r "$HOME/.config/zsh/local.zsh" ]]; then
    source "$HOME/.config/zsh/local.zsh"
fi
