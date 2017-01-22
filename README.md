Prerequisites
==============
* [Docker Engine](https://www.docker.com/products/overview)
* [Ansible Container](https://docs.ansible.com/ansible-container/installation.html)


Apache 2.4 RPM Builder
==============

Apache 2.4 RPM builder is an ansible-container project used to compile and package apache 2.4.x into a portable RPM over a given Linux OS distro.

Build the image
---------------

    ansible-container --var-file ansible/roles/apache24_rpmbuilder/vars/main.yml  build --from-scratch --service apache24_rpmbuilder

Run the process
----------------------

    docker run -v /tmp/apache24_rpmbuilder:/tmp/RPMS -t -i apache24_rpmbuilder-apache24_rpmbuilder:latest