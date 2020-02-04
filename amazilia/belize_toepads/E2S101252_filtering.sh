#!/bin/sh
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -N E2S101252_filtering
#$ -q omni
#$ -pe sm 12
#$ -P quanah
#$ -l h_rt=48:00:00
#$ -l h_vmem=8G


/lustre/work/jmanthey/bbmap/bbduk.sh \
in1=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_matching_reference/unfiltered/E2S101252/bCalAnn1.pri.cur.20181019bCalAnn1.pri.cur.20181019_E2S101252_R1.fastq.gz \
in2=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_matching_reference/unfiltered/E2S101252/bCalAnn1.pri.cur.20181019bCalAnn1.pri.cur.20181019_E2S101252_R2.fastq.gz \
out1=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_matching_reference/filtered/E2S101252/E2S101252_filtered_R1.fastq \
out2=/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_matching_reference/filtered/E2S101252/E2S101252_filtered_R2.fastq \
minlen=50 ftl=10 qtrim=rl trimq=10 ktrim=r k=25 mink=7 ref=/lustre/work/jmanthey/bbmap/resources/adapters.fa hdist=1 tbo tpe
