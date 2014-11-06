#!/bin/bash

#removes the context.xml under Tomcatserver/conf and replace with new context.xml that includes DB resources
echo provisioning DB resources
catalina=`cat ~/.bashrc | grep CATALINA_HOME`
$catalina

if [ -f /tmp/provisioning/studentdev/param.env ] ; then
	source /tmp/provisioning/studentdev/param.env
else
	echo "[ERROR]: Jenkins parameters are not available for this build."
exit 1
fi

#deleting old context.xml and copying new context.xml to /conf directory
rm -f $CATALINA_HOME/conf/context.xml
cd TomcatServer
cp -r conf $CATALINA_HOME/

#placing testadmin-settings.xml under tomcat
cp testadmin-settings.xml $CATALINA_HOME/

#passing DB resource parameters
sed -i 's/DB_server/'$DB_server'/' $CATALINA_HOME/conf/context.xml

sed -i 's/DB_port/'$DB_port'/' $CATALINA_HOME/conf/context.xml

sed -i 's/DB_schema/'$DB_schema'/' $CATALINA_HOME/conf/context.xml

sed -i 's/DB_username/'$DB_username'/' $CATALINA_HOME/conf/context.xml

sed -i 's/DB_password/'$DB_password'/' $CATALINA_HOME/conf/context.xml

rm -f /tmp/provisioning/studentdev/param.env