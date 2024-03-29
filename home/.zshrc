# -----------------------------------------------
# Set up the Environment
# -----------------------------------------------

umask 022

HISTFILE=~/.zhistory
HISTSIZE=100000000
SAVEHIST=100000000
setopt appendhistory
setopt SHARE_HISTORY
unsetopt autocd
bindkey -e #emacs mode
bindkey '^R' history-incremental-search-backward
PAGER=less
RSYNC_RSH=/usr/bin/ssh
COLORTERM=yes
CLICOLOR=yes
# LESS=-RXFEm
EDITOR='emacs'
REPORTTIME=3 # display commands with execution time >= 3 seconds
ZSH_CUSTOM=~/.oh-my-custom
# ZSH_THEME='random'
# ZSH_THEME='rkj-repos'
if [[ -n ${INSIDE_EMACS} ]]; then
    # This shell runs inside an Emacs *shell*/*term* buffer.
    unsetopt zle
fi
export EDITOR PAGER RSYNC_RSH COLORTERM HISTFILE HISTSIZE SAVEHIST CLICOLOR ZSH_CUSTOM REPORTTIME

autoload zmv
zmodload zsh/mathfunc

#randomly delay startup so zgen can get a lock reliably when multiple tabs open
sleep $(( rand48() / 1.5 ))

# -----------------------------------------------
# zgen
# -----------------------------------------------

COMPLETION_WAITING_DOTS="true"

# load zgen
source "${HOME}/.zgen/zgen.zsh"

# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/gitfast
    zgen oh-my-zsh plugins/git-extras
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/capistrano
    zgen oh-my-zsh plugins/osx
    zgen oh-my-zsh plugins/bundler
    zgen oh-my-zsh plugins/gem
    #zgen oh-my-zsh plugins/rails #currently broken
    zgen oh-my-zsh plugins/ruby
    zgen oh-my-zsh plugins/rbenv
    zgen oh-my-zsh plugins/nvm
    zgen oh-my-zsh plugins/screen
    zgen oh-my-zsh plugins/rake-fast
    zgen oh-my-zsh plugins/bower
    zgen oh-my-zsh plugins/gpg-agent

    zgen load zsh-users/zsh-syntax-highlighting
    zgen load caarlos0/zsh-add-upstream

    zgen load StackExchange/blackbox

    # completions
    zgen load zsh-users/zsh-completions src

    # new prompt
    zgen load caiogondim/bullet-train-oh-my-zsh-theme bullet-train

    # iterm touchbar
    zgen load iam4x/zsh-iterm-touchbar

    # save all to init script
    zgen save
fi

# -----------------------------------------------
# zsh vcs_info helpers #todo move these to a script
# -----------------------------------------------

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:(hg*|git*):*' get-revision true
zstyle ':vcs_info:(hg*|git*):*' check-for-changes true

BULLETTRAIN_CONTEXT_DEFAULT_USER=ronco

BULLETTRAIN_PROMPT_ORDER=(
    time
    status
    custom
    context
    dir
    screen
    perl
    ruby
    virtualenv
    conda
    nvm
    aws
    go
    rust
    elixir
    phpbrew
    git
    hg
    cmd_exec_time
)

# Call vcs_info as precmd before every prompt.
prompt_precmd() {
    vcs_info
}
add-zsh-hook precmd prompt_precmd

# Must run vcs_info when changing directories.
prompt_chpwd() {
   FORCE_RUN_VCS_INFO=1
}
add-zsh-hook chpwd prompt_chpwd

# Conda: current working env
prompt_conda() {
  if [[ -n $CONDA_DEFAULT_ENV && ! $CONDA_DEFAULT_ENV == 'base' ]]; then
    prompt_segment $BULLETTRAIN_VIRTUALENV_BG $BULLETTRAIN_VIRTUALENV_FG $BULLETTRAIN_VIRTUALENV_PREFIX" $CONDA_DEFAULT_ENV"
  fi
}

BULLETTRAIN_PHP_PREFIX=🐘

# phpbrew: current working env
prompt_phpbrew() {
  if [[ -n $PHPBREW_PHP ]]; then
    prompt_segment $BULLETTRAIN_PERL_BG $BULLETTRAIN_PERL_FG $BULLETTRAIN_PHP_PREFIX" $PHPBREW_PHP"
  fi
}

# -----------------------------------------------
# nice login stuff
# -----------------------------------------------

uname -nv
echo "------------------------"

source "$HOME/.homesick/repos/homeshick/homeshick.sh"

if [ -f `brew --prefix`/etc/profile.d/z.sh ]; then
  source `brew --prefix`/etc/profile.d/z.sh
fi

# export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
# export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
# export AWS_REGION=$(aws configure get region)

# NVM, why?
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# [ -f $(brew --prefix nvm)/nvm.sh ] && source $(brew --prefix nvm)/nvm.sh
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/opt/homebrew/opt/php@8.0/bin:$PATH"
export PATH="/opt/homebrew/opt/php@8.0/sbin:$PATH"
#phpbrew
[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/ronco/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/ronco/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/ronco/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/ronco/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export CDPATH=".:..:/Users/ronco/dev:$CDPATH"
export AIRFLOW_HOME=~/dev/airflow

alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'

alias usepyenv='eval "$(pyenv init --path)" && export PATH="/Users/ronco/.local/bin:$PATH"'

# OCTAVIA CLI 0.44.4
OCTAVIA_ENV_FILE=/Users/ronco/.octavia
export OCTAVIA_ENABLE_TELEMETRY=True
alias octavia="docker run -i --rm -v \$(pwd):/home/octavia-project --network host --env-file \${OCTAVIA_ENV_FILE} --user \$(id -u):\$(id -g) airbyte/octavia-cli:0.44.4"
