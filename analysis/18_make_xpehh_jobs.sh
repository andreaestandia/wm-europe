#!/usr/bin/env bash
#SBATCH --job-name=xpehh_raw
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
JOBFILE="${PATH_OUT}/xpehh_jobs.tsv"

mkdir -p "${PATH_OUT}/logs"

read -r QUERY REF CHR < <(sed -n "${SLURM_ARRAY_TASK_ID}p" "$JOBFILE")

sample_file_for() {
    case "$1" in
        uk)       echo "${PATH_RES}/list_uk_vcf" ;;
        shetland) echo "${PATH_RES}/list_shetland_vcf" ;;
        norway)   echo "${PATH_RES}/list_norway_vcf" ;;
        spain)    echo "${PATH_RES}/list_spain_vcf" ;;
        *)
            echo "Unknown group: $1" >&2
            exit 1
            ;;
    esac
}

QUERY_LIST="$(sample_file_for "$QUERY")"
REF_LIST="$(sample_file_for "$REF")"

TASK_DIR="${PATH_OUT}/xpehh/raw/${QUERY}_vs_${REF}/${CHR}"
mkdir -p "$TASK_DIR"

QUERY_VCF="${TASK_DIR}/${QUERY}_${CHR}.vcf.gz"
REF_VCF="${TASK_DIR}/${REF}_${CHR}.vcf.gz"
OUTBASE="${TASK_DIR}/${QUERY}_vs_${REF}_${CHR}_xpehh"
MAPFILE="${TASK_DIR}/${QUERY}_${CHR}.map"

if [[ ! -s "$QUERY_VCF" ]]; then
    bcftools view -r "$CHR" -S "$QUERY_LIST" -Oz -o "$QUERY_VCF" "$VCF"
    tabix -p vcf "$QUERY_VCF"
fi

if [[ ! -s "$REF_VCF" ]]; then
    bcftools view -r "$CHR" -S "$REF_LIST" -Oz -o "$REF_VCF" "$VCF"
    tabix -p vcf "$REF_VCF"
fi

if [[ ! -s "$MAPFILE" ]]; then
    bcftools query -f '%CHROM\t%POS\t%POS\t%POS\n' "$QUERY_VCF" > "$MAPFILE"
fi

"${PATH_SELSCAN}" \
    --xpehh \
    --vcf "$QUERY_VCF" \
    --vcf-ref "$REF_VCF" \
    --map "$MAPFILE" \
    --out "$OUTBASE" \
    --threads "${SLURM_CPUS_PER_TASK:-1}"