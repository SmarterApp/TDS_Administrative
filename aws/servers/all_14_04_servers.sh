if [ $# -ne 2 ] ; then
	echo "usage is: $0 PEM_FILE EC2_NAME"
	exit
fi
export PEM=$1
export SERVER=$2

#result=$(file $1)
#if [[ $result != *PEM\ RSA\ private\ key* ]] ; then
#	echo "$1 doesn't seem to be a PEM file"
#	exit
#fi

egrep -D skip -r -q CHANGEME  ../../root/
if [ $? -eq 0 ] ; then
	echo "You need to change the following \"CHANGEME\" values before running this script:"
	egrep -D skip -r CHANGEME  ../../root/
	exit
fi

export SSH="ssh -i $PEM ubuntu@$SERVER"

$SSH "sudo apt-get update"
$SSH "export DEBIAN_FRONTEND=noninteractive; sudo -E apt-get  -y upgrade"
$SSH "sudo useradd -m -s /bin/bash -d /usr/local/nagios nagios"

echo "installing extra packages"
$SSH "sudo apt-get install -y unattended-upgrades fail2ban python-pip ssmtp emacs pssh"

echo "need to fix permissions on files before we send them over"
chmod 600 ../../root/etc/ssh/*key ../../root/var/spool/cron/crontabs/root
chmod 440 ../../root/etc/sudoers
chmod 555 ../../root/usr/local/bin/cpan* ../../root/usr/local/bin/lwp*
chmod 4555 ../../root/usr/local/nagios/libexec/check_dhcp ../../root/usr/local/nagios/libexec/check_icmp
chmod 644 ../../root/etc/apt/apt.conf.d/10periodic ../../root/etc/bash.bashrc ../../root/etc/ca-certificates.conf ../../root/etc/environment ../../root/etc/init/nrpe.conf ../../root/etc/init/update_authorized_keys.conf ../../root/etc/init/update_route53_cname.conf ../../root/etc/init/update_ssmtp_fqdn.conf ../../root/etc/localtime ../../root/etc/profile ../../root/etc/skel/.bashrc ../../root/etc/ssh/moduli ../../root/etc/ssh/ssh_config ../../root/etc/ssh/sshd_config ../../root/etc/ssh/ssh_host_dsa_key.pub ../../root/etc/ssh/ssh_host_ecdsa_key.pub ../../root/etc/ssh/ssh_host_rsa_key.pub ../../root/etc/ssh/ssh_import_id ../../root/etc/ssl/openssl.cnf ../../root/etc/ssmtp/ssmtp.conf ../../root/etc/timezone ../../root/root/.bashrc ../../root/root/.ssh/config

echo "need to copy over the modified files. run this on your existing server (until we can check them out from github"
pushd ../../root
tar -cvf - . | $SSH "cd /;sudo tar --no-same-owner -xvBpf -"
popd

$SSH sudo pip install awscli

$SSH "sudo chown -R root.root /usr/local"
$SSH "sudo chown -R nagios.nagios /usr/local/nagios"
$SSH "sudo chgrp crontab /var/spool/cron/crontabs/root"

$SSH sudo service ssh restart
$SSH sudo service update_ssmtp_fqdn start
$SSH sudo service update_route53_cname start
$SSH sudo service update_authorized_keys start
