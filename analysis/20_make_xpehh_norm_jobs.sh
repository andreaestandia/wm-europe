#!/usr/bin/env bash
#SBATCH --job-name=xpehh_norm
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=/data/biol-wm-europe/sjoh4959/reports/selection/logs/%x_%A_%a.out
#SBATCH --error=/data/biol-wm-europe/sjoh4959/reports/selection/logs/%x_%A_%a.err

set -euo pipefail

PATH_SELSCAN="/data/biol-wm-europe/sjoh4959/src/selscan/src/selscan"
PATH_OUT="/data/biol-wm-europe/sjoh4959/reports/selection"
JOBFILE="${PATH_OUT}/xpehh_norm_jobs.tsv"

mkdir -p "${PATH_OUT}/logs"

read -r QUERY REF < <(sed -n "${SLURM_ARRAY_TASK_ID}p" "$JOBFILE")

PAIR_DIR="${PATH_OUT}/xpehh/raw/${QUERY}_vs_${REF}"
shopt -s nullglob

FILES=( "${PAIR_DIR}"/*/*.xpehh.out )

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No raw xpehh files found in ${PAIR_DIR}" >&2
    exit 1
fi

"${PATH_SELSCAN}" norm \
    --xpehh \
    --files "${FILES[@]}"