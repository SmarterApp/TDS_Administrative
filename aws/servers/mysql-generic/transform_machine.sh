. ../all_servers.sh $1 $2
$SSH sudo apt-get -y install mysql-server
$SSH sudo mysql_secure_installation
