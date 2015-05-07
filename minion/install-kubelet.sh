#!/bin/sh

KUBE_LOGTOSTDERR=true
KUBE_LOG_LEVEL=4
KUBE_API_SERVERS=10.0.0.120:8080
MINION_ADDRESS=0.0.0.0
MINION_PORT=10250
MINION_HOSTNAME=10.0.0.118
KUBE_ALLOW_PRIV=false
BASE_DOCKER_CONTAINER=docker.io/centos:latest

cat <<EOF >/usr/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
After=docker.service cadvisor.service
Requires=docker.service

[Service]
ExecStart=/opt/kubernetes/server/bin/kubelet \\
    --logtostderr=${KUBE_LOGTOSTDERR} \\
    --v=${KUBE_LOG_LEVEL} \\
    --api-servers=${KUBE_API_SERVERS} \\
    --address=${MINION_ADDRESS} \\
    --port=${MINION_PORT} \\
    --hostname_override=${MINION_HOSTNAME} \\
    --pod-infra-container-image=${BASE_DOCKER_CONTAINER} \\
    --allow_privileged=${KUBE_ALLOW_PRIV} \\
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl stop kubelet
systemctl enable kubelet
systemctl start kubelet
