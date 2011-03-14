. ~/.bashrc
# -- start rip config -- #
RIPDIR=/Users/konstantin/.rip
RUBYLIB="$RUBYLIB:$RIPDIR/active/lib"
PATH="$PATH:$RIPDIR/active/bin"
export RIPDIR RUBYLIB PATH
# -- end rip config -- #

##
# Your previous /Users/konstantin/.bash_profile file was backed up as /Users/konstantin/.bash_profile.macports-saved_2009-11-23_at_20:16:24
##

# MacPorts Installer addition on 2009-11-23_at_20:16:24: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

if [[ -s "$HOME/.rvm/scripts/rvm" ]]  ; then source "$HOME/.rvm/scripts/rvm" ; fi
