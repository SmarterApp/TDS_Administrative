#!/bin/bash
#This script places SSL generate shell script in server and produce new certificates
#pass input parameter "SERVER" for this script

function usage {
    echo " This script generates an X509 certificate for Tomcat servers."
    echo " USAGE: $0 param1=value1 param2=value2 ..."
    echo " where available params are as follows: "
    echo " -s|--server    = $SERVER (input parameter through jenkins job)"
    echo " -h|--help      = show usage information for this script"
    echo
} 

catalina=`cat ~/.bashrc | grep CATALINA_HOME`
$catalina
ssh_path=$CATALINA_HOME/.ssh
sslcerts=/tmp/sslcerts-generate
rm -rf $sslcerts
mkdir $sslcerts

for i in "$@"
do
    case $i in
    -s=*|--server=*)
    SERVER="${i#*=}"
    ;;
  esac
done

echo "server name is: $SERVER"

#delete old certificates
rm -f $ssh_path/$SERVER**
rm -rf .truststore.ts
rm -rf .keystore
#find $ssh_path  -name ".*" -type f -delete
cp create_tomcat_certs.sh $sslcerts/

#generate new certificates

cd $sslcerts
chmod +x create_tomcat_certs.sh
./create_tomcat_certs.sh -f=$SERVER -r=true &> /dev/null

if ls $ssh_path/$SERVER** >> /dev/null
	then
		echo "new SSL certificates generated successfully"
	else
		echo "script failed to generate SSL certificates"
		exit -1
fi
