# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then . /etc/bashrc; fi  

# General Settings
export PATH="$HOME/bin:/usr/bin:/usr/ucb:$PATH:/opt/bin:/opt/local/bin:.:./bin"
export PWD_LENGTH=30
shopt -s dotglob
shopt -s cdspell
shopt -s checkwinsize
set -o ignoreeof
set -o noclobber

# Bash History
export HISTIGNORE="&:ls:ll:la:l.:pwd:exit:clear"
export HISTCONTROL=ignoreboth
shopt -s histappend          

# Ruby Settings
export RUBY_VERSION=1.8.7
export RUBYOPT=rubygems
export RUBY_PATH=/opt/ruby
export PATH=$RUBY_PATH/bin:$PATH
export SYDNEY=1

# Disable XON/XOFF flow control (^s/^q).
stty -ixon

# SSH specific config.
if [ -n "$SSH_CLIENT" ]; then
  # show host only if this is an ssh session
  ps1_host="\[\033[01;32m\]\h"
fi

# Setting up git.
if [ ! -f ~/.gitconfig ]; then
	git config --global alias.b branch
	git config --global alias.c clone
	git config --global alias.ci commit
	git config --global alias.co checkout
	git config --global alias.st status
	git config --global user.name "Konstantin Haase"
	git config --global user.email "konstantin.mailinglists@googlemail.com"
	git config --global color.branch auto
	git config --global color.diff auto
	git config --global color.grep auto
	git config --global color.interactive auto
	git config --global color.interactive status
	git config --global color.ui auto
	git config --global help.autocorrect 1
	if [ "Darwin" = $(uname) ]; then git config --global core.editor "mate -wl1"; fi
	git config --global github.user "rkh"
	echo "please add your github token to ~/.gitconf"
fi

 . ~/.git_completion

# OS specific config.
case `uname` in
  Darwin)
		export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home"
		export EDITOR="mate -wl1"
		export SVN_EDITOR="mate -wl1"
		function fullscreen() { printf "\e[3;0;0;t\e[8;0;0t"; return 0; }
		alias ls='ls -G'
		;;
  Linux)
		alias ls='ls --color=auto'
		;;
  SunOS)
    stty istrip
    export PATH=/opt/csw/bin:/opt/sfw/bin:$PATH:/etc
    ;;
  *) echo "OS unknown to bashrc." ;;
esac

# Setting up hadoop.
export PATH=$HOME/Workspace/jaql/bin:$HOME/Repositories/hadoop-0.18.3/bin:$HOME/Repositories/jaql-0.4/bin:$PATH:/home/hadoop/hadoop/bin/
if [ `which hadoop-config.sh 2>/dev/null` ]; then
  . `which hadoop-config.sh`
  $(dirname $(which hadoop))
  export PIGDIR=$HOME/pig
  if [ `which jaql 2>/dev/null` ]; then
    export JAQL_HOME=$(dirname "$(dirname "$(which jaql)")")
  fi
fi

# Don't show user name if it's me. make root red.
case $USER in
  konstantin|khaase|konstantin.haase|rkh|hadoop02) ;;
  root)
		ps1_user="\[\033[01;31m\]\u"
		echo "root will be logged out after 10 minutes without input or job"
		export TMOUT=600
		;;
  *) ps1_user="\[\033[01;32m\]\u" ;;
esac

# VCS in prompt.
parse_svn_branch() { parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print " (svn: "$1 "/" $2 ")"}'; }
parse_svn_url() { svn info 2>/dev/null | sed -ne 's#^URL: ##p'; }
parse_svn_repository_root() { LANG=C svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'; }

# FIXME LATER
#ps1_vcs='\[\033[01;33m\]$(__git_ps1 " (git: %s)")$(parse_svn_branch)\[\033[00m\]'
ps1_vcs='\[\033[01;33m\]$(__git_ps1 " (git: %s)")\[\033[00m\]'

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
if [ "$PS1" != "" ]; then PS1="$PS1\[\033[01;30m\]:\[\033[00m\]"; fi
export PS1="$PS1$ps1_pwd$ps1_vcs $ps1_ruby\[\033[01;32m\]→\[\033[00m\] "

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# If this is an xterm set the title to user@host:dir.
case "$TERM" in
  xterm*|rxvt*) export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"' ;;
  *) ;;
esac

# Enable color support. Don't add ls here, it behaves different on Darwin/BSD.
if [ -x /usr/bin/dircolors ]; then eval "`dircolors -b`"; fi
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Some more aliases.
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias pdflatex='pdflatex -shell-escape'
alias vi='vim'

# shorthands - i do this a lot
ruby_version() { if [ -z $1 ]; then echo $RUBY_VERSION; else RUBY_VERSION=$1; fi; }

# if cat is called on a directory, call ls instead
cat() {
	if [ $# = 1 ] && [ -d $1 ]; then
		ls $1
	else
		`which cat` "$@"
	fi
}

# Enable programmable completion features.
if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi
if [ -f ~/.tabtab.bash ]; then . ~/.tabtab.bash; fi
set show-all-if-ambiguous on

# Clean up.
unset ps1_user ps1_host ps1_vcs ps_ruby ps1_pwd
