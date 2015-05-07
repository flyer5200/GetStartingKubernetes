#!/bin/sh

KUBE_LOGTOSTDERR=true
KUBE_LOG_LEVEL=4
KUBE_BIND_ADDRESS=0.0.0.0
KUBE_API_SERVERS=10.0.0.120:8080

cat <<EOF >/usr/lib/systemd/system/kubelet-proxy.service
[Unit]
Description=Kubernetes Proxy
# the proxy crashes if etcd isn't reachable.
# https://github.com/GoogleCloudPlatform/kubernetes/issues/1206
After=network.target

[Service]
ExecStart=/opt/kubernetes/server/bin/kube-proxy \\
    --logtostderr=${KUBE_LOGTOSTDERR} \\
    --v=${KUBE_LOG_LEVEL} \\
    --bind_address=${KUBE_BIND_ADDRESS} \\
    --master=${KUBE_API_SERVERS} 
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl stop kubelet-proxy
systemctl enable kubelet-proxy
systemctl start kubelet-proxy
