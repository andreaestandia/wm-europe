#!/bin/bash
#SBATCH --nodes=1
#SBATCH --clusters=arc
#SBATCH --ntasks-per-node=1
#SBATCH --time=2-10:00:00 
#SBATCH --job-name=admixture
#SBATCH --partition=long
#SBATCH --mem=100GB
#SBATCH --array=1-10



#########################################################################################################

# Load plink2 module
ml PLINK/2.00a2.3_x86_64
ml ADMIXTURE/1.3.0

PATH_PLINK=/data/biol-wm-europe/sjoh4959/data/genotype_calling/
PATH_ADMIX=/data/biol-wm-europe/sjoh4959/reports/admixture/

cd $PATH_PLINK

plink2 \
    --vcf wm_europe_biallelic_filtered_id_phased_brumata.vcf \
    --make-bed --out wm_europe_biallelic_filtered_id_phased \
    --allow-extra-chr

mv wm_europe_biallelic_filtered_id_phased.bed \
   wm_europe_biallelic_filtered_id_phased.bim \
   wm_europe_biallelic_filtered_id_phased.fam \
   "$PATH_ADMIX"/

cd $PATH_ADMIX 

# declare name of file so we don't need to repeat it constantly
FILE=wm_europe_biallelic_filtered_id_phased

# ADMIXTURE does not accept chromosome names that are not human chromosomes. We will thus just exchange the first column by 0
#awk '{$1="0";print $0}' $FILE.bim > $FILE.bim.tmp
#mv $FILE.bim.tmp $FILE.bim

#Run admixture
K=${SLURM_ARRAY_TASK_ID}
admixture --cv ${FILE}.bed $K > log${K}.out

#Collect CV errors to evaluate which cluster is best
awk '/CV/ {print $3,$4}' *out | cut -c 4,7-20 > $FILE.cv.error
grep "CV" *out | awk '{print $3,$4}' | sed -e 's/(//;s/)//;s/://;s/K=//'  > $FILE.cv.error
grep "CV" *out | awk '{print $3,$4}' | cut -c 4,7-20 > $FILE.cv.error