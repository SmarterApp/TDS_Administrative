#!/bin/bash

#########################################################################################################
#This script will execute a deployment task with given params -p ProjectName -v Version -d DeployType   #
#provisioning step must make this file available on server for deployment. Ideal place:tomcatserver/bin #
#At present, this script assumes tomcat as service, can modify to use tomcat/bin/start and stop scripts #
#########################################################################################################

if [ $# -ne 8 ]; then
    echo "Your command line contains $# arguments which is improper to assign as a input parameters"
        echo "example: shell.sh -p PROJECTNAME -a ARTIFACT -v Version -d DROPDB "
        exit 1
fi

while getopts ":p:a:v:d:" opt
   do
case ${opt} in
        p ) PROJECTNAME="${2}";;
        a ) ARTIFACT="${4}";;
        v ) Version="${6}";;
        d ) DROPDB="${8}";;
esac
done
echo "application name is : $PROJECTNAME"
echo "artifact name is : $ARTIFACT"
echo "version is : $Version"
echo "drop the database : $DROPDB" 

if [ "$DROPDB" == "yes" ]
        then
        mongo auth-db.uat.opentestsystem.org/testauth --eval "db.dropDatabase()"
fi

#check for tomcat service
TomcatService=`sudo chkconfig --list | grep -w -Eo tomcat`

echo $TomcatService

if [ "$TomcatService" == "tomcat" ]
        then
echo "tomcat service is available"
else
echo "tomcat service is not avilable.configure tomcat service and chkconfig"
fi


catalina=`cat ~/.bashrc | grep CATALINA_HOME`
$catalina
CATALINA_PATH=$CATALINA_HOME
if [ -f $CATALINA_PATH/webapps/ROOT.war ]
        then
                echo "old war file is existed"
        else
                mv $CATALINA_PATH/webapps/ROOT $CATALINA_PATH/webapps/ROOT-copy
fi

echo "checking tomcat status"
        sleep 10
        response=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8080)
        echo $response

        if [ "$response" != "200" ]; then
                        echo "tomcat is not running"
                else
                        echo "tomcat failed to stop"
                exit -1
        fi


#take backup, clean old deployed war and related files
#Script level variables
Backuppath=/tmp/deployments/$PROJECTNAME/oldversion
Latestpath=/tmp/deployments/$PROJECTNAME/latestversion
 mkdir -p $Backuppath


echo $ARTIFACT | grep rest

if [ $? == 0 ]
	then 
		echo "this is test-auth.rest-VERSION.war"
		cp -r $CATALINA_PATH/webapps/rest.war $Backuppath/
		
		rm -r $CATALINA_PATH/webapps/rest.war
		rm -r $CATALINA_PATH/webapps/rest
		
		mv $Latestpath/$ARTIFACT-$Version.war $Latestpath/rest.war
		cp -r $Latestpath/rest.war $CATALINA_PATH/webapps/
		
fi

echo $ARTIFACT | grep webapp

if [ $? == 0 ]
	then 
		echo "this is test-auth.webapp-VERSION.war"
		cp -r $CATALINA_PATH/webapps/ROOT.war $Backuppath/
		
		rm -r $CATALINA_PATH/webapps/ROOT.war
		rm -r $CATALINA_PATH/webapps/ROOT
		
		mv $Latestpath/$ARTIFACT-$Version.war $Latestpath/ROOT.war
		cp -r $Latestpath/ROOT.war $CATALINA_PATH/webapps/
		
fi
