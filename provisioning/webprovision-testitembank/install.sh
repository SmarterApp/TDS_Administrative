#!/bin/bash

##tomcat home path
CATALINA_HOME=/usr/local/tomcat

cp -r TomcatServer/resources $CATALINA_HOME/
cd TomcatServer
cp bin/setenv.sh $CATALINA_HOME/bin/
