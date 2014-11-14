#!/bin/bash


export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
. /usr/local/etc/ec2.env


delete=0
pairs=$(aws route53 list-resource-record-sets --hosted-zone-id Z31O66MG3W9DA5 --max-items 1000 | /usr/bin/perl -pi -e "s/CNAME\t*\n/CNAME /"|grep "CNAME RESOURCERECORDS"|awk '{print $2,$3,$6}'|grep ec2-)
printf '{\n\t\"Changes\": [\n' > /tmp/$$
while read -r line; do
	read alias ttl hostname <<< $line
	alias=${alias::-1}
	echo ".. alias=$alias hostname=$hostname ..."
	aws ec2 describe-instances --filters Name=dns-name,Values=$hostname|grep -q ^INSTANCES 
	if [ $? -eq 1 ] ; then
		echo "$alias/$hostname needs to be removed"
		#aws route53 list-resource-record-sets --hosted-zone-id Z31O66MG3W9DA5 --start-record-name $alias --start-record-type CNAME --max-items 1
		if [ $delete -eq 1 ] ; then
			printf ',\n' >> /tmp/$$
		fi
		printf '\t{\n\t\t\"Action\": \"DELETE\",\n\t\t\"ResourceRecordSet\": {\n\t\t\t\"Name\": \"%s\",\n\t\t\t\"Type\": \"CNAME\",\n\t\t\t\"TTL\": %s,\n\t\t\t\"ResourceRecords\": [\n\t\t\t{\n\t\t\t\t\"Value\": \"%s\"\n\t\t\t}\n\t\t]\n\t\t}\n\t}' $alias $ttl $hostname >> /tmp/$$
		delete=1
	fi
done <<< "$pairs"
printf '\n\t]\n }\n' >> /tmp/$$
if [ $delete -eq 1 ] ; then
	aws route53 change-resource-record-sets --hosted-zone-id Z31O66MG3W9DA5  --change-batch file:///tmp/$$
fi
rm -f /tmp/$$
