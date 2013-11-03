#!/usr/bin/env bash
#
# Sean's Essential Fedora Linux YUM Package Re/Configurator.
#
# This script allows me to easily install and/or update 
# all of the essential packages I use when running Linux, 
# from one simple command/script. Run it as a daily cronjob, 
# if you dare! ;-)
#
# This script is handy when testing different systems w/ fedora 
# in an environment where no kickstart is available. It happens!
#
# $Id: $
#
PACKAGES="WindowMaker irssi aterm tmux screen \
openssh-server openssl httpd mysql-server mysql-workbench \
php php-soap php-mysql php-pear-XML-RSS cvs \
sysstat iptables iptstate dnsmasq squid \
eclipse eclipse-phpeclipse eclipse-epic eclipse-shelled vim \
thunderbird firefox wget xmms2";

CMD="yum -y install ${PACKAGES}";

if [ ${USER} != "root" ]; then
	echo -e "\nYou must execute this script as 'root' (via su -c, not via sudo).\nPlease enter your password below:\n";
	su - -c "${CMD}"
else
	${CMD}
fi