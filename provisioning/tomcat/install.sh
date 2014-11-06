#!/bin/bash

#environment variables in capital letters
#Change to required versions if needs to

TOMCAT_VERSION=tomcat-7
VERSIONID=7.0.53
tempdir=/tmp/temp
SERVERUSER=tomcat
SERVERGROUP=tomcat

#check the user sudo permissions
##Comment: for future, we should see if $SERVERUSER has no password set

sudo grep $SERVERUSER /etc/sudoers

if [ $? -eq 0 ]; then

                echo "*****user $SERVERUSER has sudoers permission*****"
        else
                echo "*****user $SERVERUSER must be root(sudo) user to continue, provide sudo privileges to $SERVERUSER*****"
        exit -1
fi

echo "****verifying new group name and user name as tomcat runs with new group and user****"
grep -w "$SERVERGROUP" /etc/group
if [ $? -eq 0 ]; then
                echo "*****group name $SERVERGROUP already exists in system*****"
        else
                echo "*****add group name $SERVERGROUP to system*****"
fi

grep -w "$SERVERUSER" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
                echo "******user name $SERVERUSER already exists in system*****"
        else
                echo "*****user $SERVERUSER not exists, add user "$SERVERUSER" under group "$SERVERGROUP"*****"
        exit 1
fi

#verifying $SERVERUSER user group 
usergroup=`groups $SERVERUSER`

echo $usergroup
IFS=" : "
                set $usergroup
                unset IFS

if [[ $1=="$SERVERUSER" && $2=="$SERVERGROUP" ]];
        then
               echo "user $SERVERUSER belongs to group $SERVERGROUP"
        else
                echo "user $SERVERUSER is not belongs to group $SERVERGROUP"
fi

#creating a temp directory to store dwnloaded files
rm -rf $tempdir
mkdir $tempdir

#configure tomcat, only if TomcatServer doesn't exist
#verify MD5 checksum for integrity of files

if [ -d /usr/local/tomcat/webapps ]
        then
                echo "tomcat is already installed"
        else
		        cd $tempdir
                echo configuring apche-tomcat-$VERSIONID
                wget http://mirror.metrocast.net/apache/tomcat/$TOMCAT_VERSION/v$VERSIONID/bin/apache-tomcat-$VERSIONID.zip
                wget https://www.apache.org/dist/tomcat/$TOMCAT_VERSION/v$VERSIONID/bin/apache-tomcat-$VERSIONID.zip.md5
                verify_checksum=`md5sum -c apache-tomcat-$VERSIONID.zip.md5`
                echo verify_checksum is : $verify_checksum
                response_checksum=`echo "$verify_checksum" | cut -d ':' -f 2`
		echo response_checksum is $response_checksum
        #validating checksum
        if [ $response_checksum == OK ]
                then
                        echo "checksum is valid"
        else
                        echo "invalid checksum. verify the tomcat download link"
        exit -1
        fi

        #configuring tomcat

	#giving ownership of /opt/servers dir to $SERVERUSER
       sudo  unzip apache-tomcat-$VERSIONID.zip -d /usr/local/
       sudo chown -R $SERVERUSER /usr/local/apache-tomcat-$VERSIONID
        sudo chgrp -R $SERVERGROUP /usr/local/apache-tomcat-$VERSIONID
        cp -r /usr/local/apache-tomcat-$VERSIONID/** /usr/local/tomcat
        export CATALINA_HOME=/usr/local/tomcat
        export PATH=$PATH:$CATALINA_HOME
        chmod +x -R /usr/local/tomcat/bin/
	
	#setting up CATALINA_HOME
	sudo grep "CATALINA_HOME=/usr/local/tomcat" /usr/local/$SERVERUSER/.bashrc
	if [ $? -eq 0 ]; then
	echo "CATALINA_HOME is already configured in ~/.bashrc"
	else
	echo export CATALINA_HOME=/usr/local/tomcat >> ~/.bashrc
	echo export PATH=$PATH:$CATALINA_HOME >> ~/.bashrc
        fi
	#activates the new path settings
	source ~/.bashrc
	echo $CATALINA_HOME
	
    ##comment: you dont need to change ownership
	#changing permissions of TomcatServer
	#sudo chown -R $SERVERUSER /opt/servers/TomcatServer
	#sudo chgrp -R $SERVERGROUP /opt/servers/TomcatServer
	#configuring tomcat as service
	cd -
	cd files
	sudo cp --parents etc/init.d/tomcat /
	sudo chmod 755 /etc/init.d/tomcat
    
    # adding tomact to chckconfig list
    #sudo chkconfig --add tomcat  
    #sudo chkconfig --level 234 tomcat on
	if [ -f /etc/init.d/tomcat ]
		then
			echo "tomcat service configuration completed"
		else
			echo "failed to configure tomcat service"
	fi
    
    sudo chown -R $SERVERUSER /etc/init.d/tomcat
	sudo chgrp -R $SERVERGROUP /etc/init.d/tomcat    
# check http response code on localhost:8080 to see tomacat is up and running
        source ~/.bashrc
	sudo service tomcat start
	echo "waiting for tomcat response"
	sleep 10
	response=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8080)
	echo $response

	if [ "$response" == "200" ]; then
			echo "tomcat running successfully"
		else
			echo "tomcat failed to run"
		exit -1
	fi
fi


