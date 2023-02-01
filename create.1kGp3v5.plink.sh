#!/bin/bash
#
#################################################################################################
### PARAMETERS SLURM
#SBATCH --job-name=metagwastoolkit                                  														# the name of the job
#SBATCH -o /hpc/dhl_ec/data/references/1000G/Phase3/PLINK_format/create.1kGp3v5.plink.log 	        # the log file of this job
#SBATCH --error /hpc/dhl_ec/data/references/1000G/Phase3/PLINK_format/create.1kGp3v5.plink.errors	# the error file of this job
#SBATCH --time=08:15:00                                             														# the amount of time the job will take: -t [min] OR -t [days-hh:mm:ss]
#SBATCH --mem=32G                                                    														# the amount of memory you think the script will consume, found on: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/SlurmScheduler
#SBATCH --gres=tmpspace:128G                                        														# the amount of temporary diskspace per node
#SBATCH --mail-user=s.w.vanderlaan-2@umcutrecht.nl                  														# where should be mailed to?
#SBATCH --mail-type=FAIL                                            														# when do you want to receive a mail from your job?  Valid type values are NONE, BEGIN, END, FAIL, REQUEUE
                                                                    														# or ALL (equivalent to BEGIN, END, FAIL, INVALID_DEPEND, REQUEUE, and STAGE_OUT), 
                                                                    														# Multiple type values may be specified in a comma separated list. 
####    Note:   You do not have to specify workdir: 
####            'Current working directory is the calling process working directory unless the --chdir argument is passed, which will override the current working directory.'
####            TODO: select the type of interpreter you'd like to use
####            TODO: Find out whether this job should dependant on other scripts (##SBATCH --depend=[state:job_id])
####
#################################################################################################
##########################################################################################
# CONVERT 1000G phase 3, version 5
#
# This script creates a PLINK-format files including only bi-allelic variants!
#
# created by: Sander W. van der Laan | s.w.vanderlaan@gmail.com
# last edit: 2023-01-30
# 
##########################################################################################
#
#

PLINK="/hpc/local/CentOS7/dhl_ec/software/plink_v1.90_beta7_20230116"
PLINK2="/hpc/local/CentOS7/dhl_ec/software/plink2_alpha3_7_final"
GEN1000P3="/hpc/dhl_ec/data/references/1000G/Phase3"

### 1000G with rsIDs
### I still have not found an easy way to map rsID. Here I found a post referring to
### Ensemble where they mapped all variants in ensemble-release 108 to 1000G (and more). 
### This is a solution. I created two files: 1) one containing all the variants, 
### 2) one containing all the bi-allelic variants only!
### https://www.biostars.org/p/9508768/#9508808
### At the same time, we make sure it only includes unique enteries:
### https://stackoverflow.com/questions/1915636/is-there-a-way-to-uniq-by-column
### https://unix.stackexchange.com/questions/160009/remove-entire-row-in-a-file-if-first-column-is-repeated
###
### Download the b37 data
### wget https://ftp.ensembl.org/pub/grch37/release-108/variation/vcf/homo_sapiens/1000GENOMES-phase_3.vcf.gz 
### mv -v 1000GENOMES-phase_3.vcf.gz 1000G.phase_3.b37_ensemble_r108.vcf.gz
### this includes all variants
# zcat ${GEN1000P3}/VCF_format/1000G.phase_3.b37_ensemble_r108.vcf.gz | grep -v "##" | head -1 > ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.txt
# zcat ${GEN1000P3}/VCF_format/1000G.phase_3.b37_ensemble_r108.vcf.gz | grep -v "#" | grep "E_1000G" | \
# perl -ane 'print if !$k{$F[0]}++' >> ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.txt
###
### this includes only bi-allelic variants
# zcat ${GEN1000P3}/VCF_format/1000G.phase_3.b37_ensemble_r108.vcf.gz | grep -v "##" | head -1 > ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.txt
# zcat ${GEN1000P3}/VCF_format/1000G.phase_3.b37_ensemble_r108.vcf.gz | grep -v "#" | grep "E_1000G" | grep -v "," | \
# perl -ane 'print if !$k{$F[0]}++' >> ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.txt

### We create a chr:bp:ref:alt to rsid map
# zcat ${GEN1000P3}/VCF_format/1000G.phase_3.b37_ensemble_r108.vcf.gz | grep -v '##' | \
# grep "E_1000G" | grep -v "," | \
# awk '{ print "chr"$1":"$2":"$4":"$5, $3}' | \
# perl -ane 'print if !$k{$F[0]}++' > ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt
# awk '!seen[$1]++' > ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt

echo ""
echo "> create PLINK-files"

### # removed 
### --allow-extra-chr 0 \
### --set-missing-var-ids "chr"@:#:\$r:\$a \
### # obsolete
### --keep-allele-order \

echo ""
echo "- create removal list"
# cat ${GEN1000P3}/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="AFR"' | awk '{ print 0, $1 }' | tail -n +2 > ${GEN1000P3}/remove.nonAFR.individuals.txt
# cat ${GEN1000P3}/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="EUR"' | awk '{ print 0, $1 }' | tail -n +2 > ${GEN1000P3}/remove.nonEUR.individuals.txt

### NOTE
### We used the latest versions for each type of chromosome!
### chrX/XY: 	ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz
### chrY: 		ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz
### chrMT: 		ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz
### chr1-22: 	ALL.chr[1-22].phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz

for POP in AFR EUR; do
	echo "Extracting all data for the [ ${POP} ] super-population."
	echo ""
	echo "- create chromosome X - 23"
	${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz \
	--const-fid \
	--vcf-idspace-to _ \
	--chr X \
	--split-par b37 \
	--set-missing-var-ids "chr"@:#:\$r:\$a \
	--var-id-multi "chr"@:#:\$r:\$a \
	--var-id-multi-nonsnp "chr"@:#:\$r:\$a \
	--new-id-max-allele-len 23 missing \
	--max-alleles 2 \
	--min-alleles 2 \
	--rm-dup force-first \
	--update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
	--make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.${POP}.chr23 \
	--remove ${GEN1000P3}/remove.non${POP}.individuals.txt 

	echo ""
	echo "- create chromosome Y - 24"
	${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz \
	--const-fid \
	--vcf-idspace-to _ \
	--set-missing-var-ids "chr"@:#:\$r:\$a \
	--var-id-multi "chr"@:#:\$r:\$a \
	--var-id-multi-nonsnp "chr"@:#:\$r:\$a \
	--new-id-max-allele-len 23 missing \
	--max-alleles 2 \
	--min-alleles 2 \
	--rm-dup force-first \
	--update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
	--make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.${POP}.chr24 \
	--remove ${GEN1000P3}/remove.non${POP}.individuals.txt 

### NOTE - this was not present?
### 	echo ""
### 	echo "- create chromosome XY - 25"
### 	${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz \
### 	--const-fid \
### 	--vcf-idspace-to _ \
### 	--autosome-par \
### 	--split-par b37 \
### 	--set-missing-var-ids "chr"@:#:\$r:\$a \
### 	--var-id-multi "chr"@:#:\$r:\$a \
### 	--var-id-multi-nonsnp "chr"@:#:\$r:\$a \
### 	--new-id-max-allele-len 23 missing \
### 	--max-alleles 2 \
### 	--min-alleles 2 \
### 	--rm-dup force-first \
### 	--update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
### 	--make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.${POP}.chr25 \
### 	--remove ${GEN1000P3}/remove.non${POP}.individuals.txt 

	echo ""
	echo "- create chromosome MT - 26"
	${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz \
	--const-fid \
	--vcf-idspace-to _ \
	--set-missing-var-ids "chr"@:#:\$r:\$a \
	--var-id-multi "chr"@:#:\$r:\$a \
	--var-id-multi-nonsnp "chr"@:#:\$r:\$a \
	--new-id-max-allele-len 23 missing \
	--max-alleles 2 \
	--min-alleles 2 \
	--rm-dup force-first \
	--update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
	--make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.${POP}.chr26 \
	--remove ${GEN1000P3}/remove.non${POP}.individuals.txt 

	echo ""
	echo "- create autosomes"
	for C in $(seq 1 22); do 
		echo "* converting chromosome ${C}"
		${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chr${C}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz \
		--const-fid \
		--vcf-idspace-to _ \
		--set-missing-var-ids "chr"@:#:\$r:\$a \
		--var-id-multi "chr"@:#:\$r:\$a \
		--var-id-multi-nonsnp "chr"@:#:\$r:\$a \
		--new-id-max-allele-len 23 missing \
		--max-alleles 2 \
		--min-alleles 2 \
		--rm-dup force-first \
		--update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
		--make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.${POP}.chr${C} \
		--remove ${GEN1000P3}/remove.non${POP}.individuals.txt 
	
	done

done

echo "Extracting all data for the all individuals."
echo ""
echo "- create chromosome X - 23"
${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz \
--const-fid \
--vcf-idspace-to _ \
--chr X \
--split-par b37 \
--set-missing-var-ids "chr"@:#:\$r:\$a \
--var-id-multi "chr"@:#:\$r:\$a \
--var-id-multi-nonsnp "chr"@:#:\$r:\$a \
--new-id-max-allele-len 23 missing \
--max-alleles 2 \
--min-alleles 2 \
--rm-dup force-first \
--update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
--make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr23 

echo ""
echo "- create chromosome Y - 24"
${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz \
--const-fid \
--vcf-idspace-to _ \
--set-missing-var-ids "chr"@:#:\$r:\$a \
--var-id-multi "chr"@:#:\$r:\$a \
--var-id-multi-nonsnp "chr"@:#:\$r:\$a \
--new-id-max-allele-len 23 missing \
--max-alleles 2 \
--min-alleles 2 \
--rm-dup force-first \
--update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
--make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr24 

### NOTE - this was not present?
### echo ""
### echo "- create chromosome XY - 25"
### ${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz \
### --const-fid \
### --vcf-idspace-to _ \
### --autosome-par \
### --split-par b37 \
### --set-missing-var-ids "chr"@:#:\$r:\$a \
### --var-id-multi "chr"@:#:\$r:\$a \
### --var-id-multi-nonsnp "chr"@:#:\$r:\$a \
### --new-id-max-allele-len 23 missing \
### --max-alleles 2 \
### --min-alleles 2 \
### --rm-dup force-first \
### --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
### --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr25

echo ""
echo "- create chromosome MT - 26"
${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz \
--const-fid \
--vcf-idspace-to _ \
--set-missing-var-ids "chr"@:#:\$r:\$a \
--var-id-multi "chr"@:#:\$r:\$a \
--var-id-multi-nonsnp "chr"@:#:\$r:\$a \
--new-id-max-allele-len 23 missing \
--max-alleles 2 \
--min-alleles 2 \
--rm-dup force-first \
--update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
--make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr26 

echo ""
echo "- create autosomes"
for C in $(seq 1 22); do 
	echo "* converting chromosome ${C}"
	${PLINK2} --vcf ${GEN1000P3}/VCF_format/ALL.chr${C}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz \
	--const-fid \
	--vcf-idspace-to _ \
	--set-missing-var-ids "chr"@:#:\$r:\$a \
	--var-id-multi "chr"@:#:\$r:\$a \
	--var-id-multi-nonsnp "chr"@:#:\$r:\$a \
	--new-id-max-allele-len 23 missing \
	--max-alleles 2 \
	--min-alleles 2 \
	--rm-dup force-first \
	--update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
	--make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr${C} 

done

# echo ""
# echo "- merging all chromosomes"
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AFR.chr1 \
# --pmerge-list ${GEN1000P3}/PLINK_format/merge.afr.list.txt --set-missing-var-ids "chr"@:#:\$r:\$a \
# --merge-max-allele-ct 2 --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AFR
# 
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EUR.chr1 \
# --pmerge-list ${GEN1000P3}/PLINK_format/merge.eur.list.txt --set-missing-var-ids "chr"@:#:\$r:\$a \
# --merge-max-allele-ct 2 --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EUR
# 
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr1 \
# --pmerge-list ${GEN1000P3}/PLINK_format/merge.all.list.txt --set-missing-var-ids "chr"@:#:\$r:\$a \
# --merge-max-allele-ct 2 --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL
# 
# 
# echo ""
# echo "- calculating frequencies"
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AFR \
# --freq --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AFR.FREQ
# 
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EUR \
# --freq --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EUR.FREQ
# 
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL \
# --freq --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.FREQ
# 
