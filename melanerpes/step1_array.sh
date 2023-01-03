#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=step1
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-276

module load singularity

chr_array=$( head -n${SLURM_ARRAY_TASK_ID} helper1.txt | tail -n1 )

ind_array=$( head -n${SLURM_ARRAY_TASK_ID} helper2.txt | tail -n1 )

name_array=$( head -n${SLURM_ARRAY_TASK_ID} helper1b.txt | tail -n1 )

export SINGULARITY_CACHEDIR="/lustre/work/johruska/singularity-cachedir"

singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk --java-options "-Xmx58g" HaplotypeCaller -R /lustre/scratch/johruska/central_america_pine_oak/melanerpes_ref/c05_colaptes_arcs3.FINAL.reordered.fasta -I /lustre/scratch/johruska/central_america_pine_oak/melanerpes/01_bam_files/${ind_array}_final.bam -ERC GVCF -O /lustre/scratch/johruska/central_america_pine_oak/melanerpes/02_vcf/${name_array}._${ind_array}_.g.vcf --QUIET --intervals ${chr_array}
