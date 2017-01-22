#!/bin/bash

DWN_BASE_PATH={{ output_path }}
SRC_BASE_PATH={{ vol_path }}

DWN_VERSION=$(cat /etc/redhat-release | grep -o -P "([0-9]\.?)*");
MJR_VERSION=$(echo ${DWN_VERSION} | cut -f1 -d"." )

DWN_PATH=${DWN_BASE_PATH}/repo/Httpd24/${DWN_VERSION}/{{src_apache_ver}}

BUILD_PREREQUISITES="{{prereq_rpm}}"
HTTPD_PREREQUISITES="{{prereq_httpd}}"


echo "removing ${DWN_BASE_PATH}/repo/Centos/${DWN_VERSION}/latest"
rm -rf ${DWN_BASE_PATH}/repo/Centos/${DWN_VERSION}/latest ${DWN_BASE_PATH}/httpd24-repo.*

echo "creating ${DWN_PATH}"
mkdir -p ${DWN_PATH}

echo "Setting up EPEL ${MJR_VERSION}"
command rpm -Uvh --replacepkgs https://dl.fedoraproject.org/pub/epel/epel-release-latest-${MJR_VERSION}.noarch.rpm

#Install wget first for fail-fast if url not available
yum install -y wget

wget {{ src_apache_url }}
wget {{ src_apr_url }}
wget {{ src_apr_util_url }}
wget {{ src_mod_security_url }}
wget {{ distcache_url }}
wget {{ distcache_devel_url }}

yum install -y {{distcache_file}} {{distcache_devel_file}}

yum install -y ${BUILD_PREREQUISITES}

#needed by tests
#sysctl net.ipv6.conf.all.disable_ipv6=0


echo "**************************"
echo "*** APR/UTILS RPMBUILD ***"
echo "**************************"

rpmbuild -tb {{src_apr_file}} > ${DWN_BASE_PATH}/rpmbuild_apr.log
rpm -U ~/rpmbuild/RPMS/x86_64/apr-{{src_apr_ver}}-1.x86_64.rpm ~/rpmbuild/RPMS/x86_64/apr-devel-{{src_apr_ver}}-1.x86_64.rpm

rpmbuild -tb {{src_apr_util_file}} > ${DWN_BASE_PATH}/rpmbuild_aprutil.log

rpm -U ~/rpmbuild/RPMS/x86_64/apr-util-{{src_apr_util_ver}}-1.x86_64.rpm ~/rpmbuild/RPMS/x86_64/apr-util-devel-{{src_apr_util_ver}}-1.x86_64.rpm

echo "**********************"
echo "*** HTTPD RPMBUILD ***"
echo "**********************"

rpmbuild -tb {{src_apache_file}} > ${DWN_BASE_PATH}/rpmbuild_httpd.log

{% if centosver == "6.6" %}
yum install -y yum-utils
echo "Invoking Yum-Downloader to retrieve httpd install dependencies [${HTTPD_PREREQUISITES}]"
{{ downloader66 }}${DWN_PATH} ${HTTPD_PREREQUISITES} > ${DWN_BASE_PATH}/yum_downloadonly.log 2>&1

{% else %}
echo "Invoking Yum Download-Only to retrieve httpd install dependencies [${HTTPD_PREREQUISITES}]"
{{ downloader }}${DWN_PATH} ${HTTPD_PREREQUISITES} > ${DWN_BASE_PATH}/yum_downloadonly.log 2>&1
{% endif %}

echo "*****************************"
echo "*** MOD_SECURITY RPMBUILD ***"
echo "*****************************"

yum install -y ${HTTPD_PREREQUISITES}
rpm -i ~/rpmbuild/RPMS/x86_64/httpd-{{src_apache_ver}}-1.x86_64.rpm ~/rpmbuild/RPMS/x86_64/httpd-tools-{{src_apache_ver}}-1.x86_64.rpm ~/rpmbuild/RPMS/x86_64/httpd-devel-{{src_apache_ver}}-1.x86_64.rpm

#unpack mod_security tarball to add SPEC file and repackage
tar -zxf {{src_mod_security_file}}
mv {{vol_path}}/mod_security.spec modsecurity-{{src_mod_security_ver}}/mod_security.spec
rm -f {{src_mod_security_file}}
tar -zcf {{src_mod_security_file}} modsecurity-{{src_mod_security_ver}}
rpmbuild -tb {{src_mod_security_file}}  > ${DWN_BASE_PATH}/rpmbuild_modsecurity.log

echo "***************************"
echo "*** YUM REPO GENERATION ***"
echo "***************************"

mv ~/rpmbuild/RPMS/x86_64/*.rpm ${DWN_PATH}/

echo "installing createrepo package"
yum install -y createrepo gzip

echo "indexing ${DWN_PATH}"
cd ${DWN_PATH}
createrepo .

echo "<html><body><table>" > ${DWN_BASE_PATH}/repo/index.html
zcat repodata/*primary.xml.gz  | grep -e "<name" -e "<summary" | sed -e "s/<name>/<tr><td>/g" -e "s/<\/name>/<\/td>/g" -e "s/<summary>/<td>/g" -e "s/<\/summary>/<\/td><\/tr>/g" >>${DWN_BASE_PATH}/repo/index.html
echo "</table></body></html>" >> ${DWN_BASE_PATH}/repo/index.html

cd ${DWN_BASE_PATH}
tar -zcvf httpd24-repo${DWN_VERSION}.tar.gz repo

