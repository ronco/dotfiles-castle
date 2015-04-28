alias fix_airdrop='sudo ifconfig awdl0 up'
alias fix_wifi='sudo ifconfig awdl0 down'
alias gcd='git rev-parse --show-cdup | grep -q E ".." && cd (git rev-parse --show-cdup)'
alias prunebranches='git remote prune origin && git branch --merged | grep -v "\*" | grep -v master | grep -v develop | xargs -n 1 git branch -d'
