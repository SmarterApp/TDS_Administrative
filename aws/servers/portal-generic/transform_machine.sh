. ../all_servers.sh $1
echo "mysql password should be CHANGEME"
$SSH sudo apt-get -y install lamp-server^
$SSH sudo add-apt-repository '"deb http://us.archive.ubuntu.com/ubuntu/ saucy universe multiverse"'
$SSH sudo add-apt-repository '"deb http://us.archive.ubuntu.com/ubuntu/ saucy-updates universe multiverse"'
$SSH sudo apt-get update
#$SSH sudo apt-get -y install wordpress
#$SSH sudo gzip -d /usr/share/doc/wordpress/examples/setup-mysql.gz
#$SSH sudo bash /usr/share/doc/wordpress/examples/setup-mysql -n wordpress localhost
#$SSH "sudo cp /etc/wordpress/config-localhost.php /etc/wordpress/config-localhost.php.orig"
#$SSH "sudo mv /etc/wordpress/htaccess /etc/wordpress/htaccess.orig"
#cat smarterbalanced.theme.tar       | $SSH "cd /; sudo tar -xvBpf -"
#cat smarterbalanced.saml.plugin.tar | $SSH "cd /; sudo tar -xvBpf -"
#cat config-master.php               | $SSH "sudo dd of=/etc/wordpress/config-master.php"
zcat wordpress.tar.gz               | $SSH "cd /; sudo tar -xvBpf -"
cat apache.tar                      | $SSH "cd /; sudo tar -xvBpf -"
cat javascript.common.tar           | $SSH "cd /; sudo tar -xvBpf -"
cat alldb.sql                       | $SSH "mysql -u root -pCHANGEME"
$SSH sudo ln -s /usr/share/wordpress /var/www/wordpress
$SSH sudo chown -R www-data /usr/share/wordpress /etc/wordpress
cat update_wordpress_hostname.conf  | $SSH "sudo dd of=/etc/init/update_wordpress_hostname.conf"
cat update_wordpress_hostname.sh    | $SSH "sudo dd of=/usr/local/bin/update_wordpress_hostname.sh"
cat dump_component_mapping.pl       | $SSH "sudo dd of=/usr/local/bin/dump_component_mapping.pl"
cat dump_component_mapping.sh       | $SSH "sudo dd of=/usr/local/bin/dump_component_mapping.sh"
cat root.crontab                    | $SSH "sudo dd of=/var/spool/cron/crontabs/root"
$SSH sudo chown root.crontab /var/spool/cron/crontabs/root
$SSH sudo chmod 600 /var/spool/cron/crontabs/root
$SSH sudo chmod 755 /usr/local/bin/update_wordpress_hostname.sh /usr/local/bin/dump_component_mapping.sh /usr/local/bin/dump_component_mapping.pl
$SSH sudo /usr/local/bin/update_wordpress_hostname.sh
$SSH sudo service cron restart
$SSH sudo service mysql restart
$SSH sudo /etc/init.d/apache2 restart
wget http://generic-portal-dev.opentestsystem.org/wp-content/plugins/saml-20-single-sign-on/saml/www/module.php/saml/sp/metadata.php/1
