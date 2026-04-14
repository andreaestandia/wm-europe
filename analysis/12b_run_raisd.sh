#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00
#SBATCH --job-name=raisd
#SBATCH --partition=long
#SBATCH --array=1-4

ml BCFtools/1.14-GCC-11.2.0
ml R/4.2.2-foss-2022a-ARC
ml RAiSD/2025

OUTDIR="/data/biol-wm-europe/sjoh4959/reports/raisd"
mkdir -p "$OUTDIR"

pops=(norway shetland uk spain)
pop="${pops[$SLURM_ARRAY_TASK_ID]}"

VCF="/data/biol-wm-europe/sjoh4959/data/genotype_calling/vcf_pops/wm_europe_${pop}.vcf"

(
  cd "$OUTDIR" || exit 1
  RAiSD -n "wm_${pop}" -I "$VCF" -f
)