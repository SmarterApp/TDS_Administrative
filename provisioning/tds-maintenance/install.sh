#!/bin/bash
cp tdsMaintenance.jar /usr/local/tomcat/resources/tds/;chown tomcat.tomcat /usr/local/tomcat/resources/tds/tdsMaintenance.jar;cp -f tdsmaintenance.sh /etc/cron.daily/;echo '00 2 * * * root /etc/cron.daily/tdsMaintenance.sh >> /usr/local/tomcat/logs/tdsMaintenance.log' >> /etc/crontab