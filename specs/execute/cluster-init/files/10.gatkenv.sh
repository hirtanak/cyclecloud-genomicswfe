#!/bin/bash

CONDA_ENVNAME=${1:-'gatk4'}
CONDA_INSTALLER=Miniconda3-latest-Linux-x86_64.sh
CONDA_DOWNLOAD_URL=https://repo.anaconda.com/miniconda/${CONDA_INSTALLER}

GATK_VERSION="4.1.4.0"
GATK_TARBALL="gatk-${GATK4_VERSION}.zip"
GATK_DOWNLOAD_BASEURL="https://github.com/broadinstitute/gatk/releases/download"
GATK_DOWNLOAD_URL="${GATK4_DOWNLOAD_BASEURL}/${GATK_VERSION}/${GATK_TARBALL}"
GATK_REQUIRES="matplotlib pandas bleach patsy pysam pymc3 tqdm"
GATK_PACKAGES="gatk4=${GATK_VERSION} pyvcf keras scikit-learn theano bwa samtools htslib"

[ -f ${HOME}/${CONDA_INSTALLER} ] || {
    wget -O ${HOME}/${CONDA_INSTALLER} ${CONDA_DOWNLOAD_URL}
}

[ -d ${HOME}/conda ] || {
  bash ${CONDA_INSTALLER} -b -p ${HOME}/conda
}

export PATH=${HOME}/conda/condabin:${PATH}

[ -f ${HOME}/${GATK_TARBALL} ] || {
    pushd ${HOME}
    wget -nv ${GATK_DOWNLOAD_URL}
    unzip ${GATK_TARBALL} 
    popd
}

[ -d ${HOME}/conda/envs/${CONDA_ENVNAME} ] || {
    source $HOME/conda/etc/profile.d/conda.sh
    conda create -y -n ${CONDA_ENVNAME} python=3.6 pip
    conda activate ${CONDA_ENVNAME}
    conda install -y -c bioconda ${GATK_PACKAGES} ${GATK_REQUIRES}
    pip install ${HOME}/gatk-${GATK_VERSION}/gatkPythonPackageArchive.zip 
    conda deactivate
}
