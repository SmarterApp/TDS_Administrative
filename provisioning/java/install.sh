#/bin/sh

#check the user sudo permissions
SERVERGROUP=tomcat
SERVERUSER=tomcat

#if [ "$UID" -eq "$ROOT_UID" ]
 #       then
  #              echo "*****signed in user has sudoers permission*****"
   #     else
    #            echo "*****You must be root(sudo) user to continue! Sign in as root user*****"
     #   exit -1
#fi

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

usergroup=`groups $SERVERUSER`

echo user and group names are  $usergroup

IFS=" : "
                set $usergroup
                unset IFS

if [[ $1 == "$SERVERUSER" && $2 == "$SERVERGROUP" ]];
        then
                echo "user $SERVERUSER belongs to group $SERVERGROUP"
        else
                echo "user $SERVERUSER is not belongs to group $SERVERGROUP"
fi

#check for java configuration
#configure jdk if it doen't available

if type -p java;
        then
                echo found java executable in PATH
                _java=java
        elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
                echo found java executable in JAVA_HOME     
                _java="$JAVA_HOME/bin/java"
        else
                echo "no java found, configuring jdk with 1.7.** version"
                #downloading and configuring jdk
		
		sudo apt-get -y install openjdk-7-jdk
                #setting up java environments
                echo JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/ >> ~/.bash_profile
                echo export JAVA_HOME >> ~/.bash_profile
                echo export PATH=$PATH:$JAVA_HOME/bin >> ~/.bash_profile

                #activates the new path settings
                source ~/.bash_profile
                echo java home is: $JAVA_HOME

                #verifing jdk after configuration
        if type -p java;
                then
			echo "found java executable in PATH"
                        _java=java
                elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];
                then
                        echo "jdk installed successfully"     
                        _java="$JAVA_HOME/bin/java"
                else
                        echo "no java found, failed to configure jdk with 1.7.** version"
                exit -1
        fi
fi

#veryfing existed java version
if [[ "$_java" ]];
        then
                JAVA_VER=$(java -version 2>&1 | sed 's/java version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q')
                echo "java version is $JAVA_VER"
        if [ "$JAVA_VER" -gt 17 ]
                then
                        echo "ok, java is newer than 1.7"
        elif [ "$JAVA_VER" -lt 17 ]
                then
                        echo "java version is not comptible need to update to version 1.7 or above"
                sudo apt-get -y install openjdk-7-jdk
                #setting up java environments
                echo JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/ >> ~/.bash_profile
                echo export JAVA_HOME >> ~/.bash_profile
                echo export PATH=$PATH:$JAVA_HOME/bin >> ~/.bash_profile

                #activates the new path settings
                source ~/.bash_profile
                echo java home is: $JAVA_HOME

                #verifing jdk after configuration
        if type -p java;
                then
			echo "found java executable in PATH"
                        _java=java
                elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];
                then
                        echo "jdk installed successfully"     
                        _java="$JAVA_HOME/bin/java"
                else
                        echo "no java found, failed to configure jdk with 1.7.** version"
                exit -1
        fi
        else
            echo "java version is 1.7 and it is compatible"
        fi
fi
