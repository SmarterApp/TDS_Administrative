#!/bin/bash
# Create certificate and keystores for Tomcat servers
 
function usage {
    echo
    echo " This script generates an X509 certificate for Tomcat servers."
    echo " USAGE: $0 param1=value1 param2=value2 ..."
    echo " where available params are as follows: "
    echo " -f|--fqdn      = FQDN (REQUIRED)"
    echo " -k|--keypath   = key path       (DEFAULT = ~tomcat/.ssh)"
    echo " -p|--storepass = store password (DEFAULT = changeit)"
    echo " -n|--storename = store name     (DEFAULT = .keystore)"
    echo " -r|--restart   = restart tomcat after completion (DEFAULT = false)"
    echo " -c|--chown     = change ownership to tomcat (DEFAULT = false unless restart is true)"
    echo " -h|--help      = show usage information for this script"
    echo
}
 
KEYPATH=~tomcat/.ssh
#KEYPATH=/tmp
STORENAME=.keystore
STOREPASS=changeit
FQDN=___NOT-SPECIFIED___    # THIS MUST BE SET FOR EACH SERVER
RESTART=false
CHOWN=false
 
# read command line arguments
# -f|--fqdn      = FQDN (REQUIRED)
# -k|--keypath   = key path (DEFAULT = ~tomcat/.ssh)
# -p|--storepass = store password (DEFAULT = changeit)
# -n|--storename = store name (DEFAULT = .keystore)
# -r|--restart   = restart tomcat after completion (DEFAULT = false)
# -c|--chown     = change ownership to tomcat (DEFAULT = false unless restart is true)
 
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
    -k=*|--keypath=*)
    KEYPATH="${i#*=}"
    ;;
    -p=*|--storepass=*)
    STOREPASS="${i#*=}"
    ;;
    -n=*|--storename=*)
    STORENAME="${i#*=}"
    ;;
    -c=*|--chown=*)
    CHOWN="${i#*=}"
    ;;
    -r=*|--restart_tc=*)
    RESTART="${i#*=}"
    CHOWN="true"
    ;;
    --default)
        DEFAULT=YES
        ;;
    *)
            # unknown option
        ;;
    esac
done
 
# expand path
eval kp="$KEYPATH";
 
# Rename any existing keystore
if [ -d "$kp" ]; then
    if [ -f $kp/$STORENAME ]; then
    mv $kp/$STORENAME $kp/$STORENAME.old.$$
    fi
    if [ -f $kp/.truststore.ts ]; then
    mv $kp/.truststore.ts $kp/.truststore.ts.old.$$
    fi
else
    mkdir -p $kp
fi
 
if [ -d $kp ] ; then
    echo "Storing new certs in $kp"
    ls -l $kp
else
    echo " -ERROR: key path $kp could not be created"
    usage
    exit 1
fi
 
# Create the keystore:
keytool -genkey -alias $FQDN -keyalg RSA -keystore $kp/$STORENAME -dname "cn=$FQDN, ou=SBAC, o=American Institutes for Research, l=Washington, st=DC, c=US" -storepass $STOREPASS -keypass $STOREPASS -validity 365 -keysize 2048
 
if [ -f $kp/$STORENAME ] ; then
# Create a certificate from that keystore:
    keytool -export -alias $FQDN -file $kp/$FQDN.cer -keystore $kp/$STORENAME -storepass $STOREPASS -noprompt
 
    if [ -f $kp/$FQDN.cer ] ; then
# Create the truststore file with that certificate:
    keytool -import -trustcacerts -alias $FQDN -file $kp/$FQDN.cer -keystore $kp/.truststore.ts -storepass $STOREPASS -noprompt
    if [ -f $kp/.truststore.ts ] ; then
# Export the certificate and echo out
        if [ -f $kp/$FQDN.crt ]; then
        mv $kp/$FQDN.crt $kp/$FQDN.crt.$$ # backup the old cert
        fi
        keytool -export -alias $FQDN -rfc -keystore $kp/$STORENAME -storepass $STOREPASS -noprompt -file $kp/$FQDN.crt
        if [ -f $kp/$FQDN.crt ] ; then
        echo
        echo "$FQDN X509 Certificate generated:"
        cat $kp/$FQDN.crt
        if [ $CHOWN == "true" ]; then
    # if it's a Tomcat server, we are doing this in a tomcat directory so we need to set permissions accordingly
            echo " * Change cert ownership to tomcat"
            chown -R tomcat.tomcat $kp
            chmod -R go-wr $kp
        fi
         
# service tomcat restart or stop don't work reliably, so must kill.
        if [ $RESTART == "true" ]; then
    # now kill and restart tomcat
            echo " * Killing tomcat"
            pkill -f catalina
            echo " * Restarting tomcat"
            service tomcat start < /dev/null > /dev/null 2>&1 &
        fi
        echo
        echo "--DONE for $FQDN, stored in $kp"
        echo
        else
        echo " -ERROR: could not create CRT file"
        usage
        exit
        fi
    else
        echo " -ERROR: could not create truststore file"
        usage
        exit
    fi
    else
    echo " -ERROR: could not create CER file"
    usage
    exit
    fi
else
    echo " -ERROR: could not create store $STORENAME"
    usage
    exit
fi
 
exit
