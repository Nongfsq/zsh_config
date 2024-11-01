#!/bin/bash

# 检查是否安装了Zsh
if ! command -v zsh &>/dev/null; then
    echo "Zsh 未安装，请先安装 Zsh。"
    exit 1
fi

# 检查并安装 spaceship-prompt
echo "正在检查 spaceship-prompt..."
if [ ! -d "$ZSH/custom/themes/spaceship-prompt" ]; then
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH/custom/themes/spaceship-prompt" --depth=1
    ln -s "$ZSH/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH/custom/themes/spaceship.zsh-theme"
    echo "spaceship-prompt 安装完成。"
else
    echo "spaceship-prompt 已安装。"
fi

# 复制主题配置文件
CONFIG_DIR="$HOME/.config/spaceship"
mkdir -p "$CONFIG_DIR"
cp ./spaceship/spaceship.zsh "$CONFIG_DIR/"
echo "主题配置文件已复制到 $CONFIG_DIR。"

# 更新 .zshrc
if grep -q "spaceship" "$HOME/.zshrc"; then
    echo ".zshrc 已经包含 spaceship 配置，无需再次添加。"
else
    echo "设置 spaceship 主题到 .zshrc..."
    echo 'ZSH_THEME="spaceship"' >>"$HOME/.zshrc"
    echo ".zshrc 配置已更新。"
fi

echo "配置完成，请重新加载 Zsh 或运行 'source ~/.zshrc'。"
