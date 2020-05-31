#!/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "start 30.cromwell script"

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
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/genomicswfe/master
APPSDIR=/shared/home/${CUSER}/apps

CROMWELL_VERSION=44
CROMWELL_VERSION=$(jetpack config cromwell.version)

## Checking VM SKU and Cores
VMSKU=`cat /proc/cpuinfo | grep "model name" | head -1 | awk '{print $7}'`
CORES=$(grep cpu.cores /proc/cpuinfo | wc -l)

## Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

## directory setting
mkdir -p ${APPSDIR}/cromwell
chmod -R a+rx ${APPSDIR}/cromwell
chown -R ${CUSER}:${CUSER} ${APPSDIR}/cromwell

# download java, cromwell rpm 
#if [[ ! -f ${APPSDIR}/jdk-8u221-linux-x64.rpm ]]; then
#   jetpack download "jdk-8u221-linux-x64.rpm" ${APPSDIR}/
#   chown ${CUSER}:${CUSER} ${APPSDIR}/jdk-8u221-linux-x64.rpm   
#fi
if [[ ! -f ${APPSDIR}/cromwell-${CROMWELL_VERSION}.jar ]]; then
#   jetpack download "cromwell-${CROMWELL_VERSION}.jar" ${APPSDIR}/cromwell/
   wget -nv https://github.com/broadinstitute/cromwell/releases/download/${CROMWELL_VERSION}/cromwell-${CROMWELL_VERSION}.jar -O ${APPSDIR}/cromwell/cromwell-${CROMWELL_VERSION}.jar
   chown ${CUSER}:${CUSER} ${APPSDIR}/cromwell/cromwell-${CROMWELL_VERSION}.jar
fi
if [[ ! -f ${APPSDIR}/womtool-${CROMWELL_VERSION}.jar ]]; then
#   jetpack download "womtool-${CROMWELL_VERSION}.jar" ${APPSDIR}/cromwell/
   wget -nv https://github.com/broadinstitute/cromwell/releases/download/${CROMWELL_VERSION}/womtool-${CROMWELL_VERSION}.jar -O ${APPSDIR}/cromwell/womtool-${CROMWELL_VERSION}.jar
   chown ${CUSER}:${CUSER} ${APPSDIR}/cromwell/womtool-${CROMWELL_VERSION}.jar
fi
if [[ ! -f /bin/java ]]; then
#   rpm -ivh ${APPSDIR}/jdk-8u221-linux-x64.rpm
   yum install -y java-1.8.0-openjdk-devel
fi
java -version

echo "end 30.cromwell script"
