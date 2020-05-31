#!/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "starting 10.common.sh"

# disabling selinux
echo "disabling selinux"
setenforce 0
sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
# After CycleCloud 7.9 and later 
if [[ -z $CUSER ]]; then 
   CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/initialize.log | awk '{print $6}' | head -1)
   CUSER=${CUSER//\`/}
fi
echo ${CUSER} > /mnt/cluster-init/CUSER
HOMEDIR=/shared/home/${CUSER}
APPSDIR=/shared/home/${CUSER}/apps
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/genomicswfe/master

# Azure VMs that have ephemeral storage mounted at /mnt/exports.
if [[ ! -d ${HOMEDIR}/apps ]]; then 
   sudo -u ${CUSER} ln -s /mnt/exports/apps ${HOMEDIR}/apps
   chown ${CUSER}:${CUSER} ${HOMEDIR}/apps
fi

# file settings
if [[ ! -d ${HOMEDIR}/logs ]]; then
   mkdir -p ${HOMEDIR}/logs
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/logs
fi

#package installation
yum install -y htop screen

if [[ ! -f ${HOMEDIR}/azcopy ]]; then
   jetpack download "azcopy" ${HOMEDIR}
   chown ${CUSER}:${CUSER} ${HOMEDIR}/azcopy
   chmod +x ${HOMEDIR}/azcopy
fi



echo "end of 10.common.sh"
