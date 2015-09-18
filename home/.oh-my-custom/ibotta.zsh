alias dbmigrate="bundle exec rake db:migrate && bundle exec rake db:test:prepare"
alias prc="RAILS_ENV=production rc"
alias testlog="tail -f log/test.log"
alias killrb="killall ruby; pkill -f passenger; killall ruby"
alias bower='noglob bower'
alias rspec_changed="git list-changed-tests | xargs rspec --drb"
alias webclean="npm cache clean && bower cache clean && rm -rf node_modules && rm -rf bower_components && rm -rf dist && rm -rf tmp && npm install && bower install"

function back () {
  ack "$@" `bundle show --paths`
}
