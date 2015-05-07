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
 
# # Accept packets from trusted IP addresses
# iptables -A INPUT -s [MY_IP] -j ACCEPT
# iptables -A OUTPUT -d [MY_IP] -j ACCEPT
 
# # Accept local nic
# iptables -A INPUT -i lo -j ACCEPT
# iptables -A OUTPUT -o lo -j ACCEPT
 
# # Accept port 80
# iptables -A INPUT -m tcp -p tcp --dport 80 -j ACCEPT
# iptables -A OUTPUT -m tcp -p tcp --sport 80 -j ACCEPT
 
# # Accept port 22
# iptables -A INPUT -m tcp -p tcp --dport 22 -j ACCEPT
# iptables -A OUTPUT -m tcp -p tcp --sport 22 -j ACCEPT

# # Allow full outgoing connection but no incomming stuff
# iptables -A OUTPUT -o eth0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT


# iptables-save > /etc/sysconfig/iptables
