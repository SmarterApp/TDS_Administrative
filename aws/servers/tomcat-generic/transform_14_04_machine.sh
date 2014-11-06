#!/bin/bash
. ../all_14_04_servers.sh

$SSH "sudo rm -rf /usr/local/tomcat"
$SSH "sudo apt-get install -y tomcat7"
$SSH "sudo ln -s /var/lib/tomcat7 /usr/local/tomcat"

cat tomcat-juli.jar                     | $SSH "sudo dd of=/usr/local/tomcat/bin/tomcat-juli.jar"
cat tomcat-juli-adapters.jar            | $SSH "sudo dd of=/usr/local/tomcat/bin/tomcat-juli-adapters.jar"
cat log4j.xml                           | $SSH "sudo dd of=/usr/local/tomcat/conf/log4j.xml"
cat mysql-connector-java-5.1.22-bin.jar | $SSH "sudo dd of=/usr/local/tomcat/lib/mysql-connector-java-5.1.22-bin.jar"
cat server.xml                          | $SSH "sudo dd of=/usr/local/tomcat/conf/server.xml"
cat tomcat-users.xml                    | $SSH "sudo dd of=/usr/local/tomcat/conf/tomcat-users.xml"
cat tomcat.ssh.tar                      | $SSH "cd /usr/local/tomcat; sudo tar -xvf -"

$SSH "sudo chmod 700 /usr/local/tomcat/.ssh"
$SSH "sudo chmod 755 /usr/local/tomcat/bin/tomcat-juli.jar /usr/local/tomcat/bin/tomcat-juli-adapters.jar /usr/local/tomcat/lib/log4j.xml /usr/local/tomcat/lib/mysql-connector-java-5.1.22-bin.jar /usr/local/tomcat/conf/server.xml"
$SSH "sudo chown -R tomcat7.tomcat7 /var/lib/tomcat7"
$SSH "echo \"tomcat7  ALL = (ALL) NOPASSWD: ALL\" | sudo tee -a /etc/sudoers"

echo "downloading the openoffice files"
$SSH "wget https://archive.apache.org/dist/openoffice/4.0.0/binaries/en-US/Apache_OpenOffice_4.0.0_Linux_x86-64_install-deb_en-US.tar.gz"
$SSH "tar xf Apache_OpenOffice_4.0.0_Linux_x86-64_install-deb_en-US.tar.gz"
$SSH "cd en-US/DEBS; sudo dpkg -i *.deb"
$SSH "rm -rf en-US"
$SSH "wget http://archive.apache.org/dist/openoffice/4.0.0/binaries/SDK/Apache_OpenOffice-SDK_4.0.0_Linux_x86-64_install-deb_en-US.tar.gz"
$SSH "tar xf Apache_OpenOffice-SDK_4.0.0_Linux_x86-64_install-deb_en-US.tar.gz"
$SSH "cd en-US/DEBS; sudo dpkg -i *.deb"
$SSH "rm -rf en-US"
cat crontab.root | $SSH "sudo dd of=/var/spool/cron/crontabs/root"
$SSH "sudo chmod 600 /var/spool/cron/crontabs/root"
$SSH "sudo /etc/init.d/tomcat7 restart"
