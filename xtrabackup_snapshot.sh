#!/usr/bin/env bash
#
# This script is intended to perform real-time Database snapshots (manually) 
# using the Percona XtraBackup application. XtraBackup includes a wrapper 
# script (innobackupex), which is used to perform backups of both InnoDB 
# and MyISAM database engine types.
#
# This script is intended to be run (physically) on the production server. It
# will perform a complete snapshot of the entire database, then prepare the 
# backup for restoration by rebuilding the indexes, and then off-loading 
# a copy to a remote back-up/mirror server, via SCP. This script should be
# run on a weekly basis via crontab.
#
# Sean O'Donnell <sean@seanodonnell.com>
#
# $Id: xtrabackup_snapshot.sh,v 1.1 2013/10/19 02:47:42 seanodonnell Exp $
#

# define the path to the remote backup mirror server in a way that SCP will interpret.
# i.e. user@remotehost:/path/to/archives/
#MIRROR=

# create a simple timestamp if you wish to retain multiple/unique 
# snapshot copies. This eats storage, though. Be mindful.
#DATESTAMP=`date +"%Y-%m-%d_%H-%M-%S"`

# define the username and password (below) if you wish to run this via 
# crontab. Otherwise, comment-out the following (2) lines.
#DB_USER=
#DB_PASSWD=

# define the local backup destination path
#DIR_DEST=

XTRABACKUP=`which innobackupex`;
if [ -z $XTRABACKUP ]; then
	echo "Could not find the innobackupex command in your PATH.";
	exit;
fi

#
# manual interactive procedures
#
# If any of the following variables are commented-out, the procedure(s) 
# below will prompt the user to input the values during execution.
#
if [ -z $DB_USER ]; then
	echo -e "Please enter your database Username:\n";
	read DB_USER;
fi

if [ -z $DB_PASSWD ]; then
	echo -e "Please enter your database Password:\n";
	read -s DB_PASSWD;
fi

if [ -z $DIR_DEST ]; then
	echo -e "Please define the database file path. (i.e. /var/lib/mysql/)\n";
	read DIR_DEST;
fi

if [ -z $MIRROR ]; then
	echo -e "Please define the remote mirror path. (i.e. username@server:/path/to/archive/)\n";
	read MIRROR;
fi

if [ ! -z $DATESTAMP ]; then
	DIR_DEST=$DIR_DEST$DATESTAMP/
fi 

# back-up all InnoDB and MyISAM data
echo -e "Performing InnoDB and MyISAM snapshot for the entire Database.\n";
innobackupex --user=$DB_USER --password=$DB_PASSWD $DIR_DEST --no-timestamp

if [ -e $DIR_DEST ]; then
        # Apply page log and rebuild indexes to prepare for recover/cloning
        echo -e "Applying page log and rebuilding indexes...\n";
        innobackupex --apply-log --rebuild-indexes $DIR_DEST

        echo -e "Copying the snapshot to our remote backup mirror...\n";
        scp -r $DIR_DEST $MIRROR
else   
        echo -e "The back-up process appears to have failed. Please check for error messages (above).\n";
fi

echo -e "\nDone!\n"

