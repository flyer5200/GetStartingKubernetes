#!/bin/sh

ETCD_PEER_ADDR=10.0.0.120:7001
ETCD_ADDR=0.0.0.0:4001
ETCD_DATA_DIR=/var/lib/etcd
ETCD_NAME=kubernetes

! test -f /usr/bin/etcd && wget http://10.0.0.213/cloud_repository/etcd -O /usr/bin/etcd 

! test -f /usr/bin/etcdctl && wget http://10.0.0.213/cloud_repository/etcd -O /usr/bin/etcdctl

chmod 755 /usr/bin/etcd*

! test -d $ETCD_DATA_DIR && mkdir -p $ETCD_DATA_DIR
cat <<EOF >/usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server

[Service]
ExecStart=/usr/bin/etcd \\
	-peer-addr=$ETCD_PEER_ADDR \\
	-addr=$ETCD_ADDR \\
	-data-dir=$ETCD_DATA_DIR \\
	-name=$ETCD_NAME \\
	-bind-addr=0.0.0.0

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl stop etcd
systemctl start etcd
systemctl enable etcd
