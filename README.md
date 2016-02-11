random bash scripts
===
Who doesn't love random bash scripts?

dualgate_multinet.sh
=
The sole-purpose of this script, was to create a dual-gateway firewall/router, without having to buy a Cisco product.

Usage: ./dualgate_multinet.sh -i eth1 -a 192.168.0.254

ssh-keygen.sh
=
This script is intended to be used as a simple interactive-wrapper to the 'ssh-keygen' utility, along with the 'scp' procedures that would generally follow, to distribute your SSH key, after you have properly generated it.

xtrabackup_snapshot.sh
=
This bash script is intended to be used as a simple interactive-wrapper to the xtrabackup utility, to take a snapshot of an entire InnoDB MySQL Database, without interuption.

xtrabackup_cleanup.sh
=
This bash script is intended to be executed daily via crontab to purge mysql/innodb database snapshot archives, that were generated via xtrabackup_snapshot.sh, if the archives are over 30 days old. This script can be used for any type of incremental backup archive management, though. 
