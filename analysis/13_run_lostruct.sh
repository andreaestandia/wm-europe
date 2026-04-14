#!/bin/bash
#SBATCH --job-name=lostruct
#SBATCH --output=/data/biol-wm-europe/sjoh4959/reports/local_pca/1000/lostruct_%j.out
#SBATCH --error=/data/biol-wm-europe/sjoh4959/reports/local_pca/1000/lostruct_%j.err
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G

ml BCFtools/1.14-GCC-11.2.0

set -euo pipefail

source /apps/system/easybuild/software/Miniconda3/23.1.0-1/etc/profile.d/conda.sh
conda activate /data/biol-wm-europe/sjoh4959/src/lostruct

unset PYTHONPATH
unset PYTHONHOME

export CONDA_PKGS_DIRS=/data/biol-wm-europe/sjoh4959/src/conda-pkgs
export TMPDIR=/data/biol-wm-europe/sjoh4959/src/tmp
export PIP_CACHE_DIR=/data/biol-wm-europe/sjoh4959/src/pip-cache

mkdir -p /data/biol-wm-europe/sjoh4959/reports/local_pca/100

#tabix /data/biol-wm-europe/sjoh4959/data/genotype_calling/wm_europe_biallelic_filtered_qc_vcf.gz

python run_lostruct.py \
  --vcf /data/biol-wm-europe/sjoh4959/data/genotype_calling/wm_europe_biallelic_filtered_qc_vcf.gz \
  --outdir /data/biol-wm-europe/sjoh4959/reports/local_pca/100 \
  --window-size 100