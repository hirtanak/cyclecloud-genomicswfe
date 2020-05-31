#!/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "start 20.singularity script"

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
HOMEDIR=/shared/home/${CUSER}
APPSDIR=/shared/home/${CUSER}/apps

## Singularity 
Singularity_VERSION=3.3.0
Singularity_VERSION=$(jetpack config singularity.version)
SVERSION=v${Singularity_VERSION}
GOPATH=/shared/home/${CUSER}/go

## 
MANUALCOMPILE=no

## Checking VM SKU and Cores
VMSKU=`cat /proc/cpuinfo | grep "model name" | head -1 | awk '{print $7}'`
CORES=$(grep cpu.cores /proc/cpuinfo | wc -l)

## Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

## environmental setting
(echo "export GOPATH=${HOMEDIR}/go"; echo "export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin"; echo "export SVERSION=v3.3.0") > /etc/profile.d/singularity

# rpm reiqured package
yum install -y squashfs-tools
# for compatiblity and dailiy use, set up docker as well.
# yum install -y docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce doc
#docker version

# download singularity rpm 
if [[ ! -f ${APPSDIR}/singularity-${Singularity_VERSION}-1.el7.x86_64.rpm ]]; then
   jetpack download "singularity-${Singularity_VERSION}-1.el7.x86_64.rpm" ${APPSDIR}
   chown ${CUSER}:${CUSER} ${APPSDIR}/singularity-${Singularity_VERSION}-1.el7.x86_64.rpm
fi
if [[ ! -f /bin/singularity ]]; then
   rpm -ivh ${APPSDIR}/singularity-${Singularity_VERSION}-1.el7.x86_64.rpm
fi

if [[ MANUALCOMPILE = yes ]]; then 
   ## Singularity require
   yum groupinstall -y 'Development Tools'
   yum install -y epel-release openssl-devel libuuid-devel libseccomp-devel squashfs-tools golang

   # mkdir -p ${GOPATH}/src/github.com/sylabs | exit 0
   #cd ${GOPATH}/src/github.com/sylabs
   #if [[ ! -d ${GOPATH}/src/github.com/sylabs/singularity ]]; then
   #   git clone https://github.com/sylabs/singularity.git ${GOPATH}/src/github.com/sylabs/singularity
   #fi
   #cd ${GOPATH}/src/github.com/sylabs/singularity
   #git checkout ${SVERSION}

   #if [[ ! -d ${GOPATH}/src/github.com/golang/dep/cmd/dep ]]; then
   #   go get -u -v ${GOPATH}/src/github.com/golang/dep/cmd/dep
   #   ./mconfig
   #   make -C builddir
   #   make -C builddir install
   #fi
fi 

echo "end 20.singularity script"
