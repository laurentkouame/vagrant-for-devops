#!/bin/bash

## Install p1jenkins

## Doc: https://www.chrisjmendez.com/2017/01/08/installing-jenkins-using-virtualbox-and-vagrant/

IP=$(hostname -I | awk '{print $2}')

echo "START - install jenkins - "$IP

echo "[1]: Install utils & ansible"
sudo apt-get update -qq >/dev/null
sudo apt-get install -qq -y git sshpass wget ansible gnupg2 curl >/dev/null

echo "[2]: Install java & jenkins"
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update && sudo apt-get upgrade >/dev/null
sudo apt-get install -qq -y default-jre jenkins >/dev/null
sudo apt-get install --force-y Jenkins >/dev/nul
systemctl enable jenkins
systemctl start jenkins

echo "[3]: ansible custom"
sed -i 's/.*pipelining.*/pipelining = True/' /etc/ansible/ansible.cfg
sed -i 's/.*allow_world_readable_tmpfiles.*/allow_world_readable_tmpfiles = True' /etc/ansible/ansible.cfg

echo "[4]: Install docker & docker-compose"
curl -fsSL https://get.docker.com | sh; >/dev/null
# autorize docker and jenkins user
usermod -aG docker jenkins 
curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "[5]: use registry without ssl"
echo "
{
	\"insecure-registries\" : [\"192.168.56.10:5000\"]
}
" >/etc/docker/daemon.json
systemctl daemon reload
systemctl restart docker

echo "END - Install jenkins"