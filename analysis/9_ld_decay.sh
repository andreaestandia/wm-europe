#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00
#SBATCH --job-name=ld_decay
#SBATCH --partition=long
#SBATCH --mem=50GB
#SBATCH --array=0-5
#SBATCH --output=%A_%a.out
#SBATCH --error=%%A_%a.err

set -euo pipefail

ml PLINK/1.9b_6.21-x86_64
ml Biopython/1.72-foss-2018b-Python-2.7.15

PATH_PY_SCRIPT="/data/biol-wm-europe/sjoh4959/src/"
PATH_PLINK="/data/biol-wm-europe/sjoh4959/data/genotype_calling/"
PATH_SUBSETS="/data/biol-wm-europe/sjoh4959/data/resources/"
PATH_OUT="/data/biol-wm-europe/sjoh4959/reports/ld_decay/"

mkdir -p "${PATH_OUT}/logs"
cd "$PATH_PLINK"

#POPS=("all" "uk_norway_shetland" "norway" "spain" "shetland" "uk")
POPS=("norway" "spain" "shetland" "uk")
POP="${POPS[$SLURM_ARRAY_TASK_ID]}"

if [ "$POP" = "all" ]; then
  KEEP_CMD=""
else
  KEEP_CMD="--keep ${PATH_SUBSETS}/list_${POP}"
fi

plink \
  --bfile wm_europe_biallelic_filtered \
  $KEEP_CMD \
  --maf 0.05 --geno 0.1 --mind 0.2 \
  --bp-space 100 \
  --r2 gz --ld-window 99999 --ld-window-kb 150 --ld-window-r2 0 \
  --out "${PATH_OUT}/wm_europe_biallelic_filtered_${POP}_lddecay_qc"

python2 "${PATH_PY_SCRIPT}ld_decay_calc.py" \
  -i "${PATH_OUT}/wm_europe_biallelic_filtered_${POP}_lddecay_qc.ld.gz" \
  -o "${PATH_OUT}/wm_europe_biallelic_filtered_${POP}_lddecay"