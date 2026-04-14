#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00 
#SBATCH --job-name=pca
#SBATCH --partition=long

#########################################################################################################

# Load plink1.9 module
ml PLINK/1.9b_6.21-x86_64

PATH_PLINK="/data/biol-wm-europe/sjoh4959/data/genotype_calling/"
PATH_SUBSETS="/data/biol-wm-europe/sjoh4959/data/resources/"
PATH_REPORTS="/data/biol-wm-europe/sjoh4959/reports/"

# Create directories for each analysis
mkdir -p ${PATH_REPORTS}/roh

cd $PATH_PLINK

# ROH / runs of homozygosity
plink \
  --bfile wm_europe_biallelic_filtered \
  --geno 0.05 \
  --mind 0.05 \
  --hwe 0.00001 \
  --homozyg \
  --out "${PATH_REPORTS}/roh/wm_europe_biallelic_filtered_all"

# IBC
for pop in all uk_norway_shetland norway spain shetland uk; do
  OUT_PREFIX="${PATH_REPORTS}/roh/wm_europe_ibc_${pop}"

  if [ "$pop" = "all" ]; then
    KEEP_CMD=()
  else
    KEEP_FILE="${PATH_SUBSETS}/list_${pop}"
    if [ ! -f "$KEEP_FILE" ]; then
      echo "ERROR: missing keep file: $KEEP_FILE" >&2
      exit 1
    fi
    KEEP_CMD=(--keep "$KEEP_FILE")
  fi

  plink \
    --bfile wm_europe_biallelic_filtered_pruned \
    --ibc \
    "${KEEP_CMD[@]}" \
    --out "$OUT_PREFIX"
done