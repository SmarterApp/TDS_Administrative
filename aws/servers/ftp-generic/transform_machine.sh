. ../all_servers.sh $1
cat sshd_config | $SSH "sudo dd of=/etc/ssh/sshd_config"
$SSH "sudo chmod 755 /etc/ssh/sshd_config"
$SSH "sudo groupadd sftpusers"
