# README #

Administrative Scripts for SmarterApp Environment - Amazon Web Services environment-specific scripts

### What is this repository for? ###

* Configuration, installation, and maintenance scripts

## Apps developed for administrative uses

1. backup\_all\_ebs\_volumes.pl
    this script loops through ALL ebs volumes and creates a snapshot of them. it will also remove any snapshots older than 3 days.
2. create\_nagios\_files.sh
    this script gathers a list of all servers, then makes a list of all servers running nrpe (nagios listener) and populates the nagios configuration files.
3. dump\_component\_mapping.pl
    this script creates a flat file of how 
4. dump\_component\_mapping.sh
    this script drives the dump\_component_mapping.pl file. If there are errors - the output files are NOT updated and an email is sent.
6. list\_running\_instances
    script used by other scripts to get a list of all running (non-stopped and non-terminated) instances.
7. loop\_servers
    this script will run the argument passed on all running instances
8. loop\_servers\_by\_name
    this script will run the argument passed on all running instances by their tag 'Name'
9. restart\_tomcat\_servers.sh
    this script loops to each running instance and will run the restart\_tomcat.sh script
10. restart\_tomcat.sh
    this script tries to cleanly shutdown tomcat and successfully start tomcat.
11. update\_authorized\_keys.sh
    this script is run on bootup on all servers to remove the non-root-login AWS pre code from /root/.ssh/authorized_keys
12. update\_route53\_cname.sh
    this script is run on bootup on all servers to update the EC2 CNAME in route53 for the name in the tag 'Name'
13. update\_ssmtp\_fqdn.sh
    this script is run on bootup on all servers to update the field 'hostname' in /etc/ssmtp/ssmtp.conf with the name in the tag 'Name'
