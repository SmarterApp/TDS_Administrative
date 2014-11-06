#!/bin/bash

##place the custombin directory under tomcat.
#custombin has wardeploy.sh script, which is used to deploy war files under webapps


function usage {
    echo
    echo " USAGE: $0 param1=value1 param2=value2 ..."
    echo " where available params are as follows: "
    echo " -w|--wardeploy      = $WARDEPLOY (input parameter through jenkins job)"
    echo " -h|--help      = show usage information for this script"
    echo
}

source ~/.bashrc
catalina=`cat ~/.bashrc | grep CATALINA_HOME`
$catalina

#while getopts ":w:" opt
   #do
#case ${opt} in
     #   w ) wardeploy="${2}";;
#esac
#done


for i in "$@"
 do
     case $i in
     -w=*|--wardeploy=*)
     wardeploy="${i#*=}"
     ;;
   esac
done   

echo "wardeploy is: $wardeploy"

cd TomcatServer/
cp --parents custombin/"$wardeploy" $CATALINA_HOME/
mv $CATALINA_HOME/custombin/"$wardeploy" $CATALINA_HOME/custombin/wardeploy.sh
chmod +x $CATALINA_HOME/custombin/wardeploy.sh
