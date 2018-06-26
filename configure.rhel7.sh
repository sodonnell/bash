#!/usr/bin/env bash
#
# configure.rhel.sh
#
# Basic RHEL7.5 configuration script.
#
# Configure Amazon Ec2 (RHEL7.5) Instance for 
# basic LAMP-Stack development and testing.
#
# This script is a work-in-progress and intended 
# for my personal usage (only) for now.
#
# Sean O'Donnell <sean@seanodonnell.com>
#
yum -y install vim tmux screen mcrypt htop irssi httpd wireshark nmap curl wget

# install 3rd-party repos.
yum -y install https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm

# refresh yum repo file cache
yum update yum

# install mysql8
yum -y install mysql-community-server 

# install python 3.4 and pip
yum -y install python34 python34-pip 

# install PHP7 packages
yum -y install php73 php73-php-mbstring php73-php-xml php73-php-fpm php73-php-mysqlnd php73-php-pdo

# configure php-fpm as a fast-cgi proxy in apache
echo -e "<FilesMatch \\.php$>\n\tSetHandler \"proxy:fcgi://127.0.0.1:9000\"\n</FilesMatch>\n\n" >> /etc/httpd/conf/httpd.conf;

# install AWS CLI tools
pip3 install --upgrade pip
pip3 install awscli

# set daemons to autorun during init.d/systemd
chkconfig httpd on
chkconfig php73-php-fpm on
chkconfig mysqld on

# start services
service php73-php-fpm start
service httpd start
service mysqld start

echo -e "<?php\nphpinfo();\n" > /var/www/html/info.php;
