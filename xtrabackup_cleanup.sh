#!/usr/bin/env bash
#
# xtrabackup_cleanup.sh
# 
# Purge old incremental backup archives to preserve disk/storage space.
#
# This script was developed specifically for purging xtrabackup (mysql/innodb) 
# database snapshots, but can be used for any type of incremental backup archive 
# management. The goal was to purge snapshots that are over a month old. 
#
# For simplicity, we'll use the tmpwatch command, since it's a trusted
# and safer method than using timestamp-voodoo in bash, or the find
# command.
#
ARCHIVE=/backup/mysql/snapshots

#
# HOURS Hints...
#
# 10 days = 240 hours
# 15 days = 360 hours
# 20 days = 480 hours
# 30 days = 720 hours
#
HOURS=720

#
# FLAGS Hints
#
# -m delete according to modification time (mtime) instead of the access time (atime).
# -a delete all file types
# -f force remove (rm -f)
#
# For more available tmpwatch flags, use: 'man tmpwatch'.
#
FLAGS="-maf";

if [ -e $ARCHIVE ]; then
	/usr/sbin/tmpwatch $FLAGS $HOURS $ARCHIVE
else
	echo -e "\nThe ARCHIVE Path ($ARCHIVE) does not exist. Please check your path/settings.\n";
fi
