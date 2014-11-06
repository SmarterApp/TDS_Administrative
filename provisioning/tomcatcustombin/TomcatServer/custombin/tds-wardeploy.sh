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


#catalina=`cat ~/.bashrc | grep CATALINA_HOME`
#$catalina
CATALINA_HOME=/usr/local/tomcat
CATALINA_PATH=$CATALINA_HOME
#if [ -f $CATALINA_PATH/webapps/ROOT.war ]
    #    then
     #           echo "old war file is existed"
     #   else
      #         mv $CATALINA_PATH/webapps/ROOT $CATALINA_PATH/webapps/ROOT-copy
#fi

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
echo $ARTIFACT | grep tds-load-test-node

if [ $? == 0 ]
        then
                echo "this is tds-load-test-node-VERSION.war"
                cp -r $CATALINA_PATH/webapps/tds-load-test-node.war $Backuppath/

                rm -r $CATALINA_PATH/webapps/tds-load-test-node.war
                rm -r $CATALINA_PATH/webapps/tds-load-test-node

                mv $Latestpath/$ARTIFACT-$Version.war $Latestpath/tds-load-test-node.war
                cp -r $Latestpath/tds-load-test-node.war $CATALINA_PATH/webapps/

fi
echo $ARTIFACT | grep ContentUploader

if [ $? == 0 ]
        then
                echo "this is ContentUploader-VERSION.war"
                cp -r $CATALINA_PATH/webapps/ContentUploader.war $Backuppath/

                rm -r $CATALINA_PATH/webapps/ContentUploader.war
                rm -r $CATALINA_PATH/webapps/ContentUploader

                mv $Latestpath/$ARTIFACT-$Version.war $Latestpath/ContentUploader.war
                cp -r $Latestpath/ContentUploader.war $CATALINA_PATH/webapps/

fi
