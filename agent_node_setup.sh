#!/bin/bash
# assume git wget installed

yum install -y ntp 
systemctl start ntpd
systemctl enable ntpd

export host=$(hostname -f)
hostname $host
echo HOSTNAME=$host >> /etc/sysconfig/network

setenforce 0

wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo


yum install -y ambari-agent
sed -i 's/hostname=.*/hostname=master0.hdpcloud.internal/g' /etc/ambari-agent/conf/ambari-agent.ini

ambari-agent start