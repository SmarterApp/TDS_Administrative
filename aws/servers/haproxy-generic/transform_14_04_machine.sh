. ../all_14_04_servers.sh
tar -cvf - root | $SSH "tar -xvBpf -"
$SSH "cd root/haproxy-1.5.1; sudo make install"
$SSH "cd root; sudo mv auto-scaling-demo autoscaling_haproxy_update.pl haproxy-1.5.1 haproxy-autoscale /root"
$SSH "cd root; sudo mv haproxy.cfg /etc/haproxy"
$SSH "sudo chown -R root.root /etc/haproxy/haproxy.conf /root/auto-scaling-demo /root/autoscaling_haproxy_update.pl /root/haproxy-1.5.1 /root/haproxy-autoscale"
