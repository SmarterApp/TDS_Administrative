. ../all_14_04_servers.sh
cat sshd_config | $SSH "sudo dd of=/etc/ssh/sshd_config"
$SSH "sudo chmod 755 /etc/ssh/sshd_config"
$SSH "sudo groupadd sftpusers"
