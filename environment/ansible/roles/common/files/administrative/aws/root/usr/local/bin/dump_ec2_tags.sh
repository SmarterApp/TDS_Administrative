#!/bin/bash
. /usr/local/etc/ec2.env

aws ec2 describe-instances --filter Name=instance-state-name,Values=running | grep ^TAG| grep $* |cut -f3- | sort
