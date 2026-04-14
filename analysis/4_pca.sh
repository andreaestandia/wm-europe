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
FREQ_PREFIX="${PATH_OUT}/${BASE}_allfreq"

# Generate allele frequencies from the full dataset once
plink2 \
  --bfile "$BASE" \
  --allow-extra-chr \
  --chr-set 40 \
  --geno 0.05 \
  --mind 0.05 \
  --maf 0.05 \
  --freq \
  --out "$FREQ_PREFIX"

# Run PCA for each subset using the same frequency file
for i in all uk_norway_shetland uk norway spain shetland; do
  OUT_PREFIX="${PATH_OUT}/${BASE}_${i}"

  if [ "$i" = "all" ]; then
    KEEP_CMD=()
  else
    KEEP_FILE="${PATH_SUBSETS}/list_${i}"
    if [ ! -f "$KEEP_FILE" ]; then
      echo "ERROR: missing keep file: $KEEP_FILE" >&2
      exit 1
    fi
    KEEP_CMD=(--keep "$KEEP_FILE")
  fi

  plink2 \
    --bfile "$BASE" \
    --allow-extra-chr \
    --chr-set 40 \
    --geno 0.05 \
    --mind 0.05 \
    --maf 0.05 \
    --read-freq "${FREQ_PREFIX}.afreq" \
    "${KEEP_CMD[@]}" \
    --pca \
    --out "$OUT_PREFIX"
done

# PCA without chrZ
plink2 --bfile wm_filtered_biallelic_pruned \
       --keep list_subset \
       --pca \
       --geno 0.05 \
       --mind 0.05 \
       --maf 0.05 \
       --allow-extra-chr \
       --chr-set 40 \
       --not-chr chrZ \
       --out "${PATH_OUT}wm_europe_filtered_biallelic_pruned"