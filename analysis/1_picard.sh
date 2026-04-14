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