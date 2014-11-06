#!/bin/bash

#################################################################################################################################
# This deployment script will deploy artifacts to servers and provision configuration files & scripts							#
# Usage:
# A) Provisioning 
#	1) install all components needed for application deployment
#		PROVISIONING=yes 
#		PROVISION=what needs to be provision (tomcat,custombin or/and java)
#		PROJECTNAME=name of the project
#		SERVER=DNS name of the server
# B) Deploy artifacts 
#	1) provide all inputs for this script via jenkins
#		set these env variables via jenkins                   
#		ARTIFACTORY_USER=artifactory user name                          
#		ARTIFACTORY_PASSWORD=artfactory password                          
#		PROJECTNAME=name of the project
#		ARTIFACT=artifact name                           
#		VERSION=artifact version number                      
#		ARTIFACTTYPE=war/jar
#		APPDEPLOY=true
#	2) By default, when no version# is specified for an artifact, script will download the latest and greatest version
#
#################################################################################################################################

# script variables
Project_BaseUrl=ssh://hg@bitbucket.org/sbacoss
Provision_TempDir=/tmp/provisioning/$PROJECTNAME
Deploy_TempDir=/tmp/deployments/$PROJECTNAME
SERVERUSER=tomcat
SERVERGROUP=tomcat
if [ "$PROVISIONING" == "yes" ]
        then
			echo "script provisioning $PROVISION"
			## comment: No passwords. User name and password must be env variables via Jenkins
			#hg clone https://username:password@bitbucket.org/sbacoss/provisioningdev
			hg clone $Project_BaseUrl/provisioningdev
			cd $WORKSPACE/prod
			zip -r provisioningdev.zip provisioningdev
			ssh $SERVERUSER@$SERVER "\
			rm -rf $Provision_TempDir/provisioningdev
			mkdir -p $Provision_TempDir/;\
			"
			scp -r $WORKSPACE/prod/provisioningdev.zip $SERVERUSER@$SERVER:$Provision_TempDir/
			ssh $SERVERUSER@$SERVER "\
			cd $Provision_TempDir/;
			unzip provisioningdev.zip;\
			"
#passing database credentials as jenkins parameters 
			ssh $SERVERUSER@$SERVER 'rm '$Provision_TempDir'/param.env'
			ssh $SERVERUSER@$SERVER "echo 'DB_server=$DB_SERVERNAME' >> $Provision_TempDir/param.env"
			ssh $SERVERUSER@$SERVER "echo 'DB_port=$DB_PORT' >> $Provision_TempDir/param.env"
			ssh $SERVERUSER@$SERVER "echo 'DB_schema=$DB_SCHEMA' >> $Provision_TempDir/param.env"
			ssh $SERVERUSER@$SERVER "echo 'DB_username=$DB_USERNAME' >> $Provision_TempDir/param.env"
			ssh $SERVERUSER@$SERVER "echo 'DB_password=$DB_PASSWORD' >> $Provision_TempDir/param.env"

#array function to configure given provisioning option with loop

			IFS=',' read -a array <<< "$PROVISION"

			for option in "${array[@]}"
				do
					ssh $SERVERUSER@$SERVER "\
					cd $Provision_TempDir/provisioningdev/$option/;\
					sudo chmod +x install.sh;\
					./install.sh -w=$WARDEPLOY -s=$SERVER;\
					"
				done
fi

#source ~/.bashrc

if [ "$APPPROVISION" == "provision" ]
	then
	echo app provision is: $APPPROVISION
	ssh $SERVERUSER@$SERVER "\
					rm -rf $Deploy_TempDir/;\
				mkdir -p $Deploy_TempDir/;\
				

			echo 'dmnaservername=$MNA_SERVER_NAME' >> $Deploy_TempDir/param.env;\
			echo 'dspringprofileactive=$SPRING_PROFILE_ACTIVE' >> $Deploy_TempDir/param.env;\
			echo 'KeyAlias=$KEYALIAS' >> $Deploy_TempDir/param.env;\
			echo 'mongo_hostname=$MONGOHOSTNAME' >> $Deploy_TempDir/param.env;\
			echo 'mongo_port=$MONGOPORT' >> $Deploy_TempDir/param.env;\
			echo 'mongo_dbname=$MONGODBNAME' >> $Deploy_TempDir/param.env;\
			echo 'rest_context_root=$RESTCONTEXTROOT' >> $Deploy_TempDir/param.env;\
			echo 'mna_description=$MNADESCRIPTION' >> $Deploy_TempDir/param.env;\
			echo 'registration_url=$REGISTRATIONURL' >> $Deploy_TempDir/param.env;\
			echo 'mna_url=$MNARESTURL' >> $Deploy_TempDir/param.env;\
			echo 'mna_delete_component_url=$MNADELETECOMPONENTURL' >> $Deploy_TempDir/param.env;\
			echo 'progman_metric_email=$PROGMANMETRICEMAIL' >> $Deploy_TempDir/param.env;\
			
			echo 'mysql_url=$MYSQLURL' >> $Deploy_TempDir/param.env;\
			echo 'db_username=$DB_USERNAME' >> $Deploy_TempDir/param.env;\
			echo 'db_password=$DB_PASSWORD' >> $Deploy_TempDir/param.env;\
			echo 'progman_baseuri=$PROGMAN_BASE_URI' >> $Deploy_TempDir/param.env;\
			echo 'progman_locator=$PROGMAN_LOCATOR' >> $Deploy_TempDir/param.env;\
			echo 'java_rmi_server_hostname=$JAVA_RMI_SERVER_HOSTNAME' >> $Deploy_TempDir/param.env;\
			chmod 755 $Deploy_TempDir/param.env;\
			#source $Deploy_TempDir/param.env;\
			"
	
	catalina=`ssh $SERVERUSER@$SERVER 'grep CATALINA_HOME ~/.bashrc'`; echo $catalina
	$catalina
	echo catalina value is $CATALINA_HOME
	
	#sourcing param.env file in remote server
	source  <(ssh $SERVERUSER@$SERVER cat $Deploy_TempDir/param.env)
	ssh $SERVERUSER@$SERVER "\
	sed -i 's|-DmnaServerName=[^ ]*|-DmnaServerName='$dmnaservername'|' $CATALINA_HOME/bin/setenv.sh;\
	sed -i 's|-Dspring.profiles.active=[^ ]*|-Dspring.profiles.active='$dspringprofileactive'|' /usr/local/tomcat/bin/setenv.sh;\
	sed -i 's|keyAlias=[^ ]*|keyAlias=\"'$KeyAlias'\"|' $CATALINA_HOME/conf/server.xml;\
	sed -i 's|pm.mongo.hostname=[^ ]*|pm.mongo.hostname='$mongo_hostname'|' $CATALINA_HOME/resources/progman/mongo.properties;\
	sed -i 's|pm.mongo.port=[^ ]*|pm.mongo.port='$mongo_port'|' $CATALINA_HOME/resources/progman/mongo.properties;\
	sed -i 's|pm.mongo.dbname=[^ ]*|pm.mongo.dbname='$mongo_dbname'|' $CATALINA_HOME/resources/progman/mongo.properties;\
	sed -i 's|pm.rest.context.root=[^ ]*|pm.rest.context.root=\/'$rest_context_root'\/|' $CATALINA_HOME/resources/progman/rest-endpoints.properties;\
	sed -i 's|progman.mna.description=[^ ]*|progman.mna.description='$mna_description'|' $CATALINA_HOME/resources/progman/mna.properties;\
	sed -i 's|mna.registrationUrl=[^ ]*|mna.registrationUrl='$registration_url'|' $CATALINA_HOME/resources/progman/mna.properties;\
	sed -i 's|mna.mnaUrl=[^ ]*|mna.mnaUrl='$mna_url'|' $CATALINA_HOME/resources/progman/mna.properties;\
	sed -i 's|mna.mnaDeleteComponentUrl=[^ ]*|mna.mnaDeleteComponentUrl='$mna_delete_component_url'|' $CATALINA_HOME/resources/progman/mna.properties;\
	sed -i 's|progman.mna.availability.metric.email=[^ ]*|progman.mna.availability.metric.email='$progman_metric_email'|' $CATALINA_HOME/resources/progman/mna.properties;\

	sed -i 's|url=[^ ]*|url=\"'$mysql_url'\"|' $CATALINA_HOME/conf/context.xml;\
	sed -i 's|username=[^ ]*|username=\"'$db_username'\"|' $CATALINA_HOME/conf/context.xml;\
	sed -i 's|password=[^ ]*|password=\"'$db_password'\"|' $CATALINA_HOME/conf/context.xml;\
	
	sed -i 's|-Dprogman.baseUri=[^ ]*|-Dprogman.baseUri='$progman_baseuri'|' /usr/local/tomcat/bin/setenv.sh;\
	sed -i 's|-Dprogman.locator=[^ ]*|-Dprogman.locator='$progman_locator'|' /usr/local/tomcat/bin/setenv.sh;\
	sed -i 's|-Djava.rmi.server.hostname=[^ ]*|-Djava.rmi.server.hostname='$java_rmi_server_hostname'|' /usr/local/tomcat/bin/setenv.sh;\
	"
	
fi



#script variable
#defining function to download artifact from artifactory

if [ "$APPDEPLOY" == "true" ]
	then

	ssh $SERVERUSER@$SERVER "\
	sudo /bin/su tomcat /usr/local/tomcat/bin/shutdown.sh;\
	echo "tomcat stopped"
	"
		IFS=',' read -a array <<< "$ARTIFACT"
		for option in "${array[@]}"
			do

				ARTIFACTNAME=$option.$ARTIFACTTYPE
				REPO=libs-releases-local
				SERVER_NAME=airdev.artifactoryonline.com/airdev
				ARTIFACTORY_URL=http://$SERVER_NAME
				## comment: specify what username and password: ex ARTIFACTORY_USER, ARTIFACTORY_PASSWORD
				CURL="curl --basic --user $ARTIFACTORY_USER:$ARTIFACTORY_PASSWORD --write-out %{http_code} --silent --insecure --output /dev/null"
				#Search for artfactory location and pass the path to SEARCHPATH variable
				SEARCHPATH=$(curl 'https://'$ARTIFACTORY_USER':'$ARTIFACTORY_PASSWORD'@'$SERVER_NAME'/api/search/artifact?name='$option'.'$ARTIFACTTYPE'&repos='$REPO'' | grep $option | tail -1 | sed 's/\ \ \ \ \"uri\" : \"/\ /g' | sed 's/\/api\/storage\//\//g' | sed 's/\"/\ /g')
				echo "search path is $SEARCHPATH"

				echo "running deployment script"
                echo given artifcat name is: $ARTIFACTNAME
                #artifacts are saved in folder called artifacts in workspace
                #removing artifact folder which creates automatically when script runs
                rm -rf artifacts
                
				# verify arifactory repo with user credentials  
                RESP=`$CURL https://airdev.artifactoryonline.com/airdev/webapp/logout.html?0`
                echo $RESP
				if [ "$RESP" != "200" ];
					then
						echo -e "Invalid login ('$RESP')\n" >&2
						exit -1
					else
						echo "$USER_NAME  login credentials verified"
				fi

                echo "***************************************************************************"
                echo "***************************************************************************"
                echo "***************     LOGIN SUCCESSFUL       ********************************"
                echo "***************************************************************************"
                echo "***************************************************************************"


				string1=http://airdev.artifactoryonline.com/airdev/
				path=${SEARCHPATH## $string1}
				SearchURL=$ARTIFACTORY_URL/simple/$path
				CheckArtifact=`$CURL $SearchURL` >> /dev/null
                
				if [ "$CheckArtifact" == "200" ]
					then
        		        wget '-Partifacts' -q -N --http-user=$ARTIFACTORY_USER --http-password=$ARTIFACTORY_PASSWORD $SEARCHPATH
					else
                        echo "ERROR: Please check artifact name and version. Enter artifactname-** to download latest version"
					exit -1
				fi
        
				ARTIFACTID=`echo $SEARCHPATH | rev | cut -d/ -f3 | rev`
				echo artifactid is $ARTIFACTID
        
				if [ -f artifacts/$ARTIFACTID** ]
					then
                        echo "***** artifact has downloaded successfully*****"
					else
                        echo "Failed to download artifact, Verify all parameters"
					exit -1
				fi

                #checking out the project to extract app dependent properties
				#hg clone $Project_BaseUrl/$PROJECTNAME
				#creating folder structure in destination server
				ssh $SERVERUSER@$SERVER "\
				rm -rf $Deploy_TempDir/latestversion/;\
				mkdir -p $Deploy_TempDir/latestversion/;\
				"
				cd $WORKSPACE/prod/artifacts
				Version=`echo $ARTIFACTID** | sed -e 's/'$ARTIFACTID'-//g' | sed -e 's/.war//g'`
				echo version number is: $Version
				cd $WORKSPACE/prod/
				zip -j $ARTIFACTID.appfiles.zip artifacts/$ARTIFACTID-$Version.war
				scp $ARTIFACTID.appfiles.zip $SERVERUSER@$SERVER:$Deploy_TempDir/latestversion/
				
				ssh $SERVERUSER@$SERVER "\
				#catalina=`cat ~/.bashrc | pgrep CATALINA_HOME`;\
				#cat ~/.bashrc | grep CATALINA_HOME > setcatalina.env; chmod +x setcatalina.env; source setcatalina.env
				#$catalina
				cd $Deploy_TempDir/latestversion/;\
				unzip $ARTIFACTID.appfiles.zip;\
				#triggering deploy.sh to deploy war and related files
				cd /usr/local/tomcat/custombin
				./wardeploy.sh -p $PROJECTNAME -a $ARTIFACTID -v $Version -d $DROPDB
				"
			done

	ssh $SERVERUSER@$SERVER "\
        sudo /bin/su tomcat /usr/local/tomcat/bin/startup.sh;\
		chown -R tomcat.tomcat /usr/local/tomcat/webapps
		echo "tomcat started"
        "
fi

