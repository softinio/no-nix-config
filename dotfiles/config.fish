# Fish Shell Configuration
# Converted from nixpkgs configuration

# ============================================================================
# Functions
# ============================================================================

function gitignore
    curl -sL https://www.gitignore.io/api/$argv
end

# ============================================================================
# Environment Variables
# ============================================================================

set -xg TERM xterm-256color

# PATH configuration
set -xg PATH $HOME/bin $HOME/.local/bin $HOME/.cargo/bin $HOME/.npm-global/bin \
    $HOME/.luarocks/bin \
    /opt/local/bin /opt/local/sbin \
    /usr/local/bin /usr/bin /bin /usr/sbin /sbin \
    /Applications/WezTerm.app/Contents/MacOS \
    $PATH

# Workspace
set -xg WORKSPACE $HOME/Projects

# FZF configuration
set -xg FZF_DEFAULT_OPTS "--preview='bat {} --color=always'"

# Ripgrep
set -xg USE_BUILTIN_RIPGREP 0

# PostgreSQL (MacPorts postgresql18)
if test -d /opt/local/lib/postgresql18/bin
    set -xg PATH /opt/local/lib/postgresql18/bin $PATH
    set -xg PGDATA /opt/local/var/db/postgresql18/defaultdb
    set -xg PGHOST localhost
end

# API Keys (if files exist)
if test -f ~/.openai
    set -xg OPENAI_API_KEY (cat ~/.openai)
end

if test -f ~/.anthropic
    set -xg ANTHROPIC_API_KEY (cat ~/.anthropic)

end

if test -f /Library/Developer/Toolchains/swift-6.2.3-RELEASE.xctoolchain/Info.plist
    set -xg TOOLCHAINS (plutil -extract CFBundleIdentifier raw /Library/Developer/Toolchains/swift-6.2.3-RELEASE.xctoolchain/Info.plist)
    set -xg PATH /Library/Developer/Toolchains/swift-6.2.3-RELEASE.xctoolchain/usr/bin $PATH
end

# ============================================================================
# Interactive Shell Initialization
# ============================================================================

if status is-interactive
    # Starship prompt
    if type -q starship
        starship init fish | source
    end

    # jj (Jujutsu) completions
    if type -q jj
        jj util completion fish | source
    end

    # direnv integration
    if type -q direnv
        direnv hook fish | source
    end
end

# ============================================================================
# Aliases
# ============================================================================

alias addsshmac="ssh-add ~/.ssh/id_ed25519 --apple-use-keychain --apple-load-keychain"
alias bf="broot"
alias cat="bat"
alias du="dua i"
alias linesofcode="git ls-files | xargs wc -l"
alias fzfp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
alias ping="prettyping"
alias ..="cd .."
alias pj="python -m json.tool"
alias g="git"
alias ghauth="gh auth login --with-token < ~/.ghauth"
alias gitpurgemain='git branch --merged | grep -v "\*" | grep -v "main" | xargs -n 1 git branch -d'
alias gitpurgemaster='git branch --merged | grep -v "\*" | grep -v "master" | xargs -n 1 git branch -d'
alias gforksync="git fetch upstream && git merge upstream/master && git push origin master"
alias grep="grep --color=auto"
alias lg="lazygit"
alias rmxcodederived="rm -fr ~/Library/Developer/Xcode/DerivedData"
alias v="nvim"
alias sshhcloud1="ssh salar@hcloud1.softinio.net"
alias sshhcloud1r="ssh root@hcloud1.softinio.net"

# Eza (modern ls replacement) - matches nixpkgs settings
if type -q eza
    alias ls="eza --git --icons=auto --group-directories-first"
    alias ll="eza --git --icons=auto --group-directories-first --long --header --all"
    alias l="ll"
    alias la="eza --git --icons=auto --group-directories-first --long --header --all --all"
    alias lt="eza --git --icons=auto --group-directories-first --tree --level=2"
    alias lta="eza --git --icons=auto --group-directories-first --tree --level=2 --all"
end

# ============================================================================
# Plugin Notes
# ============================================================================
# The following plugins should be installed manually:
#
# 1. fish-ssh-agent - Install with fisher:
#    fisher install danhper/fish-ssh-agent
#
# To install fisher (plugin manager):
#    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
#
# Note: This config uses Starship prompt (not bobthefish theme)

# >>> coursier install directory >>>
set -gx PATH "$PATH:/Users/salar/Library/Application Support/Coursier/bin"
# <<< coursier install directory <<<
