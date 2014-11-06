#!/bin/bash

##tomcat home path
CATALINA_HOME=/usr/local/tomcat

cd  TomcatServer
cp -r bin $CATALINA_HOME/
cp testreg-secret.properties $CATALINA_HOME/.ssh/
