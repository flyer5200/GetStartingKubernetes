#!/bin/sh

# set hostname
setHostname(){
	hostnamectl set-hostname $(tr -dc A-Z-a-z-0-9 </dev/urandom |head -c8)
}

# replace default repo
replaceRepo(){
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

	wget http://mirrors.aliyun.com/repo/Centos-7.repo -O /etc/yum.repos.d/CentOS-Base.repo

	cat <<-EOF>> /etc/yum.repos.d/CentOS-Base.repo
	#add a latest repo
	[virt7-testing]
	name=virt7-testing
	baseurl=http://cbs.centos.org/repos/virt7-testing/x86_64/os/
	enabled=1
	gpgcheck=0
	exclude=kernel
	EOF
	yum clean all
	yum makecache
}

# install base tools
installBaseTools(){
	yum -y install lrzsz
	yum -y install net-tools
	yum -y install git	
}


#stop firewalld and replace to iptables
replaceFirewall(){
	systemctl stop firewalld
	systemctl disable firewalld

	yum -y erase firewalld
	yum -y install iptables-services

	systemctl start iptables
	systemctl enable iptables

	# iptables -F
	# iptables -X
	# iptables -P INPUT DROP
	# iptables -P OUTPUT DROP
	# iptables -P FORWARD DROP
	 
	# # Accept port 80
	# iptables -I INPUT -m tcp -p tcp --dport 80 -j ACCEPT
	# iptables -I OUTPUT -m tcp -p tcp --sport 80 -j ACCEPT
	 
	# # Accept port 22
	# iptables -I INPUT -m tcp -p tcp --dport 22 -j ACCEPT
	# iptables -I OUTPUT -m tcp -p tcp --sport 22 -j ACCEPT

	# # Allow full outgoing connection but no incomming stuff
	# iptables -I OUTPUT -o eth0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
	# iptables -I INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT

	# iptables-save > /etc/sysconfig/iptables
}


#update kernel to latest stable kernel
updateKernel(){
	#import key
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

	#switch rpm repo
	rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

	#install latest stable kernel
	yum --enablerepo=elrepo-kernel install  kernel-ml-devel kernel-ml -y

	#set grub boot
	grub2-set-default 0

	reboot	
}

yum -y install wget

setHostname

replaceRepo

installBaseTools

replaceFirewall

updateKernel