#!/usr/bin/env bash
set -euo pipefail

module load BCFtools/1.14-GCC-11.2.0

PATH_VCF="/data/biol-wm-europe/sjoh4959/data/genotype_calling"
PATH_OUT="/data/biol-wm-europe/sjoh4959/reports/selection"

VCF="${PATH_VCF}/wm_europe_biallelic_filtered_id_phased_brumata.vcf.gz"
JOBFILE="${PATH_OUT}/xpehh_jobs.tsv"

mkdir -p "$PATH_OUT"

groups=(uk shetland norway spain)

{
    while read -r chr; do
        for query in "${groups[@]}"; do
            for ref in "${groups[@]}"; do
                [[ "$query" == "$ref" ]] && continue
                printf "%s\t%s\t%s\n" "$query" "$ref" "$chr"
            done
        done
    done < <(bcftools index -s "$VCF" | cut -f1)
} > "$JOBFILE"

echo "Wrote $JOBFILE"
wc -l "$JOBFILE"