yum -y install cadvisor docker

sudo sed -i 's|OPTIONS=|OPTIONS=--registry-mirror=http://95728259.m.daocloud.io |g' /etc/sysconfig/docker


systemctl start docker
systemctl start cadvisor

systemctl enable docker
systemctl enable cadvisor
