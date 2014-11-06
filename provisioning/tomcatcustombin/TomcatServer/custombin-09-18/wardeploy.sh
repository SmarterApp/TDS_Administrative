#!/bin/bash
#########################################################################################################
#This script will execute a deployment task with given params -p ProjectName -v Version -d DeployType   #
#provisioning step must make this file available on server for deployment. Ideal place:tomcatserver/bin #
#At present, this script essumes tomcat as service, can modify to use tomcat/bin/start and stop scripts #
#########################################################################################################

if [ $# -ne 8 ]; then
    echo "Your command line contains $# arguments which is improper to assign as a input parameters"
        echo "example: shell.sh -p PROJECTNAME -a ARTIFACT -v Version -d DEPLOYTYPE "
        exit 1
fi

while getopts ":p:a:v:d:" opt
   do
case ${opt} in
        p ) PROJECTNAME="${2}";;
        a ) ARTIFACT="${4}";;
        v ) Version="${6}";;
        d ) DEPLOYTYPE="${8}";;
esac
done
echo "application name is : $PROJECTNAME"
echo "artifact name is : $ARTIFACT"
echo "version is : $Version"
echo "deployment type : $DEPLOYTYPE" 

#Deploy type may be cold or hot

#check for tomcat service
TomcatService=`sudo chkconfig --list | grep -w -Eo tomcat`

echo $TomcatService

if [ "$TomcatService" == "tomcat" ]
        then
echo "tomcat service is available"
else
echo "tomcat service is not avilable.configure tomcat service and chkconfig"
fi

case ${DEPLOYTYPE} in
cold)

#stop tomcat
catalina=`cat ~/.bashrc | grep CATALINA_HOME`
$catalina
sudo /bin/su tomcat $CATALINA_HOME/bin/shutdown.sh

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
Tomcatpath=/opt/servers/TomcatServer

rm -rf $Backuppath
mkdir -p $Backuppath


cp -r $Tomcatpath/webapps/$ARTIFACT $Backuppath/
cp -r $Tomcatpath/webapps/$ARTIFACT.war $Backuppath/
#cp -r $Tomcatpath/logs $Backuppath/
#cp -r $Tomcatpath/conf/configuration.properties $Backuppath/conf
#cp -r $Tomcatpath/conf/logback.xml $Backuppath/conf

rm -r $Tomcatpath/webapps/$ARTIFACT
rm -r $Tomcatpath/webapps/$ARTIFACT.war
#rm -r $Tomcatpath/logs
#rm -r $Tomcatpath/conf/configuration.properties
#rm -r $Tomcatpath/conf/logback.xml

#renaming artifact name with version to artifact name
mv $Latestpath/$ARTIFACT-$Version.war $Latestpath/$ARTIFACT.war

cp -r $Latestpath/$ARTIFACT.war $Tomcatpath/webapps/
#cp -r $Latestpath/conf/configuration.properties $Tomcatpath/conf/
#cp -r Latestpath/conf/logback.xml $Tomcatpath/conf/


#stopping tomcat
sudo /bin/su tomcat $CATALINA_HOME/bin/startup.sh

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
;;

hot)
cp -r /latestversion/$ARTIFACT** $Tomcatpath/webapps/
;;
esac
exit 0