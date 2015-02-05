#!/bin/bash
cd /tmp
/bin/tar zxvf /root/OpenOffice.tar.gz
cd /tmp/en-US/DEBS
dpkg -i *.deb
cd ~/
rm -rf /tmp/en-US
