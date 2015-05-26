#!/bin/sh

BASE_DOWNLOAD_SERVER=http://10.0.0.213				#important!!!  you must set the kubernetes archives download url

MY_IP=$(hostname -I | awk '{print $1}')

KUBE_LOGTOSTDERR=true
KUBE_LOG_LEVEL=4
KUBE_API_SERVERS=10.0.0.120:8080
MINION_PORT=10250
MINION_HOSTNAME=$(hostname)

KUBE_ALLOW_PRIV=false
KUBE_BIND_ADDRESS=0.0.0.0

install_docker(){
	yum -y install docker
	sudo sed -i 's|OPTIONS=|OPTIONS=--registry-mirror=http://95728259.m.daocloud.io |g' /etc/sysconfig/docker
	
	systemctl stop docker
	systemctl daemon-reload	
	systemctl start docker
	systemctl enable docker
}

download_archives(){
	! test -d /opt/kubernetes* && rm -rf /opt/kubernetes*
	wget ${BASE_DOWNLOAD_SERVER}/cloud_repository/kubernetes/server/kubernetes-server-linux-amd64.tar.gz -O /opt/kubernetes-server-linux-amd64.tar.gz

	cd /opt/

	tar -vxzf kubernetes-server-linux-amd64.tar.gz

	cd ../
	rm -rf /opt/kubernetes-server-linux-amd64.tar.gz
}


install_kubelet(){
	cat <<-EOF>/usr/lib/systemd/system/kubelet.service
	[Unit]
	Description=Kubernetes Kubelet
	After=docker.service cadvisor.service
	Requires=docker.service

	[Service]
	ExecStart=/opt/kubernetes/server/bin/kubelet \\
	    --logtostderr=${KUBE_LOGTOSTDERR} \\
	    --v=${KUBE_LOG_LEVEL} \\
	    --api-servers=${KUBE_API_SERVERS} \\
	    --address=${KUBE_BIND_ADDRESS} \\
	    --port=${MINION_PORT} \\
	    --hostname_override=${MINION_HOSTNAME} \\
	    --allow_privileged=${KUBE_ALLOW_PRIV} \\
	Restart=on-failure

	[Install]
	WantedBy=multi-user.target
	EOF

	systemctl daemon-reload
	systemctl stop kubelet
	systemctl enable kubelet
	systemctl start kubelet	
}

install_kubeletProxy(){
	cat <<-EOF>/usr/lib/systemd/system/kubelet-proxy.service
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
}

applyIptablesRules(){
	iptables -I INPUT -p tcp --dport 10250 -j ACCEPT
	iptables -I OUTPUT -p tcp --dport 10250 -j ACCEPT
	iptables-save > /etc/sysconfig/iptables	
	systemctl restart iptables
}

install_docker

download_archives

install_kubelet

install_kubeletProxy

applyIptablesRules