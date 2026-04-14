#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00 
#SBATCH --job-name=pca
#SBATCH --partition=long

#########################################################################################################

#Load plink2 module
ml PLINK/2.00a2.3_x86_64

PATH_PLINK="/data/biol-wm-europe/sjoh4959/data/genotype_calling"
PATH_SUBSETS="/data/biol-wm-europe/sjoh4959/data/resources"
PATH_OUT="/data/biol-wm-europe/sjoh4959/reports/pca"

mkdir -p "$PATH_OUT"
cd "$PATH_PLINK"

BASE="wm_europe_biallelic_filtered_pruned"
OUT_PREFIX="${PATH_OUT}/${BASE}_fagata"

# Run PCA for each subset using the same frequency file
  plink2 \
    --bfile "$BASE" \
    --allow-extra-chr \
    --chr-set 40 \
    --geno 0.05 \
    --maf 0.05 \
    --pca \
    --out "$OUT_PREFIX"