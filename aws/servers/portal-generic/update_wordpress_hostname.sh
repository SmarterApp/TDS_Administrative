#!/bin/sh

# This script will perform a DynDNS-like function for Amazon's Route 53
#
# Author: Johan Lindh <johan@linkdata.se>
# http://www.linkdata.se/
#
# Script requirements:
#
#  wget
#  grep
#  sed
#  dig
#  cut
#  openssl
#  base64
#
# Most if not all of these come standard on *nix distros.
#

. /usr/local/etc/ec2.env

sleep 30

# Retrieve the current ec2 hostname
EC2_Name=$(wget http://169.254.169.254/latest/meta-data/public-hostname -o /dev/null -O /dev/stdout)

# Retrieve the hostname that CNAMEs to the hostname
Desired_FQDN=$(aws ec2 describe-instances --filter "Name=dns-name,Values=$EC2_Name" | grep -P '^TAGS\tName' |awk '{print $3}')

if [ ! -f /etc/wordpress/config-$Desired_FQDN.php ] ; then
   mv /etc/wordpress/config-portal-dev.opentestsystem.org.php /etc/wordpress/config-$Desired_FQDN.php
   /usr/bin/perl -pi.bak -e "s/portal-dev.opentestsystem.org/$Desired_FQDN/" /etc/wordpress/config-$Desired_FQDN.php /etc/wordpress/wp-config.php
fi
