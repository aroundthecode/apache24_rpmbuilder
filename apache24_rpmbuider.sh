#!/bin/bash

yum install -y wget

wget http://archive.apache.org/dist/httpd/httpd-2.4.20.tar.bz2
wget http://it.apache.contactlab.it//apr/apr-1.5.2.tar.bz2
wget http://it.apache.contactlab.it//apr/apr-util-1.5.4.tar.bz2

wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm

wget http://ftp5.gwdg.de/pub/opensuse/repositories/home:/zantekk:/Server-HTTPD24/RedHat_RHEL-6/x86_64/distcache-1.4.5-8.5.x86_64.rpm
wget http://ftp5.gwdg.de/pub/opensuse/repositories/home:/zantekk:/Server-HTTPD24/RedHat_RHEL-6/x86_64/distcache-devel-1.4.5-8.5.x86_64.rpm

rpm -i distcache-1.4.5-8.5.x86_64.rpm distcache-devel-1.4.5-8.5.x86_64.rpm

yum install -y rpm-build gcc make libtool doxygen distcache distcache-devel autoconf zlib-devel libselinux-devel libuuid-devel apr-devel apr-util-devel pcre-devel openldap-devel lua-devel libxml2-devel distcache-devel openssl-devel postgresql-devel mysql-devel sqlite-devel freetds-devel unixODBC-devel nss-devel ccache

sysctl net.ipv6.conf.all.disable_ipv6=0
rpmbuild -tb apr-1.5.2.tar.bz2
rpm -U ~/rpmbuild/RPMS/x86_64/apr-1.5.2-1.x86_64.rpm ~/rpmbuild/RPMS/x86_64/apr-devel-1.5.2-1.x86_64.rpm

rpmbuild -tb apr-util-1.5.4.tar.bz2

rpm -U ~/rpmbuild/RPMS/x86_64/apr-util-1.5.4-1.x86_64.rpm ~/rpmbuild/RPMS/x86_64/apr-util-devel-1.5.4-1.x86_64.rpm

rpmbuild -tb httpd-2.4.20.tar.bz2