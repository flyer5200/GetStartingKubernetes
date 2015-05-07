#!/bin/sh

! test -d /opt/kubernetes* && rm -rf /opt/kubernetes*
wget http://10.0.0.213/cloud_repository/kubernetes/server/kubernetes-server-linux-amd64.tar.gz -O /opt/kubernetes-server-linux-amd64.tar.gz

cd /opt/

tar -vxzf kubernetes-server-linux-amd64.tar.gz

cd ../
rm -rf /opt/kubernetes-server-linux-amd64.tar.gz
