#!/bin/bash
# assume git wget installed
echo "Install and Configure NTPD"
yum install -y ntp 
systemctl start ntpd
systemctl enable ntpd

echo "Set Hostname and edit sysconfig/network file"
export host=$(hostname -f)
hostname $host
echo HOSTNAME=$host >> /etc/sysconfig/network

echo "Selinux set to 0"
setenforce 0

echo "Install ambari repo"
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo

echo "Install Ambari Agent"
yum install -y ambari-agent
sed -i 's/hostname=.*/hostname=master0.hdpcloud.internal/g' /etc/ambari-agent/conf/ambari-agent.ini

echo "Start Ambari Agent"
ambari-agent start

echo "Finished"