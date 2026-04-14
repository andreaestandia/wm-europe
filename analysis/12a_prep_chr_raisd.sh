#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00 
#SBATCH --job-name=raisd
#SBATCH --partition=long

#########################################################################################################

ml  BCFtools/1.14-GCC-11.2.0
ml R/4.2.2-foss-2022a-ARC
ml RAiSD/2025

VCF="/data/biol-wm-europe/sjoh4959/data/genotype_calling/wm_europe_biallelic_filtered_id_brumata.vcf"
LISTDIR="/data/biol-wm-europe/sjoh4959/data/resources"
OUTDIR="/data/biol-wm-europe/sjoh4959/data/genotype_calling/vcf_pops"

mkdir -p "$OUTDIR"

for pop in norway shetland uk spain; do
    SAMPLES="${LISTDIR}/list_${pop}_vcf"
    OUTVCF="${OUTDIR}/wm_europe_${pop}.vcf.gz"

    bcftools view -S ^"$SAMPLES" -Oz -o "$OUTVCF" "$VCF"
    tabix -p vcf "$OUTVCF"
done

OUTDIR="/data/biol-wm-europe/sjoh4959/data/genotype_calling/vcf_pops"

for pop in norway shetland uk spain; do

    VCF_GZ="${OUTDIR}/wm_europe_${pop}.vcf.gz"
    VCF="${OUTDIR}/wm_europe_${pop}.vcf"

    # decompress only if .vcf does not exist
    if [ ! -f "$VCF" ]; then
        gunzip -c "$VCF_GZ" > "$VCF"
    fi

done