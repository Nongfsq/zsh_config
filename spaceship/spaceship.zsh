# ~/.config/spaceship/spaceship.zsh

# 基础显示设置
SPACESHIP_PROMPT_ADD_NEWLINE=true
SPACESHIP_PROMPT_SEPARATE_LINE=true
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=true
SPACESHIP_PROMPT_PREFIXES_SHOW=true
SPACESHIP_PROMPT_SUFFIXES_SHOW=true

# 时间显示
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_PREFIX=$'\uf017 '    # 使用一个更标准的时钟图标
# 或者尝试这个
# SPACESHIP_TIME_PREFIX=$'\ue384 '  # 另一个时钟样式
SPACESHIP_TIME_FORMAT="%D{%H:%M:%S}"
SPACESHIP_TIME_COLOR="yellow"

# 用户显示
SPACESHIP_USER_SHOW=always
SPACESHIP_USER_PREFIX=$'\uf007 '
SPACESHIP_USER_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_USER_COLOR="blue"
SPACESHIP_USER_COLOR_ROOT="red"

# 主机名显示
SPACESHIP_HOST_SHOW=true
SPACESHIP_HOST_PREFIX=$'\uf179 '
SPACESHIP_HOST_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_HOST_COLOR="green"

# 目录显示
SPACESHIP_DIR_SHOW=true
SPACESHIP_DIR_PREFIX=$'\uf07c '
SPACESHIP_DIR_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_DIR_TRUNC=3
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_DIR_COLOR="cyan"

# 命令执行时间
SPACESHIP_EXEC_TIME_SHOW=true
SPACESHIP_EXEC_TIME_PREFIX=$' \uf252 '           # 时钟图标，确保后面有空格
SPACESHIP_EXEC_TIME_SUFFIX=" "                  # 添加后缀空格
SPACESHIP_EXEC_TIME_COLOR="yellow"
SPACESHIP_EXEC_TIME_ELAPSED=2

# 错误状态
SPACESHIP_EXIT_CODE_SHOW=true
SPACESHIP_EXIT_CODE_PREFIX="("
SPACESHIP_EXIT_CODE_SUFFIX=") "
SPACESHIP_EXIT_CODE_SYMBOL=$'\uf467 '
SPACESHIP_EXIT_CODE_COLOR="red"

# 提示符 - 使用苹果logo
SPACESHIP_CHAR_PREFIX=""
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_CHAR_SYMBOL=$'\uf179 '  # 只使用苹果logo，移除箭头
SPACESHIP_CHAR_COLOR_SUCCESS="green"
SPACESHIP_CHAR_COLOR_FAILURE="red"
SPACESHIP_CHAR_COLOR_SECONDARY="yellow"


# Git 设置
SPACESHIP_GIT_SHOW=true
SPACESHIP_GIT_PREFIX=$'\uf126 '              # Git 图标，确保后面有空格
SPACESHIP_GIT_SUFFIX=""                      # 移除默认后缀
SPACESHIP_GIT_SYMBOL=""                      # 清空符号避免重复
SPACESHIP_GIT_BRANCH_SHOW=true
SPACESHIP_GIT_BRANCH_PREFIX=""               # 清空前缀避免重复
SPACESHIP_GIT_BRANCH_SUFFIX=" "              # 添加空格分隔
SPACESHIP_GIT_BRANCH_COLOR="magenta"

# Git 状态设置，调整间距和图标
SPACESHIP_GIT_STATUS_SHOW=true
SPACESHIP_GIT_STATUS_PREFIX="[ "              # 使用圆括号替代方括号
SPACESHIP_GIT_STATUS_SUFFIX="] "             # 添加后缀空格
SPACESHIP_GIT_STATUS_COLOR="red"
# Git 状态图标，确保每个图标后面都有空格
SPACESHIP_GIT_STATUS_UNTRACKED=$'\uf059 '    # 问号
SPACESHIP_GIT_STATUS_ADDED=$'\uf055 '        # 加号
SPACESHIP_GIT_STATUS_MODIFIED=$'\uf071 '     # 感叹号
SPACESHIP_GIT_STATUS_RENAMED=$'\uf45a '      # 箭头
SPACESHIP_GIT_STATUS_DELETED=$'\uf1f8 '      # 垃圾桶
SPACESHIP_GIT_STATUS_STASHED=$'\uf187 '      # 盒子
SPACESHIP_GIT_STATUS_UNMERGED=$'\uf06a '     # 警告
SPACESHIP_GIT_STATUS_AHEAD=$'\uf55c '        # 上箭头
SPACESHIP_GIT_STATUS_BEHIND=$'\uf544 '       # 下箭头
SPACESHIP_GIT_STATUS_DIVERGED=$'\uf47f '     # 分叉# Node.js 设置
SPACESHIP_NODE_SHOW=true
SPACESHIP_NODE_PREFIX=$'\ue718 '
SPACESHIP_NODE_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_NODE_SYMBOL=""
SPACESHIP_NODE_COLOR="green"

# 自定义 C++ 段落
spaceship_cpp() {
  [[ -f CMakeLists.txt || -n *.cpp(#qN) || -n *.hpp(#qN) || -n *.h(#qN) || -n *.cc(#qN) ]] || return
  local cpp_version=$(g++ --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
  spaceship::section \
    $'\ufb71 ' \
    "v${cpp_version}"
}

# 自定义 Rust 段落
spaceship_rust() {
  [[ -f Cargo.toml || -f Cargo.lock || -n *.rs(#qN) ]] || return
  local rust_version=$(rustc --version | cut -d' ' -f2)
  spaceship::section \
    $'\ue7a8 ' \
    "v${rust_version}"
}


# Python 设置
SPACESHIP_PYTHON_SHOW=true
SPACESHIP_PYTHON_PREFIX=$'\ue73c '
SPACESHIP_PYTHON_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_PYTHON_SYMBOL=""
SPACESHIP_PYTHON_COLOR="yellow"

# Java 段落
spaceship_java() {
  [[ -f pom.xml || -f build.gradle || -n *.java(#qN) ]] || return
  local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
  spaceship::section \
    $'\ue738 ' \
    "v${java_version}"
}

# Go 段落
spaceship_golang() {
  [[ -f go.mod || -f go.sum || -n *.go(#qN) ]] || return
  local go_version=$(go version | cut -d' ' -f3 | sed 's/go//')
  spaceship::section \
    $'\ue724 ' \
    "v${go_version}"
}

# PHP 段落
spaceship_php() {
  [[ -f composer.json || -f composer.lock || -n *.php(#qN) ]] || return
  local php_version=$(php -v 2>&1 | head -n1 | cut -d' ' -f2)
  spaceship::section \
    $'\ue73d ' \
    "v${php_version}"
}

# Ruby 段落
spaceship_ruby() {
  [[ -f Gemfile || -f Rakefile || -n *.rb(#qN) ]] || return
  local ruby_version=$(ruby -v | cut -d' ' -f2)
  spaceship::section \
    $'\ue739 ' \
    "v${ruby_version}"
}

# Kotlin 段落
spaceship_kotlin() {
  [[ -f *.kt(#qN) || -f *.kts(#qN) ]] || return
  local kotlin_version=$(kotlin -version 2>&1 | cut -d' ' -f3)
  spaceship::section \
    $'\ue70e ' \
    "v${kotlin_version}"
}

# Swift 段落
spaceship_swift() {
  [[ -f Package.swift || -n *.swift(#qN) ]] || return
  local swift_version=$(swift --version | head -n1 | cut -d' ' -f4)
  spaceship::section \
    $'\ue755 ' \
    "v${swift_version}"
}

# Docker 段落
spaceship_docker() {
  [[ -f Dockerfile || -f docker-compose.yml ]] || return
  local docker_version=$(docker --version | cut -d' ' -f3 | tr -d ,)
  spaceship::section \
    $'\uf308 ' \
    "v${docker_version}"
}

# Kubernetes 段落
spaceship_kubernetes() {
  [[ -f kubeconfig || -d ~/.kube ]] || return
  local k8s_context=$(kubectl config current-context 2>/dev/null)
  spaceship::section \
    $'\u2388 ' \
    "${k8s_context}"
}

# Maven 段落
spaceship_maven() {
  [[ -f pom.xml ]] || return
  local mvn_version=$(mvn --version 2>/dev/null | head -n1 | cut -d' ' -f3)
  spaceship::section \
    $'\ue7c5 ' \
    "v${mvn_version}"
}

# Gradle 段落
spaceship_gradle() {
  [[ -f build.gradle || -f build.gradle.kts ]] || return
  local gradle_version=$(gradle --version 2>/dev/null | head -n1 | cut -d' ' -f2)
  spaceship::section \
    $'\ue70e ' \
    "v${gradle_version}"
}

# Mercurial (hg) 段落
spaceship_hg() {
  [[ -d .hg ]] || return
  local hg_branch=$(hg branch 2>/dev/null)
  [[ -z $hg_branch ]] && return
  spaceship::section \
    $'\uf0c3 ' \
    "${hg_branch}"
}

# SVN 段落
spaceship_svn() {
  [[ -d .svn ]] || return
  local svn_info=$(svn info 2>/dev/null)
  [[ -z $svn_info ]] && return
  local svn_rev=$(echo "$svn_info" | grep "Revision" | cut -d' ' -f2)
  spaceship::section \
    $'\ue721 ' \
    "r${svn_rev}"
}

# AWS 段落
spaceship_aws() {
  [[ -z $AWS_PROFILE && -z $AWS_DEFAULT_PROFILE && -z $AWS_ACCESS_KEY_ID ]] && return
  local aws_profile="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"
  spaceship::section \
    $'\uf270 ' \
    "${aws_profile}"
}

# Google Cloud 段落
spaceship_gcloud() {
  [[ -f ~/.config/gcloud/active_config ]] || return
  local gcloud_config=$(cat ~/.config/gcloud/active_config 2>/dev/null)
  spaceship::section \
    $'\uf1a0 ' \
    "${gcloud_config}"
}

# Azure 段落
spaceship_azure() {
  [[ -n $AZURE_SUBSCRIPTION_ID ]] || return
  local azure_sub=$(az account show --query name -o tsv 2>/dev/null)
  spaceship::section \
    $'\uf0c2 ' \
    "${azure_sub}"
}

# NPM 段落
spaceship_npm() {
  [[ -f package.json || -f node_modules ]] || return
  local npm_version=$(npm --version 2>/dev/null)
  spaceship::section \
    $'\ue71e ' \
    "v${npm_version}"
}

# Yarn 段落
spaceship_yarn() {
  [[ -f package.json && -f yarn.lock ]] || return
  local yarn_version=$(yarn --version 2>/dev/null)
    $'\ue718 ' \
    "v${yarn_version}"
}

# Cargo 段落
spaceship_cargo() {
  [[ -f Cargo.toml ]] || return
  local cargo_version=$(cargo --version 2>/dev/null | cut -d' ' -f2)
    $'\ue7a8 ' \
    "v${cargo_version}"
}

# Pip 段落
spaceship_pip() {
  [[ -f requirements.txt || -f setup.py ]] || return
  local pip_version=$(pip --version 2>/dev/null | cut -d' ' -f2)
  spaceship::section \
    $'\ue73c ' \
    "v${pip_version}"
}

# Composer 段落
spaceship_composer() {
  [[ -f composer.json || -f composer.lock ]] || return
  local composer_version=$(composer --version 2>/dev/null | cut -d' ' -f3)
  spaceship::section \
    $'\ue783 ' \
    "v${composer_version}"
}

# 操作系统标识配置
SPACESHIP_LINUX_PREFIX=$'\uf17c '    # Linux
SPACESHIP_MACOS_PREFIX=$'\uf179 '    # macOS
SPACESHIP_WINDOWS_PREFIX=$'\uf17a '  # Windows

# AWS 配置
SPACESHIP_AWS_SHOW=true
SPACESHIP_AWS_PREFIX=$'\uf270 '
SPACESHIP_AWS_SYMBOL=""
SPACESHIP_AWS_COLOR="yellow"

# 数据库配置
SPACESHIP_MYSQL_PREFIX=$'\ue704 '    # MySQL
SPACESHIP_POSTGRES_PREFIX=$'\ue76e '  # PostgreSQL
SPACESHIP_MONGO_PREFIX=$'\uf6c4 '    # MongoDB
SPACESHIP_REDIS_PREFIX=$'\ue76d '    # Redis

# 开发工具配置
SPACESHIP_VS_PREFIX=$'\ue70c '       # Visual Studio
SPACESHIP_VSCODE_PREFIX=$'\ue70c '   # VS Code
SPACESHIP_IDEA_PREFIX=$'\ue7b5 '     # IntelliJ IDEA
SPACESHIP_SUBLIME_PREFIX=$'\ue7ab '   # Sublime Text
SPACESHIP_VIM_PREFIX=$'\ue62b '      # Vim

# 版本控制配置
SPACESHIP_GIT_PREFIX=$'\uf1d3 '      # Git
SPACESHIP_SVN_PREFIX=$'\ue721 '      # SVN
SPACESHIP_MERCURY_PREFIX=$'\uf0c3 '   # Mercurial

# 云平台配置
SPACESHIP_GCLOUD_PREFIX=$'\uf1a0 '   # Google Cloud
SPACESHIP_AZURE_PREFIX=$'\uf0c2 '    # Azure
SPACESHIP_CLOUD_PREFIX=$'\uf0c2 '    # Generic cloud

# 构建工具配置
SPACESHIP_JENKINS_PREFIX=$'\ue767 '   # Jenkins
SPACESHIP_TRAVIS_PREFIX=$'\ue77e '    # Travis CI

# 包管理器配置
SPACESHIP_NPM_PREFIX=$'\ue71e '      # NPM
SPACESHIP_YARN_PREFIX=$'\ue718 '     # Yarn
SPACESHIP_CARGO_PREFIX=$'\ue7a8 '    # Cargo
SPACESHIP_PIP_PREFIX=$'\ue73c '      # Pip
SPACESHIP_COMPOSER_PREFIX=$'\ue783 '  # Composer

# 扩展提示符顺序
SPACESHIP_PROMPT_ORDER=(
  time          # 时间戳
  user          # 用户名
  host          # 主机名
  dir           # 当前目录
  git           # Git
  hg            # Mercurial
  svn           # SVN
  docker        # Docker
  kubernetes    # Kubernetes
  aws           # AWS
  gcloud        # Google Cloud
  azure         # Azure
  java          # Java
  kotlin        # Kotlin
  golang        # Go
  php           # PHP
  ruby          # Ruby
  swift         # Swift
  node          # Node.js
  python        # Python
  cpp           # C++
  rust          # Rust
  maven         # Maven
  gradle        # Gradle
  npm           # NPM
  yarn          # Yarn
  cargo         # Cargo
  pip           # Pip
  composer      # Composer
  exec_time     # 命令执行时间
  line_sep      # 换行
  exit_code     # 错误代码
  char          # 提示符
)

# 额外的样式配置
SPACESHIP_PROMPT_ASYNC=true          # 异步加载提示符
SPACESHIP_PROMPT_PREFIXES_SHOW=true  # 显示前缀
SPACESHIP_PROMPT_SUFFIXES_SHOW=true  # 显示后缀
SPACESHIP_PROMPT_DEFAULT_PREFIX="via "  # 默认前缀
SPACESHIP_PROMPT_DEFAULT_SUFFIX=" "   # 默认后缀# 右侧提示符

SPACESHIP_RPROMPT_ORDER=(
  jobs          # 后台任务指示器
)

# 后台任务图标
SPACESHIP_JOBS_SYMBOL=$'\uf013 '
SPACESHIP_JOBS_COLOR="blue"
