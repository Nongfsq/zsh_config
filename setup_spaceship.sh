#!/bin/bash

# 检查是否安装了 Zsh
if ! command -v zsh &>/dev/null; then
    echo "Zsh 未安装，请先安装 Zsh。"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "在 Ubuntu 上使用以下命令安装 Zsh:"
        echo "sudo apt update && sudo apt install zsh"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "在 macOS 上使用 Homebrew 安装 Zsh:"
        echo "brew install zsh"
    fi
    exit 1
fi

# 检查并安装 spaceship-prompt
echo "正在检查 spaceship-prompt..."
if [ ! -d "$ZSH/custom/themes/spaceship-prompt" ]; then
    echo "spaceship-prompt 未安装，正在安装..."
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

# 更新 .zshrc，替换 ZSH_THEME 并添加自定义配置加载
if grep -q 'ZSH_THEME=' "$HOME/.zshrc"; then
    sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="spaceship"/' "$HOME/.zshrc"
    echo "已将 ZSH_THEME 替换为 spaceship。"
else
    echo 'ZSH_THEME="spaceship"' >>"$HOME/.zshrc"
    echo "已在 .zshrc 中添加 ZSH_THEME 设置。"
fi

# 添加自定义配置加载
if ! grep -q "source ~/.config/spaceship/spaceship.zsh" "$HOME/.zshrc"; then
    echo "添加自定义配置加载到 .zshrc..."
    echo -e "\n# 加载自定义配置\nif [ -f ~/.config/spaceship/spaceship.zsh ]; then\n    source ~/.config/spaceship/spaceship.zsh\nfi" >>"$HOME/.zshrc"
    echo "自定义配置加载已添加。"
else
    echo "自定义配置加载已存在，无需再次添加。"
fi

echo "配置完成，请重新加载 Zsh 或运行 'source ~/.zshrc'。"
