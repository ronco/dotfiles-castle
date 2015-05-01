# general
alias o='open'
alias grep='grep --color'
alias cls='clear'
alias ls='ls -FG'

# os x
alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
alias fix_airdrop='sudo ifconfig awdl0 up'
alias fix_wifi='sudo ifconfig awdl0 down'

# git
alias gcd='git rev-parse && cd "$(git rev-parse --show-cdup)"'
alias prunebranches='git remote prune origin && git branch --merged | grep -v "\*" | grep -v master | grep -v develop | xargs -n 1 git branch -d'
