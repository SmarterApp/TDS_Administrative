. ../all_servers.sh $1
$SSH sudo apt-get remove ssmtp
$SSH sudo apt-get -y install dovecot postfix

cat dovecot.tar | $SSH "cd /; sudo tar -xvBpf -"
cat postfix.tar | $SSH "cd /; sudo tar -xvBpf -"
