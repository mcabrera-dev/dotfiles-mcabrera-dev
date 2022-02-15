# GENERAL
# GENERAL
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias webstorm='~/webstorm'
alias l='ls -laGFhS'
alias ls='ls -aGFhS'
alias lg='l | grep --color=auto'
cd() { builtin cd "$@"; ls; }
alias ip='ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk "{print $2}"'
alias publicIp="curl https://ipinfo.io/ip"
trash () { command mv "$@" ~/.Trash; }
