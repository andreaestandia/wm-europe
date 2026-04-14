#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00 
#SBATCH --job-name=pixy
#SBATCH --partition=long

#########################################################################################################

module load Anaconda3
source activate $DATA/pixy-env

DATA_DIR="/data/biol-wm-europe/sjoh4959/data"
RES_DIR="$DATA_DIR/resources"
OUT_DIR="/data/biol-wm-europe/sjoh4959/reports/pixy"

# Files
VCF="$DATA_DIR/genotype_calling/wm_europe_biallelic_filtered_id_brumata.vcf"
VCF_GZ="${VCF}.gz"
POPS="$RES_DIR/list_pops_pixy"

# Commands
#bgzip "$VCF"
#tabix "$VCF_GZ"

pixy --stats dxy \
  --vcf "$VCF_GZ" \
  --populations "$POPS" \
  --window_size 50000 \
  --n_cores 48 \
  --output_folder "$OUT_DIR" \
  --bypass_invariant_check yes