#!/bin/bash

/usr/bin/java \
    -Dlogfilename="/usr/local/tomcat/resources/tds/maintenance" \
    -Djdbc.driver="com.mysql.jdbc.Driver" \
    -Djdbc.url="jdbc:mysql://tds-db.dev.opentestsystem.org:3306/session" \
    -Djdbc.userName="dbsbac" \
    -Djdbc.password="osTyMhRM1C" \
    -DDBDialect="MYSQL" \
    -jar /usr/local/tomcat/resources/tds/tdsMaintenance.jar
