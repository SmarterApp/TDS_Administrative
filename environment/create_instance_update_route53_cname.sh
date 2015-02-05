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


# For gith now - don't update route 53 if part of cloudformation
#CloudFormationName=$(/usr/local/bin/get_cloudformation_name.sh)
#if [ -n "$CloudFormationName" ]; then
#        exit
#fi


# The domain and host name to update
# and the desired TTL of the record
Domain=opentestsystem.org
#Desired_FQDN=$(grep hostname= /etc/ssmtp/ssmtp.conf|awk -F= '{print $2}')
NewTTL=600

# The Amazon Route 53 zone ID for the domain
ZoneID=Z31O66MG3W9DA5

###############################################################
# You should not need to change anything beyond this point
###############################################################

# Find an authoritative AWS R53 nameserver so we get a clean TTL
AuthServer=$(dig NS $Domain | grep -v ';' | grep -m 1 awsdns | grep $Domain | cut -f 5)
if [ "$AuthServer" = "" ]; then
  echo The domain $Domain has no authoritative Amazon Route 53 name servers
  exit 1
fi

# Retrieve the current ec2 hostname
# Enter the URL used to check extern IP
if [ -z "$1" ] ; then
	CheckHostnameURL='http://169.254.169.254/latest/meta-data/public-hostname'
	EC2_Name=$(wget "$CheckHostnameURL" -o /dev/null -O /dev/stdout)
else
	EC2_Name=$1
fi
# Retrieve the hostname that CNAMEs to the hostname
if [ -z "$2" ] ; then
	Desired_FQDN=$(aws ec2 describe-instances --filter "Name=dns-name,Values=$EC2_Name" | grep -P '^TAGS\tName' |awk '{print $3}')
else
	Desired_FQDN=$2
fi

# Get the record and extract its parts
Record=$(dig @$AuthServer CNAME $Desired_FQDN | grep -v ";" | grep "$Desired_FQDN")
OldType=$( echo $Record | cut -d ' ' -f 4 )
OldTTL=$( echo $Record | cut -d ' ' -f 2 )
OldName=$( echo $Record | cut -d ' ' -f 5 )
OldName=${OldName%?}

# Make sure it is an A record (could be CNAME)
if [ "$Record" != "" -a "$OldType" != "CNAME" ]; then
  echo $Desired_FQDN has a $OldType record, expected 'CNAME'
  exit 1
fi

# Changeset preamble
Changeset=""
Changeset=$Changeset"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
Changeset=$Changeset"<ChangeResourceRecordSetsRequest xmlns=\"https://route53.amazonaws.com/doc/2010-10-01/\">"
Changeset=$Changeset"<ChangeBatch><Comment>Update $Desired_FQDN</Comment><Changes>"

if [ "$OldName" != "" ]; then
  # Add a DELETE request to the changeset
  Changeset=$Changeset"<Change>"
  Changeset=$Changeset"<Action>DELETE</Action>"
  Changeset=$Changeset"<ResourceRecordSet>"
  Changeset=$Changeset"<Name>$Desired_FQDN.</Name>"
  Changeset=$Changeset"<Type>CNAME</Type>"
  Changeset=$Changeset"<TTL>$OldTTL</TTL>"
  Changeset=$Changeset"<ResourceRecords>"
  Changeset=$Changeset"<ResourceRecord>"
  Changeset=$Changeset"<Value>$OldName</Value>"
  Changeset=$Changeset"</ResourceRecord>"
  Changeset=$Changeset"</ResourceRecords>"
  Changeset=$Changeset"</ResourceRecordSet>"
  Changeset=$Changeset"</Change>"
fi

if [ "$OldName" != "$EC2_Name" ]; then
  # Add CREATE request to the changeset
  Changeset=$Changeset"<Change>"
  Changeset=$Changeset"<Action>CREATE</Action>"
  Changeset=$Changeset"<ResourceRecordSet>"
  Changeset=$Changeset"<Name>$Desired_FQDN.</Name>"
  Changeset=$Changeset"<Type>CNAME</Type>"
  Changeset=$Changeset"<TTL>$NewTTL</TTL>"
  Changeset=$Changeset"<ResourceRecords>"
  Changeset=$Changeset"<ResourceRecord>"
  Changeset=$Changeset"<Value>$EC2_Name</Value>"
  Changeset=$Changeset"</ResourceRecord>"
  Changeset=$Changeset"</ResourceRecords>"
  Changeset=$Changeset"</ResourceRecordSet>"
  Changeset=$Changeset"</Change>"

  # Close the changeset
  Changeset=$Changeset"</Changes>"
  Changeset=$Changeset"</ChangeBatch>"
  Changeset=$Changeset"</ChangeResourceRecordSetsRequest>"

  # Get the date at the Amazon servers
  CurrentDate=$(wget -q -S https://route53.amazonaws.com/date -O /dev/null 2>&1 | grep Date | sed 's/.*Date: //')

  # Calculate the SHA1 hash and required headers
  Signature=$(echo -n $CurrentDate | openssl dgst -binary -sha1 -hmac $AWS_SECRET_KEY | base64)
  DateHeader="Date: "$CurrentDate
  AuthHeader="X-Amzn-Authorization: AWS3-HTTPS AWSAccessKeyId=$AWS_ACCESS_KEY,Algorithm=HmacSHA1,Signature=$Signature"

  # Submit request
  Result=$(wget -nv --header="$DateHeader" --header="$AuthHeader" --header="Content-Type: text/xml; charset=UTF-8" --post-data="$Changeset" -O /dev/stdout -o /dev/stdout https://route53.amazonaws.com/2010-10-01/hostedzone/$ZoneID/rrset)
  if [ "$?" -ne "0" ]; then
    echo "Failed to update $Desired_FQDN: "$Result
  fi
fi
