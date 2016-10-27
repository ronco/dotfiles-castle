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
ZSH_THEME='rkj-repos'
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

# -----------------------------------------------
# nice login stuff
# -----------------------------------------------

uname -nv
echo "------------------------"

source "$HOME/.homesick/repos/homeshick/homeshick.sh"

[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh

if [ -f `brew --prefix`/etc/profile.d/z.sh ]; then
  source `brew --prefix`/etc/profile.d/z.sh
fi

export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
export AWS_REGION=$(aws configure get region)

# NVM, why?

export NVM_DIR=$(brew --prefix nvm)
[ -f $(brew --prefix nvm)/nvm.sh ] && source $(brew --prefix nvm)/nvm.sh
