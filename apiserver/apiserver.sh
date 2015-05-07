#!/bin/sh

KUBE_LOGTOSTDERR=true
KUBE_LOG_LEVEL=4
KUBE_ETCD_SERVERS=http://10.0.0.120:4001
KUBE_API_ADDRESS=0.0.0.0
KUBE_API_PORT=8080
MINION_PORT=10250
KUBE_ALLOW_PRIV=false
KUBE_SERVICE_ADDRESSES=10.10.10.0/24


cat <<EOF >/usr/lib/systemd/system/kubernetes-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/opt/kubernetes/server/bin/kube-apiserver  \\
	--logtostderr=${KUBE_LOGTOSTDERR} \\
	--v=${KUBE_LOG_LEVEL} \\
	--etcd_servers=${KUBE_ETCD_SERVERS} \\
	--address=${KUBE_API_ADDRESS} \\
	--port=${KUBE_API_PORT} \\
	--kubelet_port=${MINION_PORT} \\
	--allow_privileged=${KUBE_ALLOW_PRIV} \\
	--portal_net=${KUBE_SERVICE_ADDRESSES}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl stop kubernetes-apiserver
systemctl start kubernetes-apiserver
systemctl enable kubernetes-apiserver