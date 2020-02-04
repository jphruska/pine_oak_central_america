#!/bin/sh
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -N amazilia_E2_extract
#$ -q omni
#$ -pe sm 12
#$ -P quanah
#$ -l h_rt=48:00:00
#$ -l h_vmem=12G


module load intel java

/lustre/work/jmanthey/bbmap/bbsplit.sh \
in1=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/raw/E2S101252_S4_L002_R1_001.fastq.gz \
in2=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/raw/E2S101252_S4_L002_R2_001.fastq.gz \
ref=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_ref/bCalAnn1.pri.cur.20181019.fasta \
basename=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_matching_reference/E2S101252/bCalAnn1.pri.cur.20181019%.fastq.gz \
outu1=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_not_matching_reference/E2S101252/E2S101252_R1.fastq \
outu2=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_not_matching_reference/E2S101252/E2S101252_R2.fastq
