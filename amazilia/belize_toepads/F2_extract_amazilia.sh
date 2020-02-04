#!/bin/sh
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -N F2_extract_amazilia
#$ -q omni
#$ -pe sm 10
#$ -P quanah
#$ -l h_rt=48:00:00
#$ -l h_vmem=12G


module load intel java

/lustre/work/jmanthey/bbmap/bbsplit.sh \
in1=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/raw/F2S10268_S5_L002_R1_001.fastq.gz \
in2=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/raw/F2S10268_S5_L002_R2_001.fastq.gz \
ref=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_ref/bCalAnn1.pri.cur.20181019.fasta \
basename=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_matching_reference/F2S10268/bCalAnn1.pri.cur.20181019%.fastq.gz \
outu1=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_not_matching_reference/F2S10268/F2S10268_R1.fastq \
outu2=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_not_matching_reference/F2S10268/F2S10268_R2.fastq
