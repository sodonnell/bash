random bash scripts
===
Who doesn't love random bash scripts?

configure.rhel7.sh
=
Configure Red Hat Enterprise Linux (RHEL) 7.5 to run Python 3.4, AWS CLI utilities, PHP 7.3, MySQL 8.0 and Apache 2.4. 

This script is considered experimental for development/testing environments (only). This script and configuration is not intended for current (most) production environments.

dualgate_multinet.sh
=
The sole-purpose of this script, was to create a dual-gateway firewall/router, without having to buy a Cisco product..

ssh-keygen.sh
=
This script is intended to be used as a simple interactive-wrapper to the 'ssh-keygen' utility, along with the 'scp' procedures that would generally follow, to distribute your SSH key, after you have properly generated it.

xtrabackup_snapshot.sh
=
This bash script is intended to be used as a simple interactive-wrapper to the xtrabackup utility, to take a snapshot of an entire InnoDB MySQL Database, without interuption.

xtrabackup_snapshot_deploy.sh
=
This bash script is intended to be used to deploy snapshots created from xtrabackup_snapshot.sh (or any Percona Xtrabackup snapshot, really).

xtrabackup_cleanup.sh
=
This bash script is intended to be executed daily via crontab to purge mysql/innodb database snapshot archives, that were generated via xtrabackup_snapshot.sh, if the archives are over 30 days old. This script can be used for any type of incremental backup archive management, though. 
