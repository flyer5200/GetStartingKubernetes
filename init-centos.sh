#!/bin/sh

yum -y install wget

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

yum clean all

yum makecache

yum -y install lrzsz
yum -y install net-tools

hostnamectl set-hostname "centos7"

sh replace-firewall.sh