# export PATH="/usr/local/opt/openjdk@8/bin:$PATH"
# export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk-8.jdk/Contents/Home"

autoload -U colors && colors
PS1="%B%{$fg[grey]%}%n%b | %U%{$fg[yellow]%}%2~%u %B%{$fg[white]%}$%b %{$reset_color%}"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ls='ls -GFm'
alias ll='ls -oAD "%F %R"'

export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'

# default to Java 11
java11
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export TERM=xterm 
alias icssensoria2='ssh -i ~/.ssh/ics2 srirar1@sensoria-2.ics.uci.edu'
alias clush='pdsh'
alias ssh-harry='ssh -i ~/Downloads/clickhouse.pem ec2-user@3.138.154.75'
alias ssh-hermione='ssh -i ~/Downloads/clickhouse.pem ec2-user@3.145.150.127'
alias ssh-ron='ssh -i ~/Downloads/clickhouse.pem ec2-user@18.188.232.215'
alias ssh-coordinator='ssh -i ~/Downloads/clickhouse.pem ec2-user@18.217.254.112'
alias ssh-duck='ssh -i ~/.ssh/clickhouse.pem ec2-user@18.220.207.220'

eval "$(zoxide init zsh)"

# Path additions
export PATH="$PATH:/Users/sriramrao/Code/apps/depot_tools"

# Created by `pipx` on 2024-11-05 23:27:42
export PATH="$PATH:/Users/sriramrao/.local/bin"

# For Ruby
export PATH=/usr/local/bin:$PATH
eval "$(rbenv init -)"

export PATH='/Users/sriramrao/.duckdb/cli/latest':$PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. $(brew --prefix asdf)/libexec/asdf.sh
. $(brew --prefix asdf)/libexec/asdf.sh

# Added by Windsurf
export PATH="/Users/sriramrao/.codeium/windsurf/bin:$PATH"

# API Keys - load when needed
unalias key 2>/dev/null
key() {
  source ~/.api_keys "$@"
}
lock() {
  unset AVANTE_ANTHROPIC_API_KEY
  unset ANTHROPIC_API_KEY
  unset CLAUDE_CODE_OAUTH_TOKEN
  unset AVANTE_OPENAI_API_KEY
  unset OPENAI_API_KEY
  unset GITHUB_TOKEN
  unset MORPH_API_KEY
  unset GOOGLE_SEARCH_ENGINE_ID
  unset GOOGLE_SEARCH_API_KEY
  unset GEMINI_API_KEY
  unset TABBY_TOKEN
}
key openai
key google
key claude_oauth

alias claude_api="$(whence -p claude)"
claude() { env -u ANTHROPIC_API_KEY "$(whence -p claude)" "$@"; }

# Nix
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
