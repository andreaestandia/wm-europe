#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00 
#SBATCH --job-name=phasing
#SBATCH --mem=100G
#SBATCH --partition=long

#########################################################################################################

#Load vcftools module
ml Beagle/5.4.22Jul22.46e-Java-11
ml VCFtools/0.1.16-GCC-11.2.0
ml PLINK/1.9b_6.21-x86_64
ml BCFtools/1.14-GCC-11.2.0

PATH_VCF="/data/biol-wm-europe/sjoh4959/data/genotype_calling/"
REMOVE_FILE="/data/biol-wm-europe/sjoh4959/data/resources/remove_fagata.txt"
INPUT_VCF="${PATH_VCF}wm_europe_biallelic_filtered_id_phased.vcf.gz"
OUTPUT_VCF="${PATH_VCF}wm_europe_biallelic_filtered_id_phased_brumata.vcf"

#java -jar ${EBROOTBEAGLE}/beagle.jar \
#	gt="${PATH_VCF}wm_europe_biallelic_filtered_id.vcf" \
#  	out="${PATH_VCF}wm_europe_biallelic_filtered_id_phased"

tabix -p vcf "$INPUT_VCF"
bcftools view -S "^${REMOVE_FILE}" -Ov -o "$OUTPUT_VCF" "$INPUT_VCF"
