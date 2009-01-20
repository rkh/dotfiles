#!/bin/bash
# fs3 -> lehrveranstaltungen
# fs2 -> studprofile2007$

## Defaults below

action="$1"
smb="fs2"
rdesktop="admin2"
domainuser="rudolf.zirpmann"
dhcpuser="rudi"

## No edit below this line

function usage {
	echo "Usage:"
	echo "hpi_shares.sh (start|stop) [--samba=SAMBA-SERVER] [--rdesktop=RDESKTOP-SERVER]"
	echo
	echo "start|stop has to come first, others can be arbitary, but only one"
	echo "It will prompt for hpi domain password twice, and for dhcp-server password"
	echo "You have to detach from each screen manually (Usually \"C-a d\")"
	echo
	exit 0
}

function parse {
   var=$1
   if test $(echo "$var" | grep '\-\-samba=' ); then
      smb=$(echo "$var" | sed 's/--samba=//g')
   else 
      if test $(echo "$var" | grep '\-\-rdesktop=' ); then
	 rdesktop=$(echo "$var" | sed 's/--rdesktop=//g')
      else
	 usage
      fi
   fi
}

function start {
   smb=$1
   rdesktop=$2

   echo "Starting as tunnel to smb://$smb and rdesktop://$rdesktop"

   if test "$(ps -C smbd | grep smbd)"; then
      sudo /etc/init.d/samba stop
   fi

   screen -S hpi-tunnel ssh -L 12345:placebo:22 "$domainuser"@ssh-stud.hpi.uni-potsdam.de
   screen -S hpi-dhcp ssh -L 12346:dhcpserver:22 -p 12345 "$domainuser"@127.0.0.1

   # have to run this as root, 139 is a protected port
   sudo screen -S hpi-fs ssh -L 139:"$smb":139 -L 3389:"$rdesktop":3389 -p 12346 "$dhcpuser"@127.0.0.1
}

function stop {
   echo "Stopping all tunnels"

   sudo screen -S hpi-fs -X kill
   screen -S hpi-dhcp -X kill
   screen -S hpi-tunnel -X kill
}

if [ $# -eq 2 ]; then
   parse $2
else if [ $# -eq 3 ]; then
      parse $2
      parse $3
   else if [ $# -ne 1 ]; then
	 usage
      fi
   fi
fi

if [ "$action" = "start" ]; then
   if test "$(screen -ls | grep 'hpi')"; then
      echo "Tunnel already active. Replace? (y/n)"
      read answer
      if [ "$answer" = "y" ]; then
	 stop
      else
	 exit 0
      fi
   fi
   start $smb $rdesktop
else if [ "$action" = "stop" ]; then
      stop
   else
      usage
   fi
fi

