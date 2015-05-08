#!/bin/sh

yum -y install wget

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

yum clean all

yum makecache

yum -y install lrzsz
yum -y install net-tools

hostnamectl set-hostname "minion1"


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
