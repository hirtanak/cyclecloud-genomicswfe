#!/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "start 50.gatk script"

# https://github.com/broadinstitute/gatk/releases/download/4.1.3.0/gatk-4.1.3.0.zip

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

## Applicatin Installation
APP_INSTALLATION_TPYE=Compile
APP_INSTALLATION_TPYE=$(jetpack config app.installation.type)
if [[ ${APP_INSTALLATION_TPYE} != Compile ]]; then
   exit 0
fi
BWA_VERSION=0.7.17
BWA_VERSION=$(jetpack config BWA_VERSION)
HTSLIB_VERSION=1.9
HTSLIB_VERSION=$(jetpack config HTSLIB_VERSION)
SAMTOOLS_VERSION=1.9
SAMTOOLS_VERSION=$(jetpack config SAMTOOLS_VERSION)
SAMSERVER="https://sourceforge.net/projects/samtools/files/samtools"
GATK_VERSION=4.1.4.0
GATK_VERSION=$(jetpack config GATK_VERSION)

## Checking VM SKU and Cores
VMSKU=`cat /proc/cpuinfo | grep "model name" | head -1 | awk '{print $7}'`
CORES=$(grep cpu.cores /proc/cpuinfo | wc -l)

## Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

## directory setting
#mkdir -p ${APPSDIR}/gatk-${GATK_VERSION}
#chown -R ${CUSER}:${CUSER} ${APPSDIR}/gatk-${GATK_VERSION} | exit 0

# download gatk package
if [[ ! -d ${APPSDIR}/gatk-${GATK_VERSION} ]]; then
   wget -nv https://github.com/broadinstitute/gatk/releases/download/${GATK_VERSION}/gatk-${GATK_VERSION}.zip -O ${APPSDIR}/gatk-${GATK_VERSION}.zip
   chown ${CUSER}:${CUSER} ${APPSDIR}/gatk-${GATK_VERSION}.zip
   unzip ${APPSDIR}/gatk-${GATK_VERSION} -d ${APPSDIR} 
   chown -R ${CUSER}:${CUSER} ${APPSDIR}/gatk-${GATK_VERSION} | exit 0
fi

echo "end 50.gatk script"
