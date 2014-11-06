#!/bin/bash

##removes the context.xml under Tomcatserver/conf and replace with new context.xml that includes DB resources
CATALINA_HOME=/usr/local/tomcat

cd TomcatServer
cp -r bin $CATALINA_HOME/
cp -r conf $CATALINA_HOME/
