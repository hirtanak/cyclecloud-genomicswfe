#!/bin/bash
# Copyright (c) 2020 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "start 40.appinstallation script"

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

## Checking VM SKU and Cores
VMSKU=`cat /proc/cpuinfo | grep "model name" | head -1 | awk '{print $7}'`
CORES=$(grep cpu.cores /proc/cpuinfo | wc -l)

## Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

## environmental setting
(echo "export SVERSION=v3.3.0") > /etc/profile.d/software.sh

# rpm reiqured package
yum install -y git
# general requirement
yum install -y gcc gcc-c++
# samtool requirement
yum install -y autoconf automake make gcc perl-Data-Dumper zlib-devel bzip2 bzip2-devel xz-devel curl-devel openssl-devel ncurses-devel


# download BWA source
if [[ ! -f ${HOMEDIR}/apps/bwa-v${BWA_VERSION}.tar.gz ]]; then
   wget -nv https://github.com/lh3/bwa/archive/v${BWA_VERSION}.tar.gz -O ${HOMEDIR}/apps/bwa-v${BWA_VERSION}.tar.gz || wget https://github.com/lh3/bwa/archive/${BWA_VERSION}.tar.gz -O ${HOMEDIR}/apps/bwa-v${BWA_VERSION}.tar.gz
   chown ${CUSER}:${CUSER} ${HOMEDIR}/apps/bwa-v${BWA_VERSION}.tar.gz
fi
if [[ ! -f ${HOMEDIR}/apps/bwa ]]; then
   tar zxfp ${HOMEDIR}/apps/bwa-v${BWA_VERSION}.tar.gz -C ${HOMEDIR}/apps/
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/bwa-${BWA_VERSION}
fi
# compile BWA
if [[ ! -f ${HOMEDIR}/apps/bwa-${BWA_VERSION}/bwa ]]; then
   sudo -u ${CUSER} make -C ${HOMEDIR}/apps/bwa-${BWA_VERSION}
fi
 
# download htslib source https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2
if [[ ! -f ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}.tar.gz ]]; then
   wget -nv https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2  -O ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}.tar.bz2
   chown ${CUSER}:${CUSER} ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}.tar.bz2
   tar jxfp ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}.tar.bz2 -C ${HOMEDIR}/apps/
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}
fi
# compile and install htslib
if [[ ! -f ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}/bin/htsfile ]]; then
   # tips for compling
   chmod -R 764 ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}/config*
   cd ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION} && sudo -u ${CUSER} autoheader
   cd ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION} && sudo -u ${CUSER} autoconf
   sudo -u ${CUSER} ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}/configure --prefix=${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}
   sudo -u ${CUSER} make -C ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION}
   make install
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/htslib-${HTSLIB_VERSION} | exit 0
fi

# download samtools source
if [[ ! -f ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION}.tar.bz2 ]]; then
   wget -nv ${SAMSERVER}/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 -O ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION}.tar.bz2
   chown ${CUSER}:${CUSER} ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION}.tar.bz2
   tar jxfp ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION}.tar.bz2 -C ${HOMEDIR}/apps/ | exit 0   
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION} | exit 0
fi

# compile and install SAMTOOLS
if [[ ! -d ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION}/bin/samtools ]]; then
   cd ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION} && sudo -u ${CUSER} ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION}/configure --prefix=${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION}
   sudo -u ${CUSER} make -C ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION}
   sudo -u ${CUSER} make install
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/samtools-${SAMTOOLS_VERSION} | exit 0
fi

# file settings
chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps | exit 0
cp /opt/cycle/jetpack/logs/cluster-init/genomicswfe/master/scripts/40.appinstallation.sh.out  ${HOMEDIR}/logs/ | exit 0
chown ${CUSER}:${CUSER} ${HOMEDIR}/logs/40.appinstallation.sh.out | exit 0


echo "end of 40.appinstallation.sh script"
