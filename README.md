# Zsh Configuration Setup / Zsh 配置设置

此仓库包含用于配置 Zsh 及 Spaceship 主题的配置文件和脚本。

## Prerequisites / 前置条件

在运行脚本之前，请确保系统已安装以下依赖项：

1. **Zsh**: 必须安装 Z shell。
   - 在 Ubuntu 上安装 Zsh：
     ```bash
     sudo apt install zsh
     ```
   - 在 macOS 上安装 Zsh：
     ```bash
     brew install zsh
     ```

2. **Oh My Zsh**: 一个管理 Zsh 配置的社区驱动框架。
   - 安装 Oh My Zsh：
     ```bash
     sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
     ```

3. **Spaceship Prompt**: 一款强大且美观的 Zsh 主题。  
   请确保已安装 Spaceship Prompt，如果未安装，运行以下命令：
   ```bash
   git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH/custom/themes/spaceship-prompt" --depth=1
   ln -s "$ZSH/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH/custom/themes/spaceship.zsh-theme"

## Installation / 安装
克隆此仓库并运行安装脚本：

````bash
git clone https://github.com/Nongfsq/zsh_config.git
cd zsh_config
chmod +x setup_spaceship.sh
./setup_spaceship.sh
````

Post-Installation Verification / 安装后验证
Reload Zsh: 确保在安装和配置完成后重新加载 Zsh 以应用更改：

````bash
source ~/.zshrc
````

Verify Configuration / 验证配置:

确保终端已正确显示 Spaceship 主题。
检查终端提示符是否显示时间、用户、目录、Git 状态等配置项。
Troubleshooting / 问题排查:

如果提示符未正确显示，请检查是否已正确安装支持 Nerd Fonts 的字体，并在终端设置中应用此字体。

检查 .zshrc 文件中是否包含以下行：
```bash
ZSH_THEME="spaceship"
# 加载自定义配置
if [ -f ~/.config/spaceship/spaceship.zsh ]; then
    source ~/.config/spaceship/spaceship.zsh
fi
````
确保按上述步骤进行安装和配置，以获得完整的 Zsh 和 Spaceship 体验。

