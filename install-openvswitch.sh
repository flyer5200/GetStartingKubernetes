yum -y install wget openssl-devel gcc make python-devel openssl-devel kernel-devel graphviz kernel-debug-devel autoconf automake rpm-build redhat-rpm-config libtool


mkdir -p ~/rpmbuild/SOURCES

cd ~/rpmbuild/SOURCES

wget http://10.0.0.213/cloud_repository/openvswitch/openvswitch-2.3.1.tar.gz

tar xfz openvswitch-2.3.1.tar.gz

cd openvswitch-2.3.1

cp rhel/openvswitch-kmod.files ~/rpmbuild/SOURCES/

sed 's/openvswitch-kmod, //g' rhel/openvswitch.spec > rhel/openvswitch_no_kmod.spec

rpmbuild -bb --without check rhel/openvswitch_no_kmod.spec

rpm -ivh --nodeps ~/rpmbuild/RPMS/x86_64/openvswitch-2.3.1-1.x86_64.rpm

yum install policycoreutils-python

mkdir /etc/openvswitch

semanage fcontext -a -t openvswitch_rw_t "/etc/openvswitch(/.*)?"

restorecon -Rv /etc/openvswitch
