#!/bin/sh
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -N geothlypis_clean_bwa_align
#$ -q omni
#$ -pe sm 6
#$ -P quanah
#$ -l h_rt=48:00:00
#$ -l h_vmem=32G
#$ -t 16-20

module load intel java bwa samtools

/lustre/work/jmanthey/bbmap/bbduk.sh in1=/lustre/scratch/johruska/central_america_pine_oak/renamed_raw_fastq/${SGE_TASK_ID}_R1.fastq.gz in2=/lustre/scratch/johruska/central_america_pine_oak/renamed_raw_fastq/${SGE_TASK_ID}_R2.fastq.gz out1=/lustre/scratch/johruska/central_america_pine_oak/troglodytes_clean/${SGE_TASK_ID}_R1.fastq.gz out2=/lustre/scratch/johruska/central_america_pine_oak/troglodytes_clean/${SGE_TASK_ID}_R2.fastq.gz minlen=50 ftl=10 qtrim=rl trimq=10 ktrim=r k=25 mink=7 ref=/lustre/work/jmanthey/bbmap/resources/adapters.fa hdist=1 tbo tpe

bwa mem -t 6 /lustre/scratch/johruska/central_america_pine_oak/passer_ref/GCA_003957565.2_bTaeGut1_v1.p_genomic.fasta /lustre/scratch/johruska/central_america_pine_oak/troglodytes_clean/${SGE_TASK_ID}_R1.fastq.gz /lustre/scratch/johruska/central_america_pine_oak/troglodytes_clean/${SGE_TASK_ID}_R2.fastq.gz > /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}.sam

samtools view -b -S -o /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}.bam /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}.sam

rm /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}.sam

/lustre/work/jmanthey/gatk-4.0.2.1/gatk CleanSam -I /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}.bam -O /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_cleaned.bam

rm /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}.bam

/lustre/work/jmanthey/gatk-4.0.2.1/gatk SortSam -I /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_cleaned.bam -O /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_cleaned_sorted.bam --SORT_ORDER coordinate

rm /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_cleaned.bam

/lustre/work/jmanthey/gatk-4.0.2.1/gatk AddOrReplaceReadGroups -I /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_cleaned_sorted.bam -O /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_cleaned_sorted_rg.bam --RGLB 1 --RGPL illumina --RGPU unit1 --RGSM ${SGE_TASK_ID}

rm /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_cleaned_sorted.bam

/lustre/work/jmanthey/gatk-4.0.2.1/gatk MarkDuplicates --REMOVE_DUPLICATES true --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 100 -M /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_markdups_metric_file.txt -I /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_cleaned_sorted_rg.bam -O /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_final.bam

rm /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_cleaned_sorted_rg.bam

samtools index /lustre/scratch/johruska/central_america_pine_oak/troglodytes_bam/${SGE_TASK_ID}_final.bam
