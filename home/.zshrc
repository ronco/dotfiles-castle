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
EDITOR='subl -nw' #commented until it works again
ZSH_CUSTOM=~/.oh-my-custom
ZSH_THEME='random'
export EDITOR PAGER RSYNC_RSH COLORTERM HISTFILE HISTSIZE SAVEHIST CLICOLOR ZSH_CUSTOM

alias o='open'
alias grep='grep --color'
alias cls='clear'
alias ls='ls -FG'

alias dbmigrate="bundle exec rake db:migrate db:test:prepare"
alias prc="RAILS_ENV=production rc"
alias testlog="tail -f log/test.log"
alias killrb="killall ruby; pkill -f passenger; killall ruby"
alias bower='noglob bower'
alias rspec_changed="git list-changed-tests | xargs rspec --drb"

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

function back () {
  ack "$@" `bundle show --paths`
}

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

    # theme
    # zgen oh-my-zsh themes/agnoster

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

# NVM, why?

export NVM_DIR=$(brew --prefix nvm)
[ -f $(brew --prefix nvm)/nvm.sh ] && source $(brew --prefix nvm)/nvm.sh
