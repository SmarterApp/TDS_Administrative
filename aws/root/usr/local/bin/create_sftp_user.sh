#!/bin/bash
if [ $# -eq 0 ] ; then
	echo "Please pass in the name of the user to create"
	exit
fi
if [ $# -gt 1 ] ; then
	echo "Please pass in one name to create"
	exit
fi

adduser $*

usermod -a -G sftpusers -d /incoming -s /usr/sbin/nologin $*

chown root:sftpusers /home/$*
chmod 750 /home/$*
mkdir /home/$*/incoming
chown $*:sftpusers /home/$*/incoming
chmod 700 /home/$*/incoming

/bin/rm -f /home/$*/.bash_logout /home/$*/.bashrc /home/$*/.profile
