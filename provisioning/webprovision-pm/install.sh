#!/bin/bash
#configuring progman properties for Program Management


##tomcat home path
CATALINA_HOME=/usr/local/tomcat

cd TomcatServer
cp -r conf $CATALINA_HOME/
cp bin/setenv.sh $CATALINA_HOME/bin/
cp -r resources $CATALINA_HOME/
