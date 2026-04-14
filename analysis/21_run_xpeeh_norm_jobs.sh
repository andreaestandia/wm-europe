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
(base) [sjoh4959@arc-login01 analysis]$ more 22_run_xpehh.sh 
#!/usr/bin/env bash
set -euo pipefail

PATH_OUT="/data/biol-wm-europe/sjoh4959/reports/selection"

mkdir -p "${PATH_OUT}/logs"

bash 18_prep_xpehh_jobs.sh
RAW_N=$(wc -l < "${PATH_OUT}/xpehh_jobs.tsv")
if [[ "$RAW_N" -lt 1 ]]; then
    echo "No raw jobs were written" >&2
    exit 1
fi

RAW_JOBID=$(sbatch --parsable --array=1-"$RAW_N" 19_make_xpehh_jobs.sh)

bash 20_prep_xpehh_norm_jobs.sh
NORM_N=$(wc -l < "${PATH_OUT}/xpehh_norm_jobs.tsv")
if [[ "$NORM_N" -lt 1 ]]; then
    echo "No norm jobs were written" >&2
    exit 1
fi

sbatch --dependency=afterok:"$RAW_JOBID" --array=1-"$NORM_N" 21_make_xpehh_norm_jobs.sh