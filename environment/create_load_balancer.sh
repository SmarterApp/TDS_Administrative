#!/bin/bash
set -u
set -v
set -x

show_help() {
cat << EOF
Usage: ${0##*/} -n oam-lb.xxxxx.xxxx.org -e xxxx -r oam-lb -s xxx.xxx.org -p XXX [-c certificate_name]
    -n   The fully qualified domain name of the load balancer
    -e   What environment to put it in (ci, uat, dev, etc.)
    -s   What server should be behind the load balancer
    -p   What port to listen on (80, 8080, 443, or 8443)
    -c   Name of the certificate to use with HTTPS ports
EOF
}                


. /usr/local/etc/ec2.env

OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.

while getopts "p:c:n:r:e:s:h" opt; do
    case "$opt" in
        h)  show_help
            exit 0
            ;;
        n)  host_name=$OPTARG
            ;;
        e)  host_env=$OPTARG
            ;;
        s)  host_server=$OPTARG
            ;;
        r)  host_role=$OPTARG
            ;;
        c)  host_cert=$OPTARG
            ;;
        p)  host_port=$OPTARG
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

lb_name=${host_name//\./-}
port=${host_port:-}
cert=${host_cert:-}
if [ ! -z ${cert} ] ; then
	if (( ("$port"  == 80 ) || ($port == "8080") )); then
		echo "You specified a cert with an HTTP port. Not allowed."
		exit 1
	fi

	cert_id=$(aws iam list-server-certificates| grep /$cert| awk '{print $2}')
	if [ $? -ne 0 ] ; then
		echo "Cert \"$cert\" not found. Here are certs:"
		aws iam list-server-certificates|awk '{print $6}'
		exit 1
	fi
	listener="Protocol=HTTPS,LoadBalancerPort=$port,InstanceProtocol=HTTPS,InstancePort=$port,SSLCertificateId=$cert_id"
else
	if (( ("$port"  == 443 ) || ($port == "8443") )); then
		echo "You did not specify a cert with an HTTPS port. Not allowed."
		exit 1
	fi
	listener="Protocol=HTTP,LoadBalancerPort=$port,InstanceProtocol=HTTP,InstancePort=$port"

fi

instance_output=$(aws elb describe-load-balancers --load-balancer-name $lb_name > /dev/null 2>&1)
if [ $? -eq 0 ] ; then
	instance_output=$(aws elb create-load-balancer-listeners --load-balancer-name $lb_name --listeners $listener)
else
	instance_output=$(aws elb create-load-balancer --load-balancer-name $lb_name --availability-zones us-east-1b  --listeners $listener --tags Key=Name,Value=$host_name Key=Env,Value=$host_env Key=Role,Value=$host_role Key=Type,Value=load_balancer)
	lb_id=$(echo $instance_output | tr "\n" " " |awk '{print $13}')
	
	lb_id=$(aws elb describe-load-balancers --load-balancer-name $lb_name|grep ^LOADBALANCERDESCRIPTIONS|awk '{print $2}')
	echo "updating route53 name: $host_name CNAME $lb_id"
	/home/ubuntu/create_instance_update_route53_cname.sh $lb_id $host_name
fi

if [ $? -ne 0 ] ; then
	echo "Bailing due to errors: $instance_output"
	exit 1
fi

server=${host_server:-}
if [ ! -z $server ] ; then
	instance_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$server"|grep ^INSTANCES|awk '{print $8}')
	instance_output=$(aws elb register-instances-with-load-balancer --load-balancer-name $lb_name --instances $instance_id)
fi

