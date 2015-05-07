#!/bin/sh

KUBE_LOGTOSTDERR=true
KUBE_LOG_LEVEL=4
KUBE_MASTER=10.0.0.120:8080

cat <<EOF>>/usr/lib/systemd/system/kubernetes-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/opt/kubernetes/server/bin/kube-scheduler \\
	 --logtostderr=${KUBE_LOGTOSTDERR} \\
	 --v=${KUBE_LOG_LEVEL} \\
	 --master=${KUBE_MASTER}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl stop kubernetes-scheduler
systemctl start kubernetes-scheduler
systemctl enable kubernetes-scheduler