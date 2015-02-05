#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
. /usr/local/etc/ec2.env

server_list=$(/usr/local/bin/list_running_instances_by_name)

cat > /usr/local/nagios/etc/hosts.cfg << EOF
## Default Linux Host Template ##

define host{
name                            linux-box               ; Name of this template
use                             generic-host,host-pnp   ; Inherit default values
check_period                    24x7        
check_interval                  5       
retry_interval                  1       
max_check_attempts              10      
check_command                   check-host-alive
notification_period             24x7    
notification_interval           1500      
notification_options            d,r     
contact_groups                  admins  
register                        0                       ; DONT REGISTER THIS - ITS A TEMPLATE
}

EOF

for server in $(echo $server_list)
do
#  echo $server
  address=$(dig $server|grep ^ec2|awk '{print $5}')
  if nmap -sT -p 5666 -oG - $server|grep -q "5666\/open"; then
  	echo $server has nrpe
        nagios_servers+=" $server"
	printf "define host{\n\tuse             linux-box               ; Inherit default values from a template\n\thost_name	%s\n\taddress		%s\n}\n" $server $address >> /usr/local/nagios/etc/hosts.cfg
  else
  	echo $server is NOT running nrpe
	printf "#define host{\n#\tuse             linux-box               ; Inherit default values from a template\n#\thost_name	%s\n#\taddress		%s\n#}\n" $server $address >> /usr/local/nagios/etc/hosts.cfg
  fi
done

all_servers=$(echo $nagios_servers|sed -e 's/^ //' -e 's/ /,/g')
printf "define hostgroup{\n\thostgroup_name	all-servers	; The name of the hostgroup\n\tmembers %s\n\talias		All Servers	; Long name of the group\n}\n" $all_servers > /usr/local/nagios/etc/hostgroups.cfg

################################################################################
for server in $(echo $nagios_servers)
do
  address=$(dig $server|grep ^ec2|awk '{print $5}')
  if nmap -sT -p 8080 -oG - $server|grep -q "8080\/open"; then
  	echo $server has tomcat
        tomcat_servers+=" $server"
  else
  	echo $server is NOT running tomcat
  fi
done

################################################################################
for server in $(echo $nagios_servers)
do
  address=$(dig $server|grep ^ec2|awk '{print $5}')
  if nmap -sT -p 28017 -oG - $server|grep -q "28017\/open"; then
  	echo $server has mongo
        mongo_servers+=" $server"
  else
  	echo $server is NOT running mongo
  fi
done

################################################################################
for server in $(echo $nagios_servers)
do
  address=$(dig $server|grep ^ec2|awk '{print $5}')
  if nmap -sT -p 3306 -oG - $server|grep -q "3306\/open"; then
  	echo $server has mysql
        mysql_servers+=" $server"
  else
  	echo $server is NOT running mysql
  fi
done

################################################################################
for server in $(echo $nagios_servers)
do
  address=$(dig $server|grep ^ec2|awk '{print $5}')
  if nmap -sT -p 80 -oG - $server|grep -q "80\/open"; then
  	echo $server has apache
        apache_servers+=" $server"
  else
  	echo $server is NOT running apache
  fi
done

################################################################################
#for server in $(echo $nagios_servers)
#do
#  address=$(dig $server|grep ^ec2|awk '{print $5}')
#  if nmap -sT -p 80 -oG - $server|grep -q "80\/open"; then
#  	echo $server has apache
#        apache_servers+=" $server"
#  else
#  	echo $server is NOT running apache
#  fi
#done

################################################################################
tomcat_servers=$(echo $tomcat_servers|sed -e 's/^ //' -e 's/ /,/g')
mongo_servers=$(echo $mongo_servers|sed -e 's/^ //' -e 's/ /,/g')
mysql_servers=$(echo $mysql_servers|sed -e 's/^ //' -e 's/ /,/g')
apache_servers=$(echo $apache_servers|sed -e 's/^ //' -e 's/ /,/g')

################################################################################
printf "define hostgroup{\n\thostgroup_name	tomcat-servers	; The name of the hostgroup\n\tmembers		%s\n\talias		Tomcat Servers	; Long name of the group\n\t}\n" $tomcat_servers >> /usr/local/nagios/etc/hostgroups.cfg
printf "define hostgroup{\n\thostgroup_name	mongo-servers	; The name of the hostgroup\n\tmembers		%s\n\talias		Mongo Servers	; Long name of the group\n\t}\n" $mongo_servers >> /usr/local/nagios/etc/hostgroups.cfg
printf "define hostgroup{\n\thostgroup_name	mysql-servers	; The name of the hostgroup\n\tmembers		%s\n\talias		Mysql Servers	; Long name of the group\n\t}\n" $mysql_servers >> /usr/local/nagios/etc/hostgroups.cfg
printf "define hostgroup{\n\thostgroup_name	apache-servers	; The name of the hostgroup\n\tmembers		%s\n\talias		Apache Servers	; Long name of the group\n\t}\n" $apache_servers >> /usr/local/nagios/etc/hostgroups.cfg
#printf "define hostgroup{\n\thostgroup_name	disk-servers	; The name of the hostgroup\n\tmembers		%s\n\talias		Disk Servers	; Long name of the group\n\t}\n" $nagios_servers >> hostgroups.cfg
/etc/init.d/nagios restart
