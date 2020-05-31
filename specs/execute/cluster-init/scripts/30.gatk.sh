#!/usr/bin/bash

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/} 
CUSER=${CUSER//\`/}
echo ${CUSER} > /mnt/exports/shared/CUSER
HOMEDIR=/shared/home/${CUSER}
APPSDIR=/shared/home/${CUSER}/apps

CONDA_ENVNAME=${1:-'gatk'}
CONDA_INSTALLER=Miniconda3-latest-Linux-x86_64.sh
CONDA_DOWNLOAD_URL=https://repo.anaconda.com/miniconda/${CONDA_INSTALLER}

GATK_VERSION="4.1.4.0"
GATK_VERSION=$(jetpack config GATK_VERSION)
GATK_TARBALL="gatk-${GATK_VERSION}.zip"
GATK_DOWNLOAD_BASEURL="https://github.com/broadinstitute/gatk/releases/download"
GATK_DOWNLOAD_URL="${GATK_DOWNLOAD_BASEURL}/${GATK_VERSION}/${GATK_TARBALL}"
GATK_REQUIRES="matplotlib pandas bleach patsy pysam pymc3 tqdm"
GATK_PACKAGES="gatk4=${GATK_VERSION} pyvcf keras scikit-learn theano bwa samtools htslib"

#export PATH=${HOMEDIR}/conda/condabin:${PATH}

#if [[ ! -d ${HOMEDIR}/conda/envs/${CONDA_ENVNAME} ]]; then
#    source ${HOMEDIR}/conda/etc/profile.d/conda.sh
#    sudo -u ${CUSER} conda create -y -n ${CONDA_ENVNAME} python=3.6 pip
#    sudo -u ${CUSER} conda init bash
#    sudo -u ${CUSER} conda activate ${CONDA_ENVNAME}
#    sudo -u ${CUSER} conda install -y -c bioconda ${GATK_PACKAGES} ${GATK_REQUIRES}
#    sudo -u ${CUSER} pip install --user ${APPSDIR}/gatk-${GATK_VERSION}/gatkPythonPackageArchive.zip
#    sudo -u ${CUSER} conda deactivate
#fi

