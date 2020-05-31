#!/bin/bash
# Copyright (c) 2020 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "start 70.fastqc script"

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
SPARK_VERSION=2.4.4
SPARK_VERSION=$(jetpack config SPARK_VERSION)
FASTQC_VERSION=0.11.8
FASTQC_VERSION=$(jetpack config FASTQC_VERSION)

## Checking VM SKU and Cores
VMSKU=`cat /proc/cpuinfo | grep "model name" | head -1 | awk '{print $7}'`
CORES=$(grep cpu.cores /proc/cpuinfo | wc -l)

## Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

# download spark
if [[ ! -d ${APPSDIR}/FastQC ]]; then
   wget -nv https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${FASTQC_VERSION}.zip -O ${APPSDIR}/fastqc_v${FASTQC_VERSION}.zip
   chown ${CUSER}:${CUSER} ${APPSDIR}/fastqc_v${FASTQC_VERSION}.zip
   unzip ${APPSDIR}/fastqc_v${FASTQC_VERSION}.zip -d ${APPSDIR}
   tar zxfp ${APPSDIR}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz -C ${APPSDIR}
   chown -R ${CUSER}:${CUSER} ${APPSDIR}/FastQC | exit 0
fi

# .bashrc setting
set +u
echo "export JAVA_HOME=$(readlink -e $(which java)|sed 's:/bin/java::')" > /etc/profile.d/java.sh
CMD=$(grep gatk ${HOMEDIR}/.bashrc) | exit 0
if [[ "${CMD}" == "" ]]; then
   (echo "export PATH=$PATH:\${JAVA_HOME}/bin:${APPSDIR}/bwa-${BWA_VERSION}:${APPSDIR}/htslib-${HTSLIB_VERSION}/bin:${APPSDIR}/samtools-${SAMTOOLS_VERSION}/bin:${APPSDIR}/gatk-${GATK_VERSION}:${APPSDIR}/spark-${SPARK_VERSION}-bin-hadoop2.7/bin:${APPSDIR}/FastQC") >> ${HOMEDIR}/.bashrc
   chown ${CUSER}:${CUSER} ${HOMEDIR}/.bashrc | exit 0
fi
set -u


echo "end 70.fastqc script"
