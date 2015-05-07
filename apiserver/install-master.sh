#!/bin/sh

SCRIPTS_ADDR=http://10.0.0.213/cloud_repository/scripts/apiserver

wget ${SCRIPTS_ADDR}/apiserver.sh
wget ${SCRIPTS_ADDR}/controller-manager.sh
wget ${SCRIPTS_ADDR}/etcd.sh
wget ${SCRIPTS_ADDR}/install-kubernetes.sh
wget ${SCRIPTS_ADDR}/scheduler.sh

chmod 755 *.sh

rm -rf install-master.sh

sh etcd.sh
sh install-kubernetes.sh
sh apiserver.sh
sh controller-manager.sh
sh scheduler.sh
