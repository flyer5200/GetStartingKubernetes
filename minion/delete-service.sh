#!/bin/sh


systemctl stop kubelet
systemctl stop kubelet-proxy

systemctl disable kubelet-proxy
systemctl disable kubelet-proxy

rm -rf /usr/lib/systemd/system/kubelet.service
rm -rf /usr/lib/systemd/system/kubelet-proxy.service
