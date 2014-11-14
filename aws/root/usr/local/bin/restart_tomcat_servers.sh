#!/bin/bash
# Restart tomcat servers
#
 
function usage {
    echo
    echo " This script restarts Tomcat servers from a list of servers, or one specified on command line"
    echo " USAGE: $0 param1=value1 param2=value2 ... flag1 ..."
    echo " where available params are as follows: "
    echo " -f=|--fqdn=         = Only restart this particular server whose FQDN is set here."
    echo " -l=|--serverlist=   = File containing a list of servers whose tomcat service should be restarted (default = tomcat_servers.txt)."
    echo " -h|--help           = Show usage information for this script"
    echo
}
 
#paths and defaults
SERVER_LIST=tomcat_servers.txt
FQDN=""
RESTART_SCRIPT=restart_tomcat.sh
 
# read command line arguments
# -f=|--fqdn=         = Only restart this particular server whose FQDN is set here.
# -l=|--serverlist=   = File containing a list of servers whose tomcat service should be restarted.
# -h|--help       = show usage information for this script
 
for i in "$@"
do
    case $i in
    -h|--help)
        usage
        exit 0
        ;;
    -f=*|--fqdn=*)
    FQDN="${i#*=}"
    ;;
    -l=*|--serverlist=*)
    SERVER_LIST="${i#*=}"
    ;;
    --default)
            DEFAULT=YES
        ;;
    *)
            # unknown option
        ;;
    esac
done
 
 
if [ -z $FQDN ] ; then
    if [ -f "$SERVER_LIST" ] ; then
	    while read line
	    do
	       # HACK - Don't touch SSO server
		fields=(${line//,/ })
		server="${fields[0]}"
		url="${fields[1]}"
		if [ "$server" = "drcamp-dev-secure.opentestsystem.org" ] ; then
			echo "Bypassing SSO server $server"
		else
			echo " - Connecting to $server and restarting Tomcat"
			scp -oStrictHostKeyChecking=no -i ~/.ssh/air-dev.pem $RESTART_SCRIPT root@$server:/tmp
			ssh -n -oStrictHostKeyChecking=no -i ~/.ssh/air-dev.pem root@$server "/tmp/$RESTART_SCRIPT"
			if [ ! -z "$url" ] ; then
				echo "Now waiting for \"$url\" to be alive"
				result=0
				while [ $result -eq 0 ] ; do
					sleep 5
					result=$(curl --max-time 5 -o /dev/null --silent --head --write-out '%{http_code}' $url)
					echo "result = $result"
				done
			fi
		fi
	    done < $SERVER_LIST
    else
	    echo
	    echo " -ERROR: File containing list of servers ($SERVER_LIST) not found."
	    usage
	    exit 1
    fi
else
    server=$FQDN
       # HACK - Don't touch SSO server
    if [ $server = "drcamp-dev.opentestsystem.org" ] ; then
	    echo "Bypassing SSO server $server"
    else
	    echo " - Connecting to $server and restarting Tomcat"
	    ssh -oStrictHostKeyChecking=no -i ~/.ssh/air-dev.pem root@$server "$RESTART_COMMAND"
    fi
fi
