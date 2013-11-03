#!/usr/bin/env bash
#
# This script is intended to easily open and run 
# an SSH tunnel as a background process.
#
# ./ssh-tunnel.sh -p 8080 -s me@myshell.com
#
# $Id: ssh-tunnel.sh,v 1.2 2011/09/01 11:27:26 seanodonnell Exp $
#
LOGFILE=~/ssh-tunnel.log

echo -e "\nSean's SSH Tunnel Runner\n-------------------------";

function validate_server()
{
	# prompt for input if flags not used
	if [ -z ${SERVER} ]; then
		echo -e "\nPlease define your ssh server connection string.\n\ni.e. -s myusername@myserver.com\n";
		read SERVER
		validate_server;
	fi
}

function validate_port()
{
	if [ -z ${PORT} ]; then
		echo -e "\nPlease define a port #.\n\ni.e. -p 8080\n";
		read PORT
		validate_port;
	fi
}

function open_tunnel()
{
	echo -e "\nOpening SSH Tunnel: ssh -C2TnN -D ${PORT} ${SERVER}";
	ssh -C2TnN -D ${PORT} ${SERVER} 2>&1 > ${LOGFILE} &
	echo -e "Tunnel open and running in the background.\n\nLog file: ${LOGFILE}\n";
}

# allow flags to prevent prompting for input
while getopts "p::s::" opt; do
	case $opt in
		p)
			PORT=$OPTARG;
			;;
		s)
			SERVER=$OPTARG;
			;;
		*)
			echo "\nInvalid option: $opt"
			exit;
			;;
	esac
done

validate_server;
validate_port;
open_tunnel;
