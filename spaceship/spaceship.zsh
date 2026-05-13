# ~/.config/spaceship/spaceship.zsh

# Base display settings
SPACESHIP_PROMPT_ADD_NEWLINE=true
SPACESHIP_PROMPT_SEPARATE_LINE=true
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=true
SPACESHIP_PROMPT_PREFIXES_SHOW=true
SPACESHIP_PROMPT_SUFFIXES_SHOW=true

# Time display
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_PREFIX=$'\uf017 '    # Standard clock icon
# Alternative clock style:
# SPACESHIP_TIME_PREFIX=$'\ue384 '
SPACESHIP_TIME_FORMAT="%D{%H:%M:%S}"
SPACESHIP_TIME_COLOR="yellow"

# User display
SPACESHIP_USER_SHOW=always
SPACESHIP_USER_PREFIX=$'\uf007 '
SPACESHIP_USER_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_USER_COLOR="blue"
SPACESHIP_USER_COLOR_ROOT="red"

# Host display
SPACESHIP_HOST_SHOW=true
SPACESHIP_HOST_PREFIX=$'\uf179 '
SPACESHIP_HOST_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_HOST_COLOR="green"

# Directory display
SPACESHIP_DIR_SHOW=true
SPACESHIP_DIR_PREFIX=$'\uf07c '
SPACESHIP_DIR_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_DIR_TRUNC=3
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_DIR_COLOR="cyan"

# Command execution time
SPACESHIP_EXEC_TIME_SHOW=true
SPACESHIP_EXEC_TIME_PREFIX=$' \uf252 '           # Clock icon with trailing space
SPACESHIP_EXEC_TIME_SUFFIX=" "                  # Suffix spacing
SPACESHIP_EXEC_TIME_COLOR="yellow"
SPACESHIP_EXEC_TIME_ELAPSED=2

# Error status
SPACESHIP_EXIT_CODE_SHOW=true
SPACESHIP_EXIT_CODE_PREFIX="("
SPACESHIP_EXIT_CODE_SUFFIX=") "
SPACESHIP_EXIT_CODE_SYMBOL=$'\uf467 '
SPACESHIP_EXIT_CODE_COLOR="red"

# Prompt character
SPACESHIP_CHAR_PREFIX=""
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_CHAR_SYMBOL=$'\uf179 '  # Apple logo only, no arrow
SPACESHIP_CHAR_COLOR_SUCCESS="green"
SPACESHIP_CHAR_COLOR_FAILURE="red"
SPACESHIP_CHAR_COLOR_SECONDARY="yellow"


# Git settings
SPACESHIP_GIT_SHOW=true
SPACESHIP_GIT_PREFIX=$'\uf126 '              # Git icon with trailing space
SPACESHIP_GIT_SUFFIX=""                      # Remove default suffix
SPACESHIP_GIT_SYMBOL=""                      # Clear symbol to avoid duplication
SPACESHIP_GIT_BRANCH_SHOW=true
SPACESHIP_GIT_BRANCH_PREFIX=""               # Clear prefix to avoid duplication
SPACESHIP_GIT_BRANCH_SUFFIX=" "              # Branch separator spacing
SPACESHIP_GIT_BRANCH_COLOR="magenta"

# Git status spacing and icons
SPACESHIP_GIT_STATUS_SHOW=true
SPACESHIP_GIT_STATUS_PREFIX="[ "              # Opening status bracket
SPACESHIP_GIT_STATUS_SUFFIX="] "             # Closing status bracket with spacing
SPACESHIP_GIT_STATUS_COLOR="red"
# Git status icons with trailing spacing
SPACESHIP_GIT_STATUS_UNTRACKED=$'\uf059 '    # Question mark
SPACESHIP_GIT_STATUS_ADDED=$'\uf055 '        # Plus
SPACESHIP_GIT_STATUS_MODIFIED=$'\uf071 '     # Warning
SPACESHIP_GIT_STATUS_RENAMED=$'\uf45a '      # Arrow
SPACESHIP_GIT_STATUS_DELETED=$'\uf1f8 '      # Trash
SPACESHIP_GIT_STATUS_STASHED=$'\uf187 '      # Box
SPACESHIP_GIT_STATUS_UNMERGED=$'\uf06a '     # Alert
SPACESHIP_GIT_STATUS_AHEAD=$'\uf55c '        # Up arrow
SPACESHIP_GIT_STATUS_BEHIND=$'\uf544 '       # Down arrow
SPACESHIP_GIT_STATUS_DIVERGED=$'\uf47f '     # Diverged

# Node.js settings
SPACESHIP_NODE_SHOW=true
SPACESHIP_NODE_PREFIX=$'\ue718 '
SPACESHIP_NODE_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_NODE_SYMBOL=""
SPACESHIP_NODE_COLOR="green"

# Custom C++ section
spaceship_cpp() {
  [[ -f CMakeLists.txt || -n *.cpp(#qN) || -n *.hpp(#qN) || -n *.h(#qN) || -n *.cc(#qN) ]] || return
  local cpp_version=$(g++ --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
  spaceship::section \
    $'\ufb71 ' \
    "v${cpp_version}"
}

# Custom Rust section
spaceship_rust() {
  [[ -f Cargo.toml || -f Cargo.lock || -n *.rs(#qN) ]] || return
  local rust_version=$(rustc --version | cut -d' ' -f2)
  spaceship::section \
    $'\ue7a8 ' \
    "v${rust_version}"
}


# Python settings
SPACESHIP_PYTHON_SHOW=true
SPACESHIP_PYTHON_PREFIX=$'\ue73c '
SPACESHIP_PYTHON_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_PYTHON_SYMBOL=""
SPACESHIP_PYTHON_COLOR="yellow"

# Java section
spaceship_java() {
  [[ -f pom.xml || -f build.gradle || -n *.java(#qN) ]] || return
  local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
  spaceship::section \
    $'\ue738 ' \
    "v${java_version}"
}

# Go section
spaceship_golang() {
  [[ -f go.mod || -f go.sum || -n *.go(#qN) ]] || return
  local go_version=$(go version | cut -d' ' -f3 | sed 's/go//')
  spaceship::section \
    $'\ue724 ' \
    "v${go_version}"
}

# PHP section
spaceship_php() {
  [[ -f composer.json || -f composer.lock || -n *.php(#qN) ]] || return
  local php_version=$(php -v 2>&1 | head -n1 | cut -d' ' -f2)
  spaceship::section \
    $'\ue73d ' \
    "v${php_version}"
}

# Ruby section
spaceship_ruby() {
  [[ -f Gemfile || -f Rakefile || -n *.rb(#qN) ]] || return
  local ruby_version=$(ruby -v | cut -d' ' -f2)
  spaceship::section \
    $'\ue739 ' \
    "v${ruby_version}"
}

# Kotlin section
spaceship_kotlin() {
  [[ -f *.kt(#qN) || -f *.kts(#qN) ]] || return
  local kotlin_version=$(kotlin -version 2>&1 | cut -d' ' -f3)
  spaceship::section \
    $'\ue70e ' \
    "v${kotlin_version}"
}

# Swift section
spaceship_swift() {
  [[ -f Package.swift || -n *.swift(#qN) ]] || return
  local swift_version=$(swift --version | head -n1 | cut -d' ' -f4)
  spaceship::section \
    $'\ue755 ' \
    "v${swift_version}"
}

# Docker section
spaceship_docker() {
  [[ -f Dockerfile || -f docker-compose.yml ]] || return
  local docker_version=$(docker --version | cut -d' ' -f3 | tr -d ,)
  spaceship::section \
    $'\uf308 ' \
    "v${docker_version}"
}

# Kubernetes section
spaceship_kubernetes() {
  [[ -f kubeconfig || -d ~/.kube ]] || return
  local k8s_context=$(kubectl config current-context 2>/dev/null)
  spaceship::section \
    $'\u2388 ' \
    "${k8s_context}"
}

# Maven section
spaceship_maven() {
  [[ -f pom.xml ]] || return
  local mvn_version=$(mvn --version 2>/dev/null | head -n1 | cut -d' ' -f3)
  spaceship::section \
    $'\ue7c5 ' \
    "v${mvn_version}"
}

# Gradle section
spaceship_gradle() {
  [[ -f build.gradle || -f build.gradle.kts ]] || return
  local gradle_version=$(gradle --version 2>/dev/null | head -n1 | cut -d' ' -f2)
  spaceship::section \
    $'\ue70e ' \
    "v${gradle_version}"
}

# Mercurial (hg) section
spaceship_hg() {
  [[ -d .hg ]] || return
  local hg_branch=$(hg branch 2>/dev/null)
  [[ -z $hg_branch ]] && return
  spaceship::section \
    $'\uf0c3 ' \
    "${hg_branch}"
}

# SVN section
spaceship_svn() {
  [[ -d .svn ]] || return
  local svn_info=$(svn info 2>/dev/null)
  [[ -z $svn_info ]] && return
  local svn_rev=$(echo "$svn_info" | grep "Revision" | cut -d' ' -f2)
  spaceship::section \
    $'\ue721 ' \
    "r${svn_rev}"
}

# AWS section
spaceship_aws() {
  [[ -z $AWS_PROFILE && -z $AWS_DEFAULT_PROFILE && -z $AWS_ACCESS_KEY_ID ]] && return
  local aws_profile="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"
  spaceship::section \
    $'\uf270 ' \
    "${aws_profile}"
}

# Google Cloud section
spaceship_gcloud() {
  [[ -f ~/.config/gcloud/active_config ]] || return
  local gcloud_config=$(cat ~/.config/gcloud/active_config 2>/dev/null)
  spaceship::section \
    $'\uf1a0 ' \
    "${gcloud_config}"
}

# Azure section
spaceship_azure() {
  [[ -n $AZURE_SUBSCRIPTION_ID ]] || return
  local azure_sub=$(az account show --query name -o tsv 2>/dev/null)
  spaceship::section \
    $'\uf0c2 ' \
    "${azure_sub}"
}

# NPM section
spaceship_npm() {
  [[ -f package.json || -f node_modules ]] || return
  local npm_version=$(npm --version 2>/dev/null)
  spaceship::section \
    $'\ue71e ' \
    "v${npm_version}"
}

# Yarn section
spaceship_yarn() {
  [[ -f package.json && -f yarn.lock ]] || return
  local yarn_version=$(yarn --version 2>/dev/null)
  spaceship::section \
    $'\ue718 ' \
    "v${yarn_version}"
}

# Cargo section
spaceship_cargo() {
  [[ -f Cargo.toml ]] || return
  local cargo_version=$(cargo --version 2>/dev/null | cut -d' ' -f2)
  spaceship::section \
    $'\ue7a8 ' \
    "v${cargo_version}"
}

# Pip section
spaceship_pip() {
  [[ -f requirements.txt || -f setup.py ]] || return
  local pip_version=$(pip --version 2>/dev/null | cut -d' ' -f2)
  spaceship::section \
    $'\ue73c ' \
    "v${pip_version}"
}

# Composer section
spaceship_composer() {
  [[ -f composer.json || -f composer.lock ]] || return
  local composer_version=$(composer --version 2>/dev/null | cut -d' ' -f3)
  spaceship::section \
    $'\ue783 ' \
    "v${composer_version}"
}

# Operating system identity settings
SPACESHIP_LINUX_PREFIX=$'\uf17c '    # Linux
SPACESHIP_MACOS_PREFIX=$'\uf179 '    # macOS
SPACESHIP_WINDOWS_PREFIX=$'\uf17a '  # Windows

# AWS settings
SPACESHIP_AWS_SHOW=true
SPACESHIP_AWS_PREFIX=$'\uf270 '
SPACESHIP_AWS_SYMBOL=""
SPACESHIP_AWS_COLOR="yellow"

# Database settings
SPACESHIP_MYSQL_PREFIX=$'\ue704 '    # MySQL
SPACESHIP_POSTGRES_PREFIX=$'\ue76e '  # PostgreSQL
SPACESHIP_MONGO_PREFIX=$'\uf6c4 '    # MongoDB
SPACESHIP_REDIS_PREFIX=$'\ue76d '    # Redis

# Development tool settings
SPACESHIP_VS_PREFIX=$'\ue70c '       # Visual Studio
SPACESHIP_VSCODE_PREFIX=$'\ue70c '   # VS Code
SPACESHIP_IDEA_PREFIX=$'\ue7b5 '     # IntelliJ IDEA
SPACESHIP_SUBLIME_PREFIX=$'\ue7ab '   # Sublime Text
SPACESHIP_VIM_PREFIX=$'\ue62b '      # Vim

# Version control settings
SPACESHIP_GIT_PREFIX=$'\uf1d3 '      # Git
SPACESHIP_SVN_PREFIX=$'\ue721 '      # SVN
SPACESHIP_MERCURY_PREFIX=$'\uf0c3 '   # Mercurial

# Cloud platform settings
SPACESHIP_GCLOUD_PREFIX=$'\uf1a0 '   # Google Cloud
SPACESHIP_AZURE_PREFIX=$'\uf0c2 '    # Azure
SPACESHIP_CLOUD_PREFIX=$'\uf0c2 '    # Generic cloud

# Build tool settings
SPACESHIP_JENKINS_PREFIX=$'\ue767 '   # Jenkins
SPACESHIP_TRAVIS_PREFIX=$'\ue77e '    # Travis CI

# Package manager settings
SPACESHIP_NPM_PREFIX=$'\ue71e '      # NPM
SPACESHIP_YARN_PREFIX=$'\ue718 '     # Yarn
SPACESHIP_CARGO_PREFIX=$'\ue7a8 '    # Cargo
SPACESHIP_PIP_PREFIX=$'\ue73c '      # Pip
SPACESHIP_COMPOSER_PREFIX=$'\ue783 '  # Composer

# Extended prompt order
SPACESHIP_PROMPT_ORDER=(
  time          # Timestamp
  user          # Username
  host          # Hostname
  dir           # Current directory
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
  # yarn          # Yarn
  cargo         # Cargo
  pip           # Pip
  composer      # Composer
  exec_time     # Command execution time
  line_sep      # Line break
  exit_code     # Error code
  char          # Prompt character
)

# Additional style settings
SPACESHIP_PROMPT_ASYNC=true          # Load prompt asynchronously
SPACESHIP_PROMPT_PREFIXES_SHOW=true  # Show prefixes
SPACESHIP_PROMPT_SUFFIXES_SHOW=true  # Show suffixes
SPACESHIP_PROMPT_DEFAULT_PREFIX="via "  # Default prefix
SPACESHIP_PROMPT_DEFAULT_SUFFIX=" "   # Default suffix

# Right prompt

SPACESHIP_RPROMPT_ORDER=(
  jobs          # Background job indicator
)

# Background job icon
SPACESHIP_JOBS_SYMBOL=$'\uf013 '
SPACESHIP_JOBS_COLOR="blue"
