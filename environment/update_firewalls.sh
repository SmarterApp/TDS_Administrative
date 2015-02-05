#!/bin/bash

set -u
set -x
set -v

show_help() {
cat << EOF
Usage: ${0##*/} -n XXX.XX.opentestystem.org -e XXX -r  XXX
    -n   The fully qualified domain name
EOF
}                

function add_security_group_ingress {
	my_group=$1
	procotol=$2
	remote_server=$3

	case "$2" in
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

if [ -z "$remote_server" ] ; then
		aws ec2 authorize-security-group-ingress --group-id $my_group --protocol tcp --port $port --cidr 0.0.0.0/0
else
	remote_sg=$(aws ec2 describe-security-groups --group-names $remote_server 2> /dev/null)
	if [ $? -ne 0 ] ; then
		echo "security group for server $remote_server doesn't exist. The $2 port ($port) will need to be opened up"
	else
		remote_sg_name=$(aws ec2 describe-security-groups --group-names $remote_server| grep ^SECURITYGROUPS | awk '{print $3}')
		aws ec2 authorize-security-group-ingress --group-id $my_group --protocol tcp --port $port --source-group  $remote_sg_name
	fi
fi

}

DOMAIN="opentestsystem.org"
OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
while getopts "n:h" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
        n)  host_name=$OPTARG
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

{
IFS=$'\n'
firewall=( `tail -n +7 firewalls.txt |grep -v ^,` )
}
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

# Clear out first 2 columns
unset open_ports[0]
unset open_ports[1]
i=2
for t in "${open_ports[@]}" ; do 
	if [ "$t" != "" ] ; then
		if [[ $t == *\/* ]] ; then
			IFS=/ sub=$t
			for j in $sub ; do
				#echo "opening port $j to ${Servers[$i]}.$host_env.$DOMAIN"
				add_security_group_ingress $sg_name $j ${Servers[$i]}.$host_env.$DOMAIN
			done	
		else
			#echo "opening port $t to ${Servers[$i]}.$host_env.$DOMAIN"
			add_security_group_ingress $sg_name $t ${Servers[$i]}.$host_env.$DOMAIN
		fi
	fi
	((i++))
done
