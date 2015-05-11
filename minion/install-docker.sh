#!/bin/sh

# replace default repo and download latest docker 1.6

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



yum -y install docker

sudo sed -i 's|OPTIONS=|OPTIONS=--registry-mirror=http://95728259.m.daocloud.io |g' /etc/sysconfig/docker


systemctl start docker

systemctl enable docker
