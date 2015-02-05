#!/bin/bash
set -x

show_help() {
cat << EOF
Usage: ${0##*/} -n XXX.XX.opentestystem.org -e XXX -r  XXX
    -n   The fully qualified domain name
    -e   What environment to put it in (ci, uat, dev, etc.)
    -r   What role does it occupy (ftp, ssh, cs, cs-db, tib, tib-db, etc..)
    -a   Don't run ansible against the new server
    -w   Don't wait for server to complete
    -k   Key pair pem file from AWS used to connect to server
    -d   Domain name for server
EOF
}                

function add_security_group_ingress {
	my_group=`echo $1 | awk '{ print $1 }' `
	protocol=$2
	remote_server=$3

echo "add_security_group_ingress $my_group ... $protocol ... $remote_server"

	case "$protocol" in
	MYSQL)
		port=3306
		;;
	SSH)
		port=22
		;;
	Mongo)
		port=27017
		;;
	SMTP)
		port=25
		;;
	SSMTP)
		port=10025
		;;
	HTTP)
		port=80
		;;
	HTTPS)
		port=443
		;;
	SFTP)
		port=22
		;;
	LDAP)
		port=1389
		;;
	HTTP-ALT)
		port=8080
		;;
	HTTPS-ALT)
		port=8443
		;;
	HTTP1)
		port=8081
		;;
	*)
		echo "Invalid port"
		;;
	esac

if [[ "$remote_server" == ext.* ]] ; then
		aws ec2 authorize-security-group-ingress --group-id $my_group --protocol tcp --port $port --cidr 0.0.0.0/0
else
	remote_sg=$(aws ec2 describe-security-groups --group-names $remote_server 2> /dev/null)
	if [ $? -ne 0 ] ; then
		echo "security group for server $remote_server doesn't exist. Creating"
		remote_sg=$(aws ec2 create-security-group --group-name $remote_server --description $remote_server | awk '{ print $1 }'  )
        	echo "new security group created: $remote_sg"
	fi

	remote_sg_name=$(aws ec2 describe-security-groups --group-names $remote_server| grep ^SECURITYGROUPS | awk '{print $3}'  )
	aws ec2 authorize-security-group-ingress --group-id $my_group --protocol tcp --port $port --source-group  $remote_sg_name
fi

}

. /usr/local/etc/ec2.env

image_id=ami-98aa1cf0
ubuntu_home=`pwd sed 's/\//-/g'`
ansible_home="$ubuntu_home/ansible"
###DOMAIN="opentestsystem.org"
OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
wait_to_finish=true
do_ansible=true

while getopts "wan:e:r:k:d:t:h" opt; do
    case "$opt" in
        h)  show_help
            exit 0
            ;;
        w)  wait_to_finish=false
            ;;
        a)  do_ansible=false
            ;;
        n)  host_name=$OPTARG
            ;;
        e)  host_env=$OPTARG
            ;;
        r)  host_role=$OPTARG
            ;;
	k)  key_pair=$OPTARG
	    ;;
	d)  DOMAIN=$OPTARG
	    ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

### Check key_pair exists
if [ ! -e /root/.ssh/${key_pair}.pem ]; then
	echo "Private SSH key does not exist"
	echo "Key file /root/.ssh/${key_pair}.pem does not exist"
	exit 1
fi

## Check to see if necessary files exist
if [ ! -e /etc/ansible/external_vars.yml ]; then
	echo "/etc/ansible/external_vars.yml does not exist. Exiting"
	exit 1
fi

# Read in the data
while IFS=, read Text FQDN Role Type Mach_Size Disk_Size; do
    if [ "$Role" == "$host_role" ] ; then
    	echo $Text, $FQDN, $Role, $Type, $Mach_Size, $Disk_Size
    	ec2_Text=$Text
	ec2_FQDN=$FQDN
	ec2_Role=$Role
	ec2_Type=$Type
	ec2_Mach_Size=$Mach_Size
	ec2_Disk_Size=$Disk_Size
    fi
done < machine_configs.txt


IFS=$'\n' firewall=( `tail -n +6 firewalls.txt |grep -v ^,,,` )

IFS=',' read -a Servers <<< "${firewall[0]}"

echo Servers "${Servers[0]}"
echo Servers "${Servers[1]}"
echo Servers "${Servers[2]}"
echo Servers "${Servers[3]}"

for t in "${firewall[@]}" ; do 
	IFS=',' read -a array <<< "$t"
    	if [ "$ec2_Role" == "${array[0]}" ] ; then
		#echo $t
		IFS=',' read -a open_ports <<< "$t"
	fi
done

################################################################################
# Generate security group if not available
security_group=$(aws ec2 describe-security-groups --group-names $host_name 2> /dev/null)
if [ $? -ne 0 ] ; then
	echo "Creating security-group: $host_name"
	sg_name=$(aws ec2 create-security-group --group-name $host_name --description $host_name | awk '{ print $1 }' )
	echo "new security group created: $sg_name"
else
	IFS=$'\t' sg_array=($security_group)
	IFS=$'\t' sg_name=${sg_array[2]}
	echo "security-group $host_name already exists: $sg_name"
fi

# we need to add ourselves
aws ec2 authorize-security-group-ingress --group-id $sg_name --protocol tcp --port 22 --source-group  $(wget http://169.254.169.254/latest/meta-data/security-groups -o /dev/null -O /dev/stdout )

# Clear out first 2 columns
unset open_ports[0]
unset open_ports[1]
i=2
for t in "${open_ports[@]}" ; do 
	if [ "$t" != "" ] && [[ -v Servers[$i] ]]; then
		if [[ $t == *\/* ]] ; then
			IFS=/ sub=$t
			for j in $sub ; do
				echo "opening port $j to ${[$i]}-$host_env.$DOMAIN"
				add_security_group_ingress $sg_name $j ${Servers[$i]}-$host_env.$DOMAIN
			done	
		else
			echo "opening port $t to ${Servers[$i]}-$host_env.$DOMAIN"
			add_security_group_ingress $sg_name $t ${Servers[$i]}-${host_env}.$DOMAIN
		fi
	fi
	((i++))
done

# Generated machine
echo "Creating server $host_name. Machine type is $ec2_Mach_Size with disk size $ec2_Disk_Size"
instance_output=$(aws ec2 run-instances --image-id $image_id --count 1 --instance-type $ec2_Mach_Size --key-name $key_pair --security-group-ids $sg_name --placement AvailabilityZone=us-east-1b,GroupName="",Tenancy=default --block-device-mappings "[{\"DeviceName\": \"/dev/sda1\",\"Ebs\":{\"DeleteOnTermination\":true,\"VolumeSize\":$ec2_Disk_Size,\"VolumeType\":\"gp2\"}}]")
if [ $? -ne 0 ] ; then
	echo "Bailing due to errors:"
	exit 1
fi

instance_id=$(echo $instance_output | tr "\n" " " |awk '{print $13}')

# don't Wait til it's up
if [ "$wait_to_finish" == false ] ; then
	exit 0
fi

printf "Waiting until server is up"
result=""
while [ "$result" == "" ]; do
	printf "."
	sleep 30
	result=$(aws ec2 describe-instance-status --instance-id $instance_id --filters Name=system-status.status,Values=ok)
done	
printf "\n"

#echo "New machine instance_id is up: $instance_id"
echo "Tagging instance_id: $instance_id"
output=$(aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$host_name Key=Env,Value=$host_env Key=Role,Value=$ec2_Role Key=Type,Value=$ec2_Type)
if [ $? -ne 0 ] ; then
	echo "ec2 create-tags failed: $output"
fi
# Set route53 hostname
instance_ec2_name=$(aws ec2 describe-instances --instance-id $instance_id | grep ^INSTANCES|awk '{print $15}')

echo "updating route53 name: $host_name CNAME $instance_ec2_name"
unset IFS
$ubuntu_home/create_instance_update_route53_cname.sh $instance_ec2_name $host_name

if [ "$do_ansible" == true ] ; then
	echo "updating ansible database to add new machine"
	$ubuntu_home/ec2.py --refresh-cache > $ansible_home/inventory
	
	cd ansible
	# Let's make sure the group_vars files exists
	mkdir -p group_vars > /dev/null 2>&1
	if [ ! -f group_vars/tag_Env_$host_env ] ; then
		echo "---"					 		> group_vars/tag_Env_$host_env
		echo "ssmtp_server: mail.$host_env.$DOMAIN"			>> group_vars/tag_Env_$host_env
		echo "ssmtp_server_and_port: mail.$host_env.$DOMAIN:10025"	>> group_vars/tag_Env_$host_env
		echo "ssmtp_domainname: $DOMAIN"				>> group_vars/tag_Env_$host_env
	fi
	
	ansible-playbook -vvv --private-key=/root/.ssh/$key_pair.pem -s -i ec2.py  site.yml  --limit $host_name
fi
