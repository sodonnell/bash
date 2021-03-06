#!/usr/bin/env bash
#
# configure.rhel.sh
#
# Basic RHEL7.5 configuration script.
#
# This script is a work-in-progress and intended 
# for my personal usage (only) for now.
#
# Install Python 3.4, AWS CLI, PHP 7.2, MySQL 8.0, Apache 2.4 and Laravel, 
# as well as other basic linux-based utilities, on a freshly installed 
# RHEL7.5 Amazon EC2 Instance. 
#
# @todo
#
# Add conditioning cases to detect failures. 
# Add more user-friendly procedural output.
#
# Sean O'Donnell <sean@seanodonnell.com>
#

#
# install 3rd-party repos.
#
yum -y install https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
# rpmfusion? rpmforge? others?

# refresh yum repo file cache
yum update yum

#
# install basic packages that you normally use
#
yum -y install vim tmux screen mcrypt htop irssi wireshark nmap curl wget rsync scp mc yum-utils

#
# Install MySQL 5.7. Disable 8.0 repo, enable 5.7 repo. Eh.
#
yum-config-manager --disable mysql80-community
yum-config-manager --enable mysql57-community

#
# Install Apache, MySQL and PHP related packages
#

# install apache 2.4 and mysql 5.7 (current)
yum -y install httpd mysql-community-server 

# install PHP7.2 packages
yum -y install php72 php72-php-mbstring php72-php-xml php72-php-fpm php72-php-mysqlnd php72-php-pdo php72-php-pecl-zip

# create a default php cli executable (symlink)
ln -s /usr/bin/php72 /usr/bin/php

#
# download and install composer
#
# modified from composer docs: 
# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
#
EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)";
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');";
ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")";

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid composer installer signature'
else    
    php composer-setup.php --install-dir=/usr/bin --filename=composer
fi

rm composer-setup.php

composer global require "laravel/installer"

# configure php-fpm as a fast-cgi proxy in apache
echo -e "<FilesMatch \\.php$>\n\tSetHandler \"proxy:fcgi://127.0.0.1:9000\"\n</FilesMatch>\n\n" >> /etc/httpd/conf/httpd.conf;

# set daemons to autorun during init.d/systemd
chkconfig php72-php-fpm on
chkconfig httpd on
chkconfig mysqld on

# start services
service php72-php-fpm start
service httpd start
service mysqld start

# create a basic phpinfo file to confirm apache/php/php-fpm are running; remove once confirmed (for security purposes)
echo -e "<?php\nphpinfo();\n" > /var/www/html/info.php;

#
# Python/AWS Automation Tools
#

# install python 3.4 and pip
yum -y install python34 python34-pip ansible

# install AWS CLI tools
pip3 install --upgrade pip
pip3 install awscli

# install terraform... @todo

# install a Laravel boilerplate;
# These steps are a pain to remember, 
# so here we go. Set it, and forget it! Eh.
mkdir -p /data/.config;
mv ~/.config/composer /data/.config/;
echo -e "\nPATH=\$PATH:/data/.config/composer/vendor/bin" >> /etc/bashrc;
bash
mkdir -p /var/www/php-bin;
cd /var/www/php-bin;
artisan new test;
chown apache:apache /var/www/html;
sudo -u apache ln -s /var/www/php-bin/test/public /var/www/html/test;
# @todo add +FollowSymlinks to httpd.conf
# @todo disable selinux
# @todo configure laravel storage + bootstrap chmod perms; ugh
