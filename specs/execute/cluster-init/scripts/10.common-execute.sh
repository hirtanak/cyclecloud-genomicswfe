#!/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "starting 10.common.execute.sh"

# disabling selinux
echo "disabling selinux"
setenforce 0
sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/} 
CUSER=${CUSER//\`/}
echo ${CUSER} > /mnt/exports/shared/CUSER
HOMEDIR=/shared/home/${CUSER}

yum install -y htop java-1.8.0-openjdk-devel

mkdir -p anfvol01
mount -t nfs -o rw,hard,rsize=65536,wsize=65536,vers=3,tcp 10.0.8.4:/anfvol01 /shared/home/azureuser/anfvol01
chown ${CUSER}:${CUSER} /shared/home/azureuser/anfvol01

echo "end of 10.common-execute.sh"
