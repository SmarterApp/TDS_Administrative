. ../all_servers.sh $1 $2
$SSH sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
$SSH "echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list"
$SSH sudo apt-get update
$SSH sudo apt-get -y install mongodb-10gen=2.4.9
$SSH sudo service mongodb start
