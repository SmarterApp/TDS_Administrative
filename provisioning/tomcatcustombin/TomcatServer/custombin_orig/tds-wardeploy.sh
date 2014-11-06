#!/bin/bash
#########################################################################################################
#This script will execute a deployment task with given params -p ProjectName -v Version -d DeployType   #
#provisioning step must make this file available on server for deployment. Ideal place:tomcatserver/bin #
#At present, this script assumes tomcat as service, can modify to use tomcat/bin/start and stop scripts #
#########################################################################################################


if [ $# -ne 8 ]; then
    echo "Your command line contains $# arguments which is improper to assign as a input parameters"
        echo "example: shell.sh -p PROJECTNAME -a ARTIFACT -v Version -d DROPDB"
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

#stop tomcat

sudo /bin/su tomcat $CATALINA_PATH/bin/shutdown.sh

echo "waiting for tomcat response"
        sleep 10
        response=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8080)
        echo $response

        if [ "$response" != "200" ]; then
                        echo "tomcat stopped successfully"
                else
                        echo "tomcat failed to stop"
                exit -1
        fi


#take backup, clean old deployed war and related files
#Script level variables
Backuppath=/tmp/deployments/$PROJECTNAME/oldversion
Latestpath=/tmp/deployments/$PROJECTNAME/latestversion
 mkdir -p $Backuppath

echo $ARTIFACT | grep item-scoring-service

if [ $? == 0 ]
	then 
		echo "this is item-scoring-service-VERSION.war"
		cp -r $CATALINA_PATH/webapps/itemscoring.war $Backuppath/
		
		rm -r $CATALINA_PATH/webapps/itemscoring.war
		rm -r $CATALINA_PATH/webapps/itemscoring
		
		mv $Latestpath/$ARTIFACT-$Version.war $Latestpath/itemscoring.war
		cp -r $Latestpath/itemscoring.war $CATALINA_PATH/webapps/
		
fi

echo $ARTIFACT | grep student

if [ $? == 0 ]
	then 
		echo "this is student-VERSION.war"
		cp -r $CATALINA_PATH/webapps/student.war $Backuppath/
		
		rm -r $CATALINA_PATH/webapps/student.war
		rm -r $CATALINA_PATH/webapps/student
		
		mv $Latestpath/$ARTIFACT-$Version.war $Latestpath/student.war
		cp -r $Latestpath/student.war $CATALINA_PATH/webapps/
		
fi


echo $ARTIFACT | grep testadmin

if [ $? == 0 ]
        then
                echo "this is testadmin-VERSION.war"
                cp -r $CATALINA_PATH/webapps/proctor.war $Backuppath/

                rm -r $CATALINA_PATH/webapps/proctor.war
                rm -r $CATALINA_PATH/webapps/proctor

                mv $Latestpath/$ARTIFACT-$Version.war $Latestpath/proctor.war
                cp -r $Latestpath/proctor.war $CATALINA_PATH/webapps/

fi


#start tomcat
sudo /bin/su tomcat $CATALINA_PATH/bin/startup.sh

echo "tomcat is starting"
        sleep 10
        response=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8080)
        echo $response

        if [ "$response" == "200" ]; then
                        echo "tomcat started successfully"
                else
                        echo "tomcat failed to start"
                exit -1
        fi
