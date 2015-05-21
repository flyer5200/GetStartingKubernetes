#!/bin/sh


systemctl stop etcd
systemctl stop kube-apiserver
systemctl stop kube-controller-manager
systemctl stop kube-scheduler

systemctl disable etcd
systemctl disable kube-apiserver
systemctl disable kube-controller-manager
systemctl disable kube-scheduler

rm -rf /usr/lib/systemd/system/kubernetes-*.service
rm -rf /usr/lib/systemd/system/etcd.service
