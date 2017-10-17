#!/usr/bin/env bash
# 
# xtrabackup_snapshot_deploy.sh
#
# This script is intended to perform database 'rollback' procedures 
# from a specified xtrabackup snapshot archive. This script 
# is ideal for installing a production snapshot on a staging database,
# local workstation, or replication-slave instance.
#
# This script assumes that you have sudo access, and was developed
# to support CentOS (and other RHEL-based distros).
#
# Author: Sean O'Donnell <sean@seanodonnell.com>
#
DATESTAMP=`date +"%Y-%m-%d"`;
DBPATH=`grep '^datadir' /etc/my.cnf | sed s/datadir=//`;

echo -e "\nPlease define the path the Archive you wish to roll-back/deploy:\ni.e. /data/snapshots/snapshot_2014-01-01\n\n";

read ARCHIVEPATH;

if [ -e $ARCHIVEPATH ]; then

	# shut-down database process
	sudo service mysqld stop
	
	# move existing database files to a back-up directory, in case you 
	# want to roll-back from your attempted snapshot rollback/deployment
	sudo mv $DBPATH $DBPATH.bak-$DATESTAMP
	
	# recreate the database directory
	sudo mkdir $DBPATH
	
	# recover the data from innobackupex
	sudo innobackupex --copy-back $ARCHIVEPATH
	
	# change ownership of files to database user (mysql)
	sudo chown -R mysql:mysql $DBPATH
	
	# restart the staging database
	sudo service mysqld start
else
	echo -e "The path that you specified, does not exist. Please try again.\n";
fi
