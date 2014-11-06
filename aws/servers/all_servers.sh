if [ $# -ne 2 ] ; then
	echo "usage is: $0 PEM_FILE EC2_NAME"
	exit
fi
export PEM=$1
export SERVER=$2

#result=$(file $1)
#if [[ $result != *PEM\ RSA\ private\ key* ]] ; then
#	echo "$1 doesn't seem to be a PEM file"
#	exit
#fi

egrep -D skip -r -q CHANGEME  ../../root/
if [ $? -eq 0 ] ; then
	echo "You need to change the following \"CHANGEME\" values before running this script:"
	egrep -D skip -r CHANGEME  ../../root/
	exit
fi

export SSH="ssh -i $PEM ubuntu@$2"
$SSH sudo apt-get update
$SSH sudo apt-get --force-yes -y upgrade
$SSH sudo apt-get --force-yes -y install ant ant-optional aspectj autoconf automake autopoint autotools-dev binutils bsh-gcj bsh build-essential ca-certificates-java chkconfig consolekit cpp-4.6 cpp cryptsetup-bin dbus-x11 dconf-gsettings-backend dconf-service debhelper dh-apparmor dh-autoreconf dpkg-dev emacs23-bin-common emacs23-common emacs23 emacsen-common fail2ban fakeroot fontconfig-config fontconfig fop g++-4.6 gamin gcc-4.6-base:i386 gcc-4.6 gcc gcj-4.6-base gcj-4.6-jre-lib gconf2-common gconf2 gconf-service-backend gconf-service gettext g++ git git-man glassfish-javaee gvfs-common gvfs-daemons gvfs gvfs-libs hicolor-icon-theme html2text icedtea-6-jre-cacao icedtea-6-jre-jamvm icedtea-6-plugin icedtea6-plugin icedtea-7-jre-jamvm icedtea-netx-common icedtea-netx intltool-debian java-common java-wrappers junit4 junit libacl1:i386 libaether-java libaio1 libaio-dev libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libantlr-java libaopalliance-java libapache-pom-java libasm3-java libasound2 libaspectj-java libasync-http-client-java libasyncns0 libatasmart4 libatinject-jsr330-api-java libatk1.0-0 libatk1.0-data libatk-wrapper-java libatk-wrapper-java-jni libattr1:i386 libavahi-client3 libavahi-common3 libavahi-common-data libavahi-glib1 libavalon-framework-java libbackport-util-concurrent-java libbatik-java libbonobo2-0 libbonobo2-common libboost-filesystem1.46.1 libboost-program-options1.46.1 libboost-system1.46.1 libboost-thread1.46.1 libbsf-java libbz2-1.0:i386 libc6-dev libc6:i386 libcairo2 libcairo-gobject2 libcanberra0 libcap2 libc-dev-bin libcdi-api-java libcglib-java libck-connector0 libclassworlds-java libcomerr2:i386 libcommons-beanutils-java libcommons-cli-java libcommons-codec-java libcommons-collections3-java libcommons-collections-java libcommons-configuration-java libcommons-digester-java libcommons-httpclient-java libcommons-io-java libcommons-jexl-java libcommons-jxpath-java libcommons-lang-java libcommons-logging-java libcommons-net2-java libcommons-parent-java libcommons-validator-java libcommons-vfs-java libcroco3 libcryptsetup4 libcups2 libdatrie1 libdb5.1:i386 libdbus-1-3:i386 libdconf0 libdevmapper-event1.02.1 libdom4j-java libdoxia-java libdoxia-sitetools-java libdpkg-perl libeasymock-java liberror-perl libexcalibur-logkit-java libffi6:i386 libflac8 libfontconfig1 libfontenc1 libfop-java libgamin0 libganymed-ssh2-java libgcc1:i386 libgcj12 libgcj-bc libgcj-common libgconf-2-4 libgconf2-4 libgd2-noxpm libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgdu0 libgeronimo-interceptor-3.0-spec-java libgeronimo-jpa-2.0-spec-java libgeronimo-osgi-support-java libgettextpo0 libgif4 libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libglib2.0-0:i386 libglib2.0-data libgnome2-0 libgnome2-bin libgnome2-common libgnome-keyring0 libgnome-keyring-common libgnomevfs2-0 libgnomevfs2-common libgnutls-openssl27 libgomp1 libgoogle-collections-java libgpgme11 libgpm2:i386 libgtk2.0-0 libgtk2.0-bin libgtk2.0-common libgtk-3-0 libgtk-3-bin libgtk-3-common libguava-java libhamcrest-java libhtml-template-perl libhttpclient-java libhttpcore-java libice6 libice-dev libidl0 libidl-common libitext1-java libjasper1 libjaxen-java libjaxme-java libjaxp1.3-java libjdom1-java libjetty-java libjline-java libjpeg8 libjpeg-turbo8 libjsch-java libjson0 libjsoup-java libjsr305-java libjtidy-java liblcms2-2 libllvm3.0 liblog4j1.2-java libltdl7 libltdl-dev liblvm2app2.2 libm17n-0 libmail-sendmail-perl libmaven2-core-java libmaven-plugin-tools-java libmaven-reporting-impl-java libmaven-scm-java libmodello-java libmpc2 libmpfr4 libncurses5:i386 libncursesw5:i386 libnetbeans-cvsclient-java libnetty-java libnspr4 libnss3-1d libnss3 libogg0 libopts25 liborbit2 liboro-java libosgi-compendium-java libosgi-core-java libosgi-foundation-ee-java libotf0 libpam-ck-connector libpango1.0-0 libpciaccess0:i386 libpcre3:i386 libpcrecpp0 libpixman-1-0 libplexus-ant-factory-java libplexus-archiver-java libplexus-bsh-factory-java libplexus-build-api-java libplexus-cipher-java libplexus-classworlds2-java libplexus-classworlds-java libplexus-cli-java libplexus-container-default-java libplexus-containers1.5-java libplexus-containers-java libplexus-i18n-java libplexus-interactivity-api-java libplexus-interpolation-java libplexus-io-java libplexus-sec-dispatcher-java libplexus-utils2-java libplexus-utils-java libplexus-velocity-java libpng12-0:i386 libpolkit-agent-1-0 libpolkit-backend-1-0 libpth20 libpthread-stubs0-dev libpthread-stubs0 libpulse0 libqdox-java libquadmath0 libregexp-java librhino-java librsvg2-2 libsaxon-java libselinux1:i386 libservlet2.4-java libservlet2.5-java libsgutils2-2 libsisu-guice-java libsisu-ioc-java libslang2:i386 libslf4j-java libsm6 libsm-dev libsndfile1 libstdc++6-4.6-dev libsys-hostname-long-perl libtdb1 libthai0 libthai-data libtiff4 libtinfo5:i386 libtokyocabinet8 libtool libudev0:i386 libunistring0 libuuid1:i386 libvorbis0a libvorbisenc2 libvorbisfile3 libwagon-java libwerken.xpath-java libx11-dev libx11-doc libx11-xcb1 libxalan2-java libxau-dev libxaw7 libxbean-java libxcb1-dev libxcb-glx0 libxcb-render0 libxcb-shape0 libxcb-shm0 libxcomposite1 libxcursor1 libxdamage1 libxdmcp-dev libxerces2-java libxfixes3 libxft2 libxi6 libxinerama1 libxml-commons-external-java libxml-commons-resolver1.1-java libxmlgraphics-commons-java libxmu6 libxom-java libxpm4 libxpp2-java libxpp3-java libxrandr2 libxrender1 libxt6 libxt-dev libxtst6 libxv1 libxxf86dga1 libxxf86vm1 linux-headers-3.2.0-40 linux-headers-3.2.0-40-virtual linux-headers-3.2.0-48 linux-headers-3.2.0-48-virtual linux-headers-3.2.0-64 linux-headers-3.2.0-64-virtual linux-headers-3.2.0-65 linux-headers-3.2.0-65-virtual linux-headers-3.2.0-67 linux-headers-3.2.0-67-virtual linux-image-3.2.0-40-virtual linux-image-3.2.0-48-virtual linux-image-3.2.0-64-virtual linux-image-3.2.0-65-virtual linux-image-3.2.0-67-virtual linux-libc-dev m17n-contrib m17n-db m4 make manpages-dev maven mercurial-common mercurial module-assistant mtools mutt ncurses-term ntp openjdk-6-jdk openjdk-6-jre-headless openjdk-6-jre openjdk-6-jre-lib openjdk-7-jdk openjdk-7-jre-headless openjdk-7-jre po-debconf policykit-1-gnome policykit-1 python-central python-gamin python-pip python-setuptools python-support rhino shared-mime-info siege sound-theme-freedesktop ssmtp ttf-dejavu-core ttf-dejavu-extra tzdata-java udisks unzip velocity whois x11-common x11proto-core-dev x11proto-input-dev x11proto-kb-dev x11-utils xorg-sgml-doctools xtrans-dev zlib1g:i386 pssh

echo "unattended security updates"
$SSH sudo apt-get install unattended-upgrades

$SSH sudo pip install awscli

echo "Changing Java to point to the newest one installed"
$SSH "sudo update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java"

echo "Changing permissions before we send them over"
chmod 600 ../../root/etc/ssh/*key ../../root/var/spool/cron/crontabs/root
chmod 440 ../../root/etc/sudoers
chmod 555 ../../root/usr/local/bin/cpan* ../../root/usr/local/bin/lwp*
chmod 4555 ../../root/usr/local/nagios/libexec/check_dhcp ../../root/usr/local/nagios/libexec/check_icmp
chmod 644 ../../root/etc/apt/apt.conf.d/10periodic ../../root/etc/bash.bashrc ../../root/etc/ca-certificates.conf ../../root/etc/environment ../../root/etc/init/nrpe.conf ../../root/etc/init/update_authorized_keys.conf ../../root/etc/init/update_route53_cname.conf ../../root/etc/init/update_ssmtp_fqdn.conf ../../root/etc/localtime ../../root/etc/profile ../../root/etc/skel/.bashrc ../../root/etc/ssh/moduli ../../root/etc/ssh/ssh_config ../../root/etc/ssh/sshd_config ../../root/etc/ssh/ssh_host_dsa_key.pub ../../root/etc/ssh/ssh_host_ecdsa_key.pub ../../root/etc/ssh/ssh_host_rsa_key.pub ../../root/etc/ssh/ssh_import_id ../../root/etc/ssl/openssl.cnf ../../root/etc/ssmtp/ssmtp.conf ../../root/etc/timezone ../../root/root/.bashrc ../../root/root/.ssh/config

echo "need to copy over the modified files. run this on your existing server (until we can check them out from github"
pushd ../../root
tar -cvf - etc/bash.bashrc etc/ca-certificates.conf etc/environment etc/profile etc/sudoers etc/timezone etc/localtime etc/default/fail2ban etc/fail2ban/jail.conf etc/fail2ban/jail.local etc/init.d/fail2ban etc/init/nrpe.conf etc/init/update_authorized_keys.conf etc/init/update_route53_cname.conf etc/init/update_ssmtp_fqdn.conf etc/logrotate.d/fail2ban etc/logrotate.d/tomcat etc/skel/.bashrc etc/ssh etc/ssl/openssl.cnf etc/ssmtp/ssmtp.conf root/.ssh root/air.pem root/air_production.pem root/.bashrc var/spool/cron/crontabs/root home/ec2 usr/local/bin usr/local/etc usr/local/include usr/local/lib usr/local/man usr/local/nagios usr/local/sbin usr/local/share | $SSH "cd /;sudo tar --no-same-owner -xvBpf -"
popd

$SSH sudo service ssh restart
$SSH sudo service update_ssmtp_fqdn start
$SSH sudo service update_route53_cname start
$SSH sudo service update_authorized_keys start
