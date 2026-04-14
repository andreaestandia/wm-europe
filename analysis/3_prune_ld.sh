#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00 
#SBATCH --job-name=prune_ld
#SBATCH --partition=long

#########################################################################################################

#Load plink2 module
ml PLINK/2.00a2.3_x86_64

PATH_PLINK=/data/biol-wm-europe/sjoh4959/data/genotype_calling/

cd $PATH_PLINK

#Prune LD
plink2 --bfile wm_europe_biallelic_filtered --indep-pairwise 30 5 0.2 --allow-extra-chr --out wm_europe_biallelic_filtered_pruned
plink2 --bfile wm_europe_biallelic_filtered --extract wm_europe_biallelic_filtered_pruned.prune.in --make-bed --allow-extra-chr --chr-set 40 --out wm_europe_biallelic_filtered_pruned