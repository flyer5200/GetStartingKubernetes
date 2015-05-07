#!/bin/sh

KUBE_LOGTOSTDERR=true
KUBE_LOG_LEVEL=4
KUBE_MASTER=10.0.0.120:8080
MINION_ADDRESSES=10.0.0.118,10.0.0.119

cat <<EOF >/usr/lib/systemd/system/kubernetes-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/opt/kubernetes/server/bin/kube-controller-manager \\
    --logtostderr=${KUBE_LOGTOSTDERR} \\
    --v=${KUBE_LOG_LEVEL} \\
	--machines=${MINION_ADDRESSES} \\
    --master=${KUBE_MASTER}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl stop kubernetes-controller-manager
systemctl start kubernetes-controller-manager
systemctl enable kubernetes-controller-manager