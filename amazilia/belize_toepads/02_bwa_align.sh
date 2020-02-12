#!/bin/sh
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -N amazilia_belize_bwa_align
#$ -q omni
#$ -pe sm 24
#$ -P quanah
#$ -l h_rt=48:00:00
#$ -l h_vmem=8G
#$ -t 1-3

module load intel java bwa samtools

bwa mem -t 6 /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_ref/bCalAnn1.pri.cur.20181019.fasta /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_for_bwa/${SGE_TASK_ID}_R1.fastq.gz /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/reads_for_bwa/${SGE_TASK_ID}_R2.fastq.gz > /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}.sam

samtools view -b -S -o /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}.bam /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}.sam

rm /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}.sam

/lustre/work/jmanthey/gatk-4.0.2.1/gatk CleanSam -I /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}.bam -O /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_cleaned.bam

rm /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}.bam

/lustre/work/jmanthey/gatk-4.0.2.1/gatk SortSam -I /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_cleaned.bam -O /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_cleaned_sorted.bam --SORT_ORDER coordinate

rm /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_cleaned.bam

/lustre/work/jmanthey/gatk-4.0.2.1/gatk AddOrReplaceReadGroups -I /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_cleaned_sorted.bam -O /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_cleaned_sorted_rg.bam --RGLB 1 --RGPL illumina --RGPU unit1 --RGSM ${SGE_TASK_ID}

rm /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_cleaned_sorted.bam

/lustre/work/jmanthey/gatk-4.0.2.1/gatk MarkDuplicates --REMOVE_DUPLICATES true --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 100 -M /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_markdups_metric_file.txt -I /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_cleaned_sorted_rg.bam -O /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_final.bam

rm /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_cleaned_sorted_rg.bam

samtools index /lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_belize/bams/${SGE_TASK_ID}_final.bam












