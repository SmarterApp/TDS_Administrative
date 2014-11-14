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

Instance_id=$(wget http://169.254.169.254/latest/meta-data/instance-id -o /dev/null -O /dev/stdout)

# Retrieve the hostname that CNAMEs to the hostname
Desired_FQDN=$(aws ec2 describe-instances --filter "Name=dns-name,Values=$EC2_Name" | grep -P '^TAGS\tName' |awk '{print $3}')

Env=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$Instance_id" | grep -P "TAGS\tEnv"|awk '{print $5}')

if [ -z $Env ] ; then
	Env="dev"
fi

case $Env in
	dev)
		mailserver=mail-dev.opentestsystem.org:10025
		;;
	ci)
		mailserver=mail.ci.opentestsystem.org:10025
		;;
	uat)
		mailserver=mail.uat.opentestsystem.org:10025
		;;
	dl)
		mailserver=mail.opentestsystem.org:10025
		;;
	*)
		mailserver=mail-dev.opentestsystem.org:10025
		;;
esac

/usr/bin/perl -pi.bak -e "s/^hostname=.*/hostname=$Desired_FQDN/;" -e "s/mailhub=.*/mailhub=$mailserver/;" /etc/ssmtp/ssmtp.conf
