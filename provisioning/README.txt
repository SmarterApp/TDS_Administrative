tomcatserver/config.sh script functions

1. Verify user permissions. User must have sudo permissions
2. Tomcat runs with user "deployer" and group "server". Script looks for both user and group.
3. Create temp folder in root directory to save downloaded files.
4. Minimum version requirement of JDK is 1.7. If system JDK is less than 1.7 then script will install version 1.7 and set up environment variables
5. Check for tomcat. If it doesn't exist, configure with latest version and set up CATALINA_HOME
6. Configure tomcat as a service
7. Script runs tomcat and verifies its response


Comments:
