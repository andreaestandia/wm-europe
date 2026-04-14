#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00 
#SBATCH --job-name=taj_pi
#SBATCH --partition=long
#SBATCH --array=0-4

#########################################################################################################

#Load plink2 module
ml VCFtools/0.1.16-GCC-11.2.0

PATH_PLINK="/data/biol-wm-europe/sjoh4959/data/genotype_calling/"
PATH_OUT_TAJ="/data/biol-wm-europe/sjoh4959/reports/tajimasD/"
PATH_OUT_PI="/data/biol-wm-europe/sjoh4959/reports/pi/"
PATH_SUBSETS="/data/biol-wm-europe/sjoh4959/data/resources/"

mkdir -p $PATH_OUT_TAJ
mkdir -p $PATH_OUT_PI

cd "$PATH_PLINK"

POPS=(uk norway shetland spain)
POP="${POPS[$SLURM_ARRAY_TASK_ID]}"

if [ "$POP" = "all" ]; then
  KEEP_CMD=""
else
  KEEP_CMD="--keep ${PATH_SUBSETS}/list_${POP}_vcf"
fi

vcftools --vcf wm_europe_biallelic_filtered_id.vcf \
  $KEEP_CMD \
  --TajimaD 50000 \
  --out "${PATH_OUT_TAJ}${POP}_tajimasD_50kb"

vcftools --vcf wm_europe_biallelic_filtered_id.vcf \
  $KEEP_CMD \
  --window-pi 50000 \
  --out "${PATH_OUT_PI}${POP}_pi_50kb"

vcftools --vcf wm_europe_biallelic_filtered_id.vcf \
  $KEEP_CMD \
  --TajimaD 10000 \
  --out "${PATH_OUT_TAJ}${POP}_tajimasD_10kb"

vcftools --vcf wm_europe_biallelic_filtered_id.vcf \
  $KEEP_CMD \
  --window-pi 10000 \
  --out "${PATH_OUT_PI}${POP}_pi_10kb"