. ../all_servers.sh $1
tar -cvf - root | $SSH "tar -xvBpf -"
$SSH "cd root/haproxy-1.5.1; sudo make install"
$SSH "cd root; sudo mv auto-scaling-demo autoscaling_haproxy_update.pl haproxy-1.5.1 haproxy-autoscale /root"
$SSH "cd root; sudo mv haproxy.cfg /etc/haproxy"
