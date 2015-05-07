#!/bin/sh


systemctl stop etcd
systemctl stop kubernetes-apiserver
systemctl stop kubernetes-controller-manager
systemctl stop kubernetes-scheduler

systemctl disable etcd
systemctl disable kubernetes-apiserver
systemctl disable kubernetes-controller-manager
systemctl disable kubernetes-scheduler

rm -rf /usr/lib/systemd/system/kubernetes-*.service
rm -rf /usr/lib/systemd/system/etcd.service
