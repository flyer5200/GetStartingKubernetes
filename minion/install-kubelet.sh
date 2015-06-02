#!/bin/sh

BASE_DOWNLOAD_SERVER=http://download.linux-dream.net				#important!!!  you must set the kubernetes archives download url
KUBE_API_SERVERS=192.168.1.2:8080						#important!!!  you must set the kubernetes apiserver


KUBE_LOGTOSTDERR=true
KUBE_LOG_LEVEL=4
MINION_PORT=10250
KUBE_ALLOW_PRIV=false
KUBE_BIND_ADDRESS=0.0.0.0
MY_IP=$(hostname -I | awk '{print $1}')

install_docker(){
	echo "starting install docker..."
	#delete aliyun ecs default route config
	sed -i "/^172.16.0.0/d" /etc/sysconfig/network-scripts/route-eth0
	route del -net 172.16.0.0 netmask 255.240.0.0 dev eth0

	yum -y install docker
		
	systemctl stop docker
	systemctl daemon-reload	
	systemctl start docker
	systemctl enable docker
	echo "docker install successfull!"
}

download_archives(){
	echo "starting download kubernetes..."

	test -d /opt/kubernetes-minion && rm -rf /opt/kubernetes-minion

	wget ${BASE_DOWNLOAD_SERVER}/archives/kubernetes/kubernetes-minion.tar.gz -O /opt/kubernetes-minion.tar.gz

	cd /opt/

	tar -vxzf kubernetes-minion.tar.gz

	cd ../
	rm -rf /opt/kubernetes-minion.tar.gz

	echo "kubernetes download successfull!"
}


install_kubelet(){
	echo "starting install kubelet..."
	cat <<-EOF>/usr/lib/systemd/system/kubelet.service
	[Unit]
	Description=Kubernetes Kubelet
	After=docker.service
	Requires=docker.service

	[Service]
	ExecStart=/opt/kubernetes-minion/kubelet \\
	    --logtostderr=${KUBE_LOGTOSTDERR} \\
	    --v=${KUBE_LOG_LEVEL} \\
	    --api-servers=${KUBE_API_SERVERS} \\
	    --address=${KUBE_BIND_ADDRESS} \\
	    --port=${MINION_PORT} \\
	    --hostname_override=${MY_IP} \\
	    --allow_privileged=${KUBE_ALLOW_PRIV}
	Restart=on-failure

	[Install]
	WantedBy=multi-user.target
	EOF

	systemctl daemon-reload
	systemctl stop kubelet
	systemctl enable kubelet
	systemctl start kubelet	

	echo "kubelet install successfull!"
}

install_kubeletProxy(){
	echo "starting install kubeletProxy..."
	cat <<-EOF>/usr/lib/systemd/system/kubelet-proxy.service
	[Unit]
	Description=Kubernetes Proxy
	# the proxy crashes if etcd isn't reachable.
	# https://github.com/GoogleCloudPlatform/kubernetes/issues/1206
	After=network.target

	[Service]
	ExecStart=/opt/kubernetes-minion/kube-proxy \\
	    --logtostderr=${KUBE_LOGTOSTDERR} \\
	    --v=${KUBE_LOG_LEVEL} \\
	    --master=${KUBE_API_SERVERS} \\
	    --bind_address=${KUBE_BIND_ADDRESS}
	    
	Restart=on-failure

	[Install]
	WantedBy=multi-user.target
	EOF

	systemctl daemon-reload
	systemctl stop kubelet-proxy
	systemctl enable kubelet-proxy
	systemctl start kubelet-proxy

	echo "kubeletProxy install successfull!"
}

applyIptablesRules(){
	systemctl start iptables

	iptables -I INPUT -p tcp --dport 4194 -j ACCEPT

	iptables -I OUTPUT -p tcp --dport 4194 -j ACCEPT

	iptables -I INPUT -p tcp --dport ${MINION_PORT} -j ACCEPT

	iptables -I OUTPUT -p tcp --dport ${MINION_PORT} -j ACCEPT

	iptables-save > /etc/sysconfig/iptables	
	systemctl restart iptables

	echo "Apply iptables rules successfull!"
}

install_docker

download_archives

install_kubelet

install_kubeletProxy

applyIptablesRules