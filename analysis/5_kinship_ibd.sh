#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00 
#SBATCH --job-name=ibd
#SBATCH --partition=long

#########################################################################################################

# Load plink1.9 module
ml PLINK/1.9b_6.21-x86_64

PATH_PLINK="/data/biol-wm-europe/sjoh4959/data/genotype_calling/"
PATH_SUBSETS="/data/biol-wm-europe/sjoh4959/data/resources/"
PATH_REPORTS="/data/biol-wm-europe/sjoh4959/reports/"

# Create directories for each analysis
mkdir -p ${PATH_REPORTS}/heterozygosity
mkdir -p ${PATH_REPORTS}/ibd
mkdir -p ${PATH_REPORTS}/kinship

cd $PATH_PLINK

# HETEROZYGOSITY
for pop in all uk_norway_shetland norway spain shetland uk; do
  if [ "$pop" = "all" ]; then
    KEEP_CMD=""
  else
    KEEP_CMD="--keep ${PATH_SUBSETS}list_${pop}"
  fi

  plink \
    --bfile wm_europe_biallelic_filtered_pruned \
    --het \
    --allow-extra-chr \
    --geno 0.05 \
    --mind 0.05 \
    --hwe 0.00001 \
    $KEEP_CMD \
    --out "${PATH_REPORTS}/heterozygosity/wm_europe_biallelic_filtered_${pop}"
done


# IBD / GENOME
for pop in all uk_norway_shetland spain shetland uk; do
  if [ "$pop" = "all" ]; then
    KEEP_CMD=""
  else
    KEEP_CMD="--keep ${PATH_SUBSETS}list_${pop}"
  fi

  plink \
    --bfile wm_europe_biallelic_filtered_pruned \
    --genome \
    --allow-extra-chr \
    --geno 0.05 \
    --hwe 0.00001 \
    --mind 0.05 \
    $KEEP_CMD \
    --out "${PATH_REPORTS}/ibd/wm_europe_biallelic_filtered_pruned_${pop}"
done


# Load plink2 module 
ml PLINK/2.00a2.3_x86_64

# KINSHIP (all samples only)
plink2 \
  --bfile wm_europe_biallelic_filtered_pruned \
  --make-king-table \
    --geno 0.05 \
    --mind 0.05 \
    --hwe 0.00001 \
  --out "${PATH_REPORTS}/kinship/wm_europe_biallelic_filtered"