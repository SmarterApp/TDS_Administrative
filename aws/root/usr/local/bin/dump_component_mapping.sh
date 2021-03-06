#!/bin/bash
ERROR_TEMP=/tmp/$$.error
OUTPUT_TEMP=/tmp/$$.output
COMPONENT_DIR=/var/www/etc
COMPONENT_FILENAME=component_mapping.txt
COMPONENT_OUTPUT=$COMPONENT_DIR/$COMPONENT_FILENAME
CACHE_SCRIPT=/usr/local/bin/dump_component_mapping.pl

ENV=$(grep ^hostname /etc/ssmtp/ssmtp.conf|awk -F. '{print toupper($2)}')

$CACHE_SCRIPT $ENV $OUTPUT_TEMP > $ERROR_TEMP 2>&1

if [ -s $OUTPUT_TEMP ] ; then
    mkdir -p $COMPONENT_DIR
    cp $COMPONENT_OUTPUT $COMPONENT_OUTPUT.bak
    cp $OUTPUT_TEMP $COMPONENT_OUTPUT
else
    /usr/bin/mail -s "dump_component_mapping.pl had an error"  CHANGEME@SOMEWHERE.COM -- -f component_mapper@PORTAL_SERVER.com < $ERROR_TEMP
fi

/bin/rm -f $ERROR_TEMP $OUTPUT_TEMP
