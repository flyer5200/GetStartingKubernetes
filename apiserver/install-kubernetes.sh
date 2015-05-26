#!/bin/sh

BASE_DOWNLOAD_SERVER=http://10.0.0.213				#important!!!  you must set the kubernetes archives download url

MY_IP=$(hostname -I | awk '{print $1}')

#etcd config
ETCD_PEER_ADDR=${MY_IP}:7001						#important!!!  you must defined etcd server address
ETCD_ADDR=${MY_IP}:4001
ETCD_DATA_DIR=/var/lib/etcd
ETCD_NAME=kubernetes


#apiserver config
KUBE_ETCD_SERVERS=http://${ETCD_ADDR}			#important!!!  you must set etcd server address
KUBE_API_ADDRESS=${MY_IP}
KUBE_API_PORT=8080
MINION_PORT=10250
KUBE_ALLOW_PRIV=false
KUBE_SERVICE_ADDRESSES=10.10.10.0/24

#controller manager config
MINION_ADDRESSES=10.0.0.118,10.0.0.119				#important!!!  you must set default minions node's address

#kube common config
KUBE_LOGTOSTDERR=true
KUBE_LOG_LEVEL=4
KUBE_MASTER=${KUBE_API_ADDRESS}:${KUBE_API_PORT}	#important!!!  you must set kube server address for other component

downloadkubernetes(){

	! test -d /opt/kubernetes* && rm -rf /opt/kubernetes*
	echo "start download kubernetes archives..."
	wget ${BASE_DOWNLOAD_SERVER}/cloud_repository/kubernetes/server/kubernetes-server-linux-amd64.tar.gz -O /opt/kubernetes-server-linux-amd64.tar.gz

	cd /opt/

	tar -vxzf kubernetes-server-linux-amd64.tar.gz

	cd ../
	rm -rf /opt/kubernetes-server-linux-amd64.tar.gz	
}

install_Etcd(){
	echo "start install Etcd..."
	! test -f /usr/bin/etcd && wget ${BASE_DOWNLOAD_SERVER}/cloud_repository/etcd -O /usr/bin/etcd 

	! test -f /usr/bin/etcdctl && wget ${BASE_DOWNLOAD_SERVER}/cloud_repository/etcd -O /usr/bin/etcdctl

	chmod 755 /usr/bin/etcd*

	! test -d $ETCD_DATA_DIR && mkdir -p $ETCD_DATA_DIR
	cat <<-EOF>/usr/lib/systemd/system/etcd.service
	[Unit]
	Description=Etcd Server
	Requires=network.service

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
}

install_KubeApiserver(){
	echo "start install KubeApiserver..."
	cat <<-EOF>/usr/lib/systemd/system/kube-apiserver.service
	[Unit]
	Description=Kubernetes API Server
	Documentation=https://github.com/GoogleCloudPlatform/kubernetes
	Requires=etcd.service

	[Service]
	ExecStart=/opt/kubernetes/server/bin/kube-apiserver  \\
		--logtostderr=${KUBE_LOGTOSTDERR} \\
		--v=${KUBE_LOG_LEVEL} \\
		--etcd_servers=${KUBE_ETCD_SERVERS} \\
		--address=${KUBE_API_ADDRESS} \\
		--port=${KUBE_API_PORT} \\
		--kubelet_port=${MINION_PORT} \\
		--allow_privileged=${KUBE_ALLOW_PRIV} \\
		--cors_allowed_origins=.* \\
		--portal_net=${KUBE_SERVICE_ADDRESSES}
	Restart=on-failure

	[Install]
	WantedBy=multi-user.target
	EOF

	systemctl daemon-reload
	systemctl stop kube-apiserver
	systemctl start kube-apiserver
	systemctl enable kube-apiserver
}


install_KubeControllerManager(){
	echo "start install KubeControllerManager..."
	cat <<-EOF>/usr/lib/systemd/system/kube-controller-manager.service
	[Unit]
	Description=Kubernetes Controller Manager
	Documentation=https://github.com/GoogleCloudPlatform/kubernetes
	Requires=kube-apiserver.service

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
	systemctl stop kube-controller-manager
	systemctl start kube-controller-manager
	systemctl enable kube-controller-manager
}


install_KubeScheduler(){
	echo "start install KubeScheduler..."
	cat <<-EOF>/usr/lib/systemd/system/kube-scheduler.service
	[Unit]
	Description=Kubernetes Scheduler
	Documentation=https://github.com/GoogleCloudPlatform/kubernetes
	Requires=kube-apiserver.service

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
	systemctl stop kube-scheduler
	systemctl start kube-scheduler
	systemctl enable kube-scheduler
}

applyIptablesRules(){
	iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
	iptables -I OUTPUT -p tcp --dport 8080 -j ACCEPT
	iptables -I INPUT -p tcp --dport 4001 -j ACCEPT
	iptables -I OUTPUT -p tcp --dport 4001 -j ACCEPT
	iptables -I INPUT -p tcp --dport 7001 -j ACCEPT
	iptables -I OUTPUT -p tcp --dport 7001 -j ACCEPT
	iptables-save > /etc/sysconfig/iptables	
	systemctl restart iptables
}

downloadkubernetes

install_Etcd

install_KubeApiserver

install_KubeControllerManager

install_KubeScheduler

applyIptablesRules
