#!/bin/sh
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -N D2S10010_filtering
#$ -q omni
#$ -pe sm 12
#$ -P quanah
#$ -l h_rt=48:00:00
#$ -l h_vmem=8G



/lustre/work/jmanthey/bbmap/bbduk.sh \
in1=/lustre/scratch/johruska/amazilia/amazilia_belize/reads_matching_reference/unfiltered/D2S10010/bCalAnn1.pri.cur.20181019bCalAnn1.pri.cur.20181019_D2S10010_R1.fastq \
in2=/lustre/scratch/johruska/amazilia/amazilia_belize/reads_matching_reference/unfiltered/D2S10010/bCalAnn1.pri.cur.20181019bCalAnn1.pri.cur.20181019_D2S10010_R2.fastq \
out1=/lustre/scratch/johruska/amazilia_belize/reads_matching_reference/filtered/D2S10010/D2S10010_filtered_R1.fq \
out2=/lustre/scratch/johruska/amazilia_belize/reads_matching_reference/filtered/D2S10010/D2S10010_filtered_R2.fq \
minlen=50 ftl=10 qtrim=rl trimq=10 ktrim=r k=25 mink=7 ref=/lustre/work/jmanthey/bbmap/resources/adapters.fa hdist=1 tbo tpe
