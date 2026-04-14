#!/usr/bin/env bash
set -euo pipefail

PATH_OUT="/data/biol-wm-europe/sjoh4959/reports/selection"
JOBFILE="${PATH_OUT}/selscan_jobs.tsv"

mkdir -p "${PATH_OUT}/logs"

bash 15_prep_selscans.sh

N=$(wc -l < "$JOBFILE")

if [[ "$N" -lt 1 ]]; then
    echo "No jobs were written to $JOBFILE" >&2
    exit 1
fi

sbatch --array=1-"$N" 16_make_selscan_jobs.sh