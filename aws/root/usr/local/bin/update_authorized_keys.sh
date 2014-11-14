#!/bin/sh

# This script will perform a DynDNS-like function for Amazon's Route 53
#
# Author: Johan Lindh <johan@linkdata.se>
# http://www.linkdata.se/
#
# Script requirements:
#
#  wget
#  grep
#  sed
#  dig
#  cut
#  openssl
#  base64
#
# Most if not all of these come standard on *nix distros.
#
sleep 30
/usr/bin/perl -pi.bak -e "s/^.* ssh/ssh/" /root/.ssh/authorized_keys
