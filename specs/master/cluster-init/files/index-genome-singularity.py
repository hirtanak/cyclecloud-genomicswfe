"""
This script downloads and indexes useful information
"""

__author__ = 'Yosvany Lopez Alvarez'
__copyright__ = 'Copyright 2019, Genesis Healthcare Co.'

import argparse
import sys
import os


def main(args):

    data_dir = args.data_dir
    genome_dir = args.genome_dir

    server = "ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg19/"

    data_files = os.listdir(data_dir)
    [os.system("gunzip " + data_dir + "/" + data_file) for data_file in data_files]

    genome_file = genome_dir + "/" + os.listdir(genome_dir)[0]
    os.system("gunzip " + genome_file)

    genome_sequence = genome_file.replace(".gz", "")

    docker_cmd = ["docker run --rm -u $(id -u):$(id -g)",
                  "-v", os.path.dirname(genome_sequence) + ":" + os.path.dirname(genome_sequence)]

    # index reference genome sequence with bwa
    create_gindex = docker_cmd + ["comics/bwa bwa index", "-p", genome_sequence.replace(".fasta", ""),
                                  "-a bwtsw", genome_sequence]
    os.system(" ".join(create_gindex))

    # index reference genome sequence with samtools
    create_st_idx = docker_cmd + ["comics/samtools", "samtools faidx", genome_sequence]
    os.system(" ".join(create_st_idx))

    # create dictionary of the genome sequence
    create_gdict = docker_cmd + ["broadinstitute/gatk", "java -jar gatk.jar CreateSequenceDictionary",
                                 "--REFERENCE", genome_sequence,
                                 "--OUTPUT", genome_sequence.replace(".fasta", "") + ".dict"]
    os.system(" ".join(create_gdict))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Downloading and indexation of useful information")
    parser.add_argument("-d", type=str, required=True, dest="data_dir", help="output directory for data files")
    parser.add_argument("-g", type=str, required=True, dest="genome_dir", help="output directory for genome sequence")

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    main(parser.parse_args())
