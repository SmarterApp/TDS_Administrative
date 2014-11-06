#!/bin/bash

#this script configures Apache_OpenOffice-SDK_4.0.0_Linux_x86-64

openoffice=`soffice -h 2>&1 | grep -o OpenOffice`

if [ "OpenOffice" == "$openoffice" ] ; then
                echo "openoffice4 is already installed"
        else
                echo "Installing openoffice4"
                rm -rf /tmp/temp
                sudo rm -rf /usr/bin/soffice
                mkdir /tmp/temp
                cd /tmp/temp
                wget http://sourceforge.net/projects/openofficeorg.mirror/files/4.0.0/binaries/en-US/Apache_OpenOffice_4.0.0_Linux_x86-64_install-deb_en-US.tar.gz
                tar -xvf Apache_OpenOffice*.tar.gz
                sudo dpkg -i en-US/DEBS/*.deb
                sudo dpkg -i en-US/DEBS/desktop-integration/*.deb
                openoffice=`soffice -h 2>&1 | grep -o OpenOffice`

                if [ "OpenOffice" == "$openoffice" ] ; then
                        echo "openoffice4 is installed successfully"
					else
                        echo  "openoffice4 is failed to install."
                fi
fi
