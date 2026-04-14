#!/usr/bin/env bash
set -euo pipefail

module load BCFtools/1.14-GCC-11.2.0

PATH_VCF="/data/biol-wm-europe/sjoh4959/data/genotype_calling"
PATH_OUT="/data/biol-wm-europe/sjoh4959/reports/selection"

VCF="${PATH_VCF}/wm_europe_biallelic_filtered_id_phased_brumata.vcf.gz"
JOBFILE="${PATH_OUT}/selscan_jobs.tsv"

mkdir -p "$PATH_OUT"

{
    while read -r chr; do
        printf "all\tnsl\t%s\n" "$chr"
        printf "all\tihs\t%s\n" "$chr"
        printf "uk\tnsl\t%s\n" "$chr"
        printf "uk\tihs\t%s\n" "$chr"
        printf "shetland\tnsl\t%s\n" "$chr"
        printf "shetland\tihs\t%s\n" "$chr"
        printf "norway\tnsl\t%s\n" "$chr"
        printf "norway\tihs\t%s\n" "$chr"
        printf "spain\tnsl\t%s\n" "$chr"
        printf "spain\tihs\t%s\n" "$chr"
    done < <(bcftools index -s "$VCF" | cut -f1)
} > "$JOBFILE"

echo "Wrote $JOBFILE"
wc -l "$JOBFILE"