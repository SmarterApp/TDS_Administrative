#!/bin/bash

##removes the context.xml under Tomcatserver/conf and replace with new context.xml that includes DB resources

##tomcat home path
CATALINA_HOME=/usr/local/tomcat

rm -f $CATALINA_HOME/conf/context.xml
cd TomcatServer
cp -r conf $CATALINA_HOME/
cp -r bin $CATALINA_HOME/
cp -r resources $CATALINA_HOME/
