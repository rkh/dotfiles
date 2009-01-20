# I use this in my .bashrc to have nice VCS stuff.
# Tim Felgentreff (09/20/01): Simplify for speedup, use the git-completion script for git

source ~/bin/git-completion.sh

_bold=$(tput bold)
_normal=$(tput sgr0)

__prompt_command() {
	local vcs base_dir sub_dir ref last_command
	sub_dir() {
		local sub_dir
		sub_dir=$(stat --printf="%n" "${PWD}")
		sub_dir=${sub_dir#$1}
		echo ${sub_dir#/}
	}

	git_dir() {
	   	ref=`__git_ps1`
		if [ -z $ref ]; then return 1; fi
		vcs="git"
		alias pull="git pull"
		alias commit="git commit -v -a"
		alias push="commit ; git push"
		alias revert="git checkout"
	}

	svn_dir() {
		[ -d ".svn" ] || return 1
		ref=$(svn info "$base_dir" | awk '/^URL/ { sub(".*/","",$0); r=$0 } /^Revision/ { sub("[^0-9]*","",$0); print r":"$0 }')		
		# this is too slow...
		#if [ -n $(svn status -q) ]; then
		#   ref="\e[0;31m$ref\e[m"
		#fi 
		ref="[$ref]"
		vcs="svn"
		alias pull="svn up"
		alias commit="svn commit"
		alias push="svn ci"
		alias revert="svn revert"
	}
	
	
	cvs_dir() {
		[ -d "CVS" ] || return 1
		vcs="cvs"
		alias pull="cvs update"
		alias commit="cvs commit"
		alias push="cvs commit"
	}

	bzr_dir() {
		base_dir=$(bzr root 2>/dev/null) || return 1
		ref=$(bzr revno 2>/dev/null)
		vcs="bzr"
		alias pull="bzr pull"
		alias commit="bzr commit"
		alias push="bzr push"
		alias revert="bzr revert"
	}
	

	git_dir || svn_dir || cvs_dir

	if [ -n "$vcs" ]; then
		alias st="$vcs status"
		alias d="$vcs diff"
		alias up="pull"
		alias cdb="cd $base_dir"
		__vcs_ref="$vcs:$ref"
		echo " $__vcs_ref"
	fi
}

#export PROMPT_COMMAND=__prompt_command

# Show the currently running command in the terminal title:
# http://www.davidpashley.com/articles/xterm-titles-with-bash.html
#if [ -z "$TM_SUPPORT_PATH"]; then
#case $TERM in
#  rxvt|*term|xterm-color)
#    trap 'echo -e "\e]1;$working_on>$BASH_COMMAND<\007\c"' DEBUG
#  ;;
#esac
#fi
