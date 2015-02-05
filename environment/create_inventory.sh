#!/bin/bash
. /usr/local/etc/ec2.env
./ec2.py --list > ansible/inventory
