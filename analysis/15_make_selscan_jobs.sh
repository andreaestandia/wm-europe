#!/usr/bin/env bash
#SBATCH --job-name=selscan
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --output=/data/biol-wm-europe/sjoh4959/reports/selection/logs/%x_%A_%a.out
#SBATCH --error=/data/biol-wm-europe/sjoh4959/reports/selection/logs/%x_%A_%a.err

set -euo pipefail

module load BCFtools/1.14-GCC-11.2.0

PATH_SELSCAN="/data/biol-wm-europe/sjoh4959/src/selscan/src/selscan"
PATH_VCF="/data/biol-wm-europe/sjoh4959/data/genotype_calling"
PATH_RES="/data/biol-wm-europe/sjoh4959/data/resources"
PATH_OUT="/data/biol-wm-europe/sjoh4959/reports/selection"

VCF="${PATH_VCF}/wm_europe_biallelic_filtered_id_phased_brumata.vcf.gz"
JOBFILE="${PATH_OUT}/selscan_jobs.tsv"

mkdir -p "${PATH_OUT}/logs"

read -r GROUP STAT CHR < <(sed -n "${SLURM_ARRAY_TASK_ID}p" "$JOBFILE")

sample_args=()
case "$GROUP" in
    all)
        ;;
    uk)
        sample_args=(-S "${PATH_RES}/list_uk_vcf")
        ;;
    shetland)
        sample_args=(-S "${PATH_RES}/list_shetland_vcf")
        ;;
    norway)
        sample_args=(-S "${PATH_RES}/list_norway_vcf")
        ;;
    spain)
        sample_args=(-S "${PATH_RES}/list_spain_vcf")
        ;;
    *)
        echo "Unknown group: $GROUP" >&2
        exit 1
        ;;
esac

TASK_DIR="${PATH_OUT}/${GROUP}/${STAT}/${CHR}"
mkdir -p "$TASK_DIR"

SUBSET_VCF="${TASK_DIR}/${GROUP}_${CHR}.vcf.gz"
OUTBASE="${TASK_DIR}/${GROUP}_${CHR}_${STAT}"

if [[ ! -s "$SUBSET_VCF" ]]; then
    bcftools view -r "$CHR" "${sample_args[@]}" -Oz -o "$SUBSET_VCF" "$VCF"
    tabix -p vcf "$SUBSET_VCF"
fi

if [[ "$STAT" == "nsl" ]]; then
    "${PATH_SELSCAN}" \
        --nsl \
        --vcf "$SUBSET_VCF" \
        --out "$OUTBASE" \
        --threads "${SLURM_CPUS_PER_TASK:-1}"

elif [[ "$STAT" == "ihs" ]]; then
    MAPFILE="${TASK_DIR}/${GROUP}_${CHR}.map"

    if [[ ! -s "$MAPFILE" ]]; then
        bcftools query -f '%CHROM\t%POS\t%POS\t%POS\n' "$SUBSET_VCF" > "$MAPFILE"
    fi

    "${PATH_SELSCAN}" \
        --ihs \
        --vcf "$SUBSET_VCF" \
        --map "$MAPFILE" \
        --out "$OUTBASE" \
        --threads "${SLURM_CPUS_PER_TASK:-1}"
else
    echo "Unknown stat: $STAT" >&2
    exit 1
fi