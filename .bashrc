# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then . /etc/bashrc; fi  

# General Settings
export PATH="$HOME/bin:/usr/bin:/usr/ucb:$PATH:/opt/bin:.:./bin"
export PWD_LENGTH=30

# Bash History
export HISTCONTROL=ignoreboth
shopt -s histappend          
shopt -s checkwinsize 

# Ruby Settings
export RUBY_VERSION=1.8.7
export RUBYOPT=rubygems
export GEM_GLOBAL="install|cleanup|generate_index|pristine|rdoc|update"
export PATH=/opt/ruby/bin:$PATH
export SYDNEY=1

# ssh specific config
if [ -n "$SSH_CLIENT" ]; then
  # show host only if this is an ssh session
  ps1_host="\h"
fi

# Setting up hadoop
if [ `which hadoop-config.sh 2>/dev/null` ]; then
  . `which hadoop-config.sh`
  if [ `which jaql 2>/dev/null` ]; then
    export JAQL_HOME=$(dirname $(dirname $(which jaql)))
  fi
fi

# OS specific config.
case `uname` in
  Darwin)
	. .git_completion
	;;
  Linux) ;;
  SunOS)
    stty istrip
    export PATH=$PATH:/etc
    ;;
  *) echo "OS unknown to bashrc." ;;
esac

# Don't show user name if it's me. make root red.
case `whoami` in
  konstantin|khaase|konstantin.haase|rkh) ;;
  root) ps1_user="\[\033[01;31m\]\u" ;;
  *) ps1_user="\[\033[01;32m\]\u" ;;
esac

# VCS in prompt.
parse_svn_branch() {
  parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print " (svn: "$1 "/" $2 ")"}'
}
parse_svn_url() {
  svn info 2>/dev/null | sed -ne 's#^URL: ##p'
}
parse_svn_repository_root() {
  LANG=C svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
}

ps1_vcs='\[\033[01;33m\]$(__git_ps1 " (git: %s)")$(parse_svn_branch)\[\033[00m\]'

# Ruby version in prompt if Rakefile exists.
show_ruby_version() {
  if [ -f "Rakefile" ]; then echo -n "$RUBY_VERSION "; fi
}

ps1_ruby='\[\033[01;30m\]$(show_ruby_version)\[\033[00m\]'

# Short PWD, if it's to long.
short_pwd() {
  FIXED_PWD=$(echo $PWD | sed "s:^$HOME:~:g")
  if [ ${#FIXED_PWD} -gt $(($PWD_LENGTH)) ]; then
    echo "${FIXED_PWD:0:$((4))}...${FIXED_PWD:$((${#PWD}-$PWD_LENGTH+7)):$(($PWD_LENGTH-7))}"
  else
    echo "$FIXED_PWD"
  fi
}

ps1_pwd='\[\033[00;32m\]$(short_pwd)\[\033[00m\]'

# Building $PS1.
if [ -n "$ps1_user" ] && [ -n "$ps1_host" ]; then ps1_user="$ps1_user@"; fi
PS1="$ps1_user$ps1_host"
if [ "$PS1" != "" ]; then PS1="$PS1\[\033[00m\]:"; fi
export PS1="$PS1$ps1_pwd$ps1_vcs $ps1_ruby\[\033[01;32m\]→\[\033[00m\] "

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# If this is an xterm set the title to user@host:dir.
case "$TERM" in
  xterm*|rxvt*) export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"' ;;
  *) ;;
esac

# Enable color support of ls and also add handy aliases.
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Some more aliases.
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias pdflatex='pdflatex -shell-escape'
alias sudo='sudo -E'
alias vi='vim'

# Enable programmable completion features.
if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi
set show-all-if-ambiguous on

# Clean up.
unset ps1_user ps1_host ps1_vcs default_user
