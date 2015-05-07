#!/bin/sh

yum -y install docker

sudo sed -i 's|OPTIONS=|OPTIONS=--registry-mirror=http://95728259.m.daocloud.io |g' /etc/sysconfig/docker


systemctl start docker

systemctl enable docker
