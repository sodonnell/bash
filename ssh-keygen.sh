#!/usr/bin/env bash 
# 
# ssh-keygen.sh 
# 
# Use this simple shell script to generate your 
# public rsa/dsa (SSH) encryption keys, and then  
# copy the public keys to the remote machine in which 
# you wish to create a 'trusted' authentication mechanism. 
# 
# Sean O'Donnell <sean@seanodonnell.com> 
#
# $Id: ssh-keygen.sh,v 1.3 2011/09/14 09:50:38 seanodonnell Exp $
# 

# use SSHv1 (rsa1) identity.pub file? 
# for legacy systems, set this to: true
# default: false
SSHV1=false
# use SSHv2 (rsa/dsa) id_rsa.pub/id_dsa.pub files?
# default: true
SSHV2=true

#
# these (3) variables can be overwritten by the various flags. (i.e. -s|-p|-d)
#
# ssh server login (default: nobody@localhost)
SSHSERV="nobody@localhost"
# ssh server port
SSHPORT=22 
# ssh server user-directory (.ssh)
# default: .ssh (which is ~/.ssh, remotely speaking)
SSHDIR_REMOTE=.ssh 

#
# these (2) variables are not yet supported by option flags.
#
# local .ssh directory (usually ~/.ssh)
SSHDIR=~/.ssh 
# local tmp directory to use to merge local/remote keys during process.
TMPDIR=~

echo -e "\n$0 - An SSH Key Generator and Distribution Script";

# 
# function: generate_keys 
# descript: Generate RSA/DSA Encryption keys using ssh-keygen 
# 
function generate_keys 
{ 
	cd $SSHDIR;

	if [ $SSHV1 == "true" ]; then
	# create rsa key for SSHv1 support
		echo -e "Generating RSA Keys for SSHv1 support (rsa1)\n";
		ssh-keygen -t rsa1;
	else
		echo -e "SSHv1 support disabled. No SSHv1 keys were generated.\n";
	fi

	if [ $SSHV2 == "true" ]; then
		# create rsa key for SSHv2 support
		echo -e "Generating RSA Keys for SSHv2 support\n";
		ssh-keygen -t rsa;

		# create dsa key for SSHv2 support
		echo -e "Generating DSA Keys for SSHv2 support\n";
		ssh-keygen -t dsa;
	else
		echo -e "SSHv2 support disabled. No SSHv2 keys were generated.\n";
	fi
} 

# get_existing_keys from the remote server, before pushing our keys over. 
# We generally don't want to overwrite any existsing keys, just in case.
function get_existing_keys 
{
	echo -e "Connecting to remote host to collect existing file(s).\n";
	scp -P $SSHPORT $SSHSERV:$SSHDIR_REMOTE/authorized_keys* $TMPDIR/ 
} 

# merge our keys with the existing keys from the remote server.
function merge_keys 
{ 
	# copy the public identity and encryption keys to 
	# a new 'temporary' file on the local system 
	echo -e "Merging local keys with remote authorized_keys file(s)\n";
	cat $SSHDIR/identity.pub >> $TMPDIR/authorized_keys 
	cat $SSHDIR/id_dsa.pub $SSHDIR/id_rsa.pub >> $TMPDIR/authorized_keys2 
	# set the proper permissions (644) for the authorized_keys file(s) 
	chmod 644 $TMPDIR/authorized_keys* 
} 

function transfer_keys 
{ 
	get_existing_keys 
	merge_keys 

	# copy the authorized_keys file(s) to the remote system 
	echo -e "Transfering the SSH keys to the remote server ($SSHSERV:$SSHDIR_REMOTE/)\n";
	scp -P $SSHPORT $TMPDIR/authorized_keys* $SSHSERV:$SSHDIR_REMOTE/ 

	# clean-up local directory 
	rm $TMPDIR/authorized_keys* 
} 

# 
# function: verify_deps 
# descript: a simple function used to verify the dependencies 
# 
function verify_deps 
{ 
	if [ ! -x $SSHDIR ]; then 
		# mkdir -m 0700 $SSHDIR 
		echo -e "\nIt appears that you have not manually connected to a remote SSH Server from this machine yet."
		echo -e "We will now connect you to $SSHSERV, which should instantiate the initial $SSHDIR"; 
		echo -e "Please verify that the '$SSHDIR' directory does exist on the remote machine. (ls -la | grep ssh;)" 
		echo -e "If the directory does not exist on the remote machine, then you will need to create the directory, and try again. (mkdir -m 0700 ~/.ssh; logout;)\n"
		ssh $SSHSERV -p $SSHPORT 
		exit 0; 
	fi 
} 

function print_help 
{ 
	echo -e "\nUsage: \t$0 [options] command\n";
	echo -e "Options:\n";
	echo -e "\t-l [login]\tssh server login (default: $SSHSERV)";
	echo -e "\t-p [port]\tssh port (default: $SSHPORT)";
	echo -e "\t-d [dir]\tremote .ssh directory (default: $SSHDIR_REMOTE)\n";
	echo -e "Commands:\n";
	echo -e "\t-g\tGenerate and Transfer your keys";
	echo -e "\t-t\tTransfer your keys (if existing)";
	echo -e "\t-h\tHelp Screen (this)\n";
	echo -e "Copyright (c) 2011 Sean O'Donnell <sean@seanodonnell.com>\n";
	exit;
} 

while getopts "p::l::d::ght" opt; do
	case $opt in
		# options
		p)
			# ssh port (if other than 22)
			SSHPORT=$OPTARG;
			echo -e "\nSSH Port set to: $SSHPORT";
			;;
		l)
			# ssh server login (i.e. user@remote.com)
			SSHSERV=$OPTARG;
			echo -e "\nSSH Login set to: $SSHSERV";
			;;
		d)
			# custom remote .ssh directory
			SSHDIR_REMOTE=$OPTARG;
			echo -e "\nSSH Remote Directory set to: $SSHDIR_REMOTE";
			;;
			
		# commands
		h)
			# custom remote .ssh directory
			print_help;
			;;
		g)
			# generate and transfer (default)
			verify_deps;
			generate_keys;  
			transfer_keys;
			;;
		t)
			# transfer
			verify_deps;
			transfer_keys;
			;;
		*)
			echo "\nInvalid option: $opt"
			print_help;
			exit;
			;;
	esac
done