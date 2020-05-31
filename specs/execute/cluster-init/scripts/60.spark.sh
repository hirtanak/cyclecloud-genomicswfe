#!/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "start 60.spark script"

# https://github.com/broadinstitute/gatk/releases/download/4.1.3.0/gatk-4.1.3.0.zip

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
HOMEDIR=/shared/home/${CUSER}
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
GATK_VERSION=4.1.3.0
#GATK_VERSION=$(jetpack config cromwell.version)
SPARK_VERSION=2.4.4
SPARK_VERSION=$(jetpack config SPARK_VERSION)

## Checking VM SKU and Cores
VMSKU=`cat /proc/cpuinfo | grep "model name" | head -1 | awk '{print $7}'`
CORES=$(grep cpu.cores /proc/cpuinfo | wc -l)

## Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

# download spark
if [[ ! -d ${APPSDIR}/spark-${SPARK_VERSION}-bin-hadoop2.7 ]]; then
   wget -nv http://ftp.riken.jp/net/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz -O ${APPSDIR}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz
   chown ${CUSER}:${CUSER} ${APPSDIR}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz
   tar zxfp ${APPSDIR}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz -C ${APPSDIR}
   chown -R ${CUSER}:${CUSER} ${APPSDIR}/spark-${SPARK_VERSION}-bin-hadoop2.7 | exit 0
fi

echo "end 60.spark script"
