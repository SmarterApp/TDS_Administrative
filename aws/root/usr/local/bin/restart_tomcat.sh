#!/bin/bash
h=$(pgrep -u tomcat)
if [[ -n $h ]]; then
	kill $h
	while [[ -n $h ]]; do
		sleep 1
		h=$(pgrep -u tomcat)
	done
fi

service tomcat start

while true; do 
	if ! pgrep -u tomcat &>/dev/null; then
		echo "tomcat not alive, trying again..."
		service tomcat start
	else
		exit
	fi
	sleep 3
done

