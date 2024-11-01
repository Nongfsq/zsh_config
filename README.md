# Zsh Configuration Setup / Zsh 配置设置

This repository contains configuration files and a setup script for configuring Zsh with the Spaceship theme.  
此仓库包含用于配置 Zsh 及 Spaceship 主题的配置文件和脚本。

## Prerequisites / 前置条件

Before running the setup, ensure the following dependencies are installed on your system:  
在运行脚本之前，请确保系统已安装以下依赖项：

1. **Zsh**: The Z shell is required for these configurations.  
   必须安装 Z shell。
   - Install Zsh using / 安装 Zsh：
     ```bash
     sudo apt install zsh
     ```
     Or on macOS / 或在 macOS 上：
     ```bash
     brew install zsh
     ```

2. **Oh My Zsh**: A community-driven framework for managing Zsh configuration.  
   一个管理 Zsh 配置的社区驱动框架。
   - Install Oh My Zsh / 安装 Oh My Zsh：
     ```bash
     sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
     ```

## Installation / 安装

Clone this repository and run the setup script:  
克隆此仓库并运行安装脚本：

```bash
git clone https://github.com/Nongfsq/zsh_config.git
cd zsh_config
chmod +x setup_spaceship.sh
./setup_spaceship.sh

