#!/bin/bash
#user must has root priviliges to run this script
#creates a new group
#creates new user and add it to group

username=tomcat
GroupnameID=tomcat
password=

if [ $(id -u) -eq 0 ]; then
		#read -p "Enter username : " username
		grep -w "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
			echo "user $username already exists!"
		exit 1
		fi
	else
		echo "Only root user can add another user to the system. Run with sudo??"
	exit 2
fi

#read -p "Enter groupname : " GroupnameID
grep -w "^$GroupnameID" /etc/group
if [ $? -eq 0 ]; then
		echo "can not add $GroupnameID, group already exists!"
	else
		echo "creating new group : $GroupnameID"
		groupadd $GroupnameID
fi
echo "***************************************************"
echo "**** Adding new ${username} under $GroupnameID ****"
echo "***************************************************"
#read -s -p "Enter password : " password
HOME_BASE='/home/'
useradd -g $GroupnameID -m -d ${HOME_BASE}${username} ${username}
echo $password | passwd $username --stdin
[ $? -eq 0 ] && echo "*****${username} has been added to system****" || echo "Failed to add a user!"

#adding user to sudoers file

echo ''${username}'  ALL=(ALL)  NOPASSWD: ALL' >> /etc/sudoers                                                    
