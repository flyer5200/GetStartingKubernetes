#!/bin/sh

yum -y install wget


# replace default repo

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo


cat <<EOF>> /etc/yum.repos.d/CentOS-Base.repo

#add a latest repo
[virt7-testing]
name=virt7-testing
baseurl=http://cbs.centos.org/repos/virt7-testing/x86_64/os/
enabled=1
gpgcheck=0
exclude=kernel

EOF


yum clean all

yum makecache


# install base tools

yum -y install lrzsz
yum -y install net-tools
yum -y install git

# set hostname

hostnamectl set-hostname "centos7"


#stop firewalld and replace to iptables

sh replace-firewall.sh




#update kernel to latest stable kernel

#import key
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

#switch rpm repo
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

#install latest stable kernel
yum --enablerepo=elrepo-kernel install  kernel-ml-devel kernel-ml -y

#set grub boot
grub2-set-default 0

reboot

