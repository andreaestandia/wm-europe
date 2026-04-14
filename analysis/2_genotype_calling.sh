#!/bin/sh
#SBATCH --nodes=1
#SBATCH --time=48:00:00
#SBATCH --array=1-149:1
#SBATCH --job-name=picard
#SBATCH --output=picard.%A_%a.out
#SBATCH --error=picard.%A_%a.error

#########################################################################################################

#Load picard
ml picard/3.0.0-Java-17

Sample_List=/data/biol-wm-europe/sjoh4959/data/resources/list_dir

# STEP 2:
# Use slurm array task ID to alocate sample name and directory
SAMPLE_NAME=$(cat $Sample_List | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk {'print $1}')
SAMPLE_DIRECTORY=$(cat $Sample_List | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk {'print $2}')

# STEP 3:
#move into sample directory
cd $SAMPLE_DIRECTORY

# Set path to list of bam files (bam.list)
REF=/data/biol-wm/sjoh4959/0.0_winter-moth/data/ref_genome/GCA_932527175.1/GCA_932527175.1_ilOpeBrum1.1_genomic.fna
PATH_OUT=/data/biol-wm-europe/sjoh4959/data/genotype_calling/

#snp calling based on a list of paths to the sorted BAM files
java -jar $EBROOTPICARD/picard.jar MarkDuplicates I=${SAMPLE_NAME}.sorted.bam O=${SAMPLE_NAME}_dedup.sorted.bam M=${SAMPLE_NAME}_dedup_metrics.txt REMOVE_DUPLICATES=TRUE CREATE_INDEX=true

(base) [sjoh4959@arc-login01 analysis]$   more 2_genotype_calling.sh 
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=13-10:00:00 
#SBATCH --job-name=gt_call
#SBATCH --partition=long

#########################################################################################################

#Load samtools and bcftools module
ml SAMtools/1.16.1-GCC-11.3.0
ml BCFtools/1.14-GCC-11.2.0
ml PLINK/2.00a2.3_x86_64

# Set path to reference assembly and list of bam files (bam.list)
# Note: bam files need to be indexed (using samtools index) 
REF=/data/biol-wm-europe/ref_genome/GCA_932527175.1_ilOpeBrum1.1_genomic_renamed.fna
BAMs=/data/biol-wm-europe/sjoh4959/data/resources/list_bam
PATH_OUT=/data/biol-wm-europe/sjoh4959/data/genotype_calling/

#snp calling based on a list of paths to the sorted BAM files
bcftools mpileup -Ou -f $REF -b $BAMs | \
bcftools call -mv -Ob -o "${PATH_OUT}wm_europe.bcf"

#bcf to vcf
bcftools view -Ov -o "${PATH_OUT}wm_europe.vcf" "${PATH_OUT}wm_europe.bcf"
bcftools view --max-alleles 2 --exclude-types indels "${PATH_OUT}wm_europe.vcf" > "${PATH_OUT}wm_europe_biallelic.vcf"

#filter

bcftools view -e 'QUAL <= 10 || DP > 6000 || DP < 500' "${PATH_OUT}wm_europe_biallelic.vcf" > "${PATH_OUT}wm_europe_biallelic_filtered.vcf"
awk 'BEGIN{FS=OFS="\t"} /^#/ {print; next} {$3=$1"_"$2; print}' "${PATH_OUT}wm_europe_biallelic_filtered.vcf" > "${PATH_OUT}wm_europe_biallelic_filtered_id.vcf"

PATH_VCF="/data/biol-wm-europe/sjoh4959/data/genotype_calling/"
REMOVE_FILE="/data/biol-wm-europe/sjoh4959/data/resources/remove_fagata.txt"
INPUT_VCF="${PATH_VCF}wm_europe_biallelic_filtered_id.vcf"
OUTPUT_VCF="${PATH_VCF}wm_europe_biallelic_filtered_id_brumata.vcf"

bcftools view -S "^${REMOVE_FILE}" -Ov -o "$OUTPUT_VCF" "$INPUT_VCF"

plink2 --vcf "${PATH_OUT}wm_europe_biallelic_filtered_id_brumata.vcf" --make-bed --out "${PATH_OUT}wm_europe_biallelic_filtered_brumata"