#!/bin/bash
. /usr/local/etc/ec2.env

/home/ubuntu/ec2.py --list > /home/ubuntu/ansible/inventory
