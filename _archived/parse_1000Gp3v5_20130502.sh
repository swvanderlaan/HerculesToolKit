#!/bin/bash
#
# created by Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl
# last edit: 2023-01-30
#
#################################################################################################
### PARAMETERS SLURM
#SBATCH --job-name=parse_1000Gp3v5_20130502                                  														# the name of the job
#SBATCH -o /hpc/dhl_ec/data/references/1000G/Phase3/VCF_format/parse_1000Gp3v5_20130502.log 	        # the log file of this job
#SBATCH --error /hpc/dhl_ec/data/references/1000G/Phase3/VCF_format/parse_1000Gp3v5_20130502.errors	# the error file of this job
#SBATCH --time=12:15:00                                             														# the amount of time the job will take: -t [min] OR -t [days-hh:mm:ss]
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

# Reference: https://www.biostars.org/p/335605/

# https://bioinformatics.stackexchange.com/questions/264/is-there-an-easy-way-to-create-a-summary-of-a-vcf-file-v4-1-with-structural-va
# https://github.com/pwwang/vcfstats
# https://www.biostars.org/p/274824/

bcftools="/hpc/local/CentOS7/dhl_ec/software/bcftools_v1.6"
SERV_1000G="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp"

PLINK="/hpc/local/CentOS7/dhl_ec/software/plink_v1.90_beta7_20230116"
PLINK2="/hpc/local/CentOS7/dhl_ec/software/plink2_alpha3_7_final"
GEN1000P3="/hpc/dhl_ec/data/references/1000G/Phase3"


# echo "STEP 1: Download the files as VCF.gz (and tab-indices)."
# prefix="${SERV_1000G}/release/20130502/ALL.chr" ;
# 
# suffix=".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz" ;
# 
# for chr in {1..22}; do
# 	echo "> processing chromosome: ${chr} ..."
# 	wget "${prefix}""${chr}""${suffix}" "${prefix}""${chr}""${suffix}".tbi ;
# done
# 
# 
# wget ${SERV_1000G}/release/20130502/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz
# wget ${SERV_1000G}/release/20130502/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz.tbi
# wget ${SERV_1000G}/release/20130502/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz
# wget ${SERV_1000G}/release/20130502/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz.tbi
# wget ${SERV_1000G}/release/20130502/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz
# wget ${SERV_1000G}/release/20130502/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz.tbi
# 
# 
# wget ${SERV_1000G}/release/20130502/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5c.20130502.sites.vcf.gz
# wget ${SERV_1000G}/release/20130502/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5c.20130502.sites.vcf.gz.tbi
# 
# 
# wget ${SERV_1000G}/release/20130502/integrated_call_male_samples_v3.20130502.ALL.panel
# wget ${SERV_1000G}/release/20130502/integrated_call_samples_v3.20130502.ALL.panel
# wget ${SERV_1000G}/release/20130502/integrated_call_samples_v3.20200731.ALL.ped
# wget ${SERV_1000G}/release/20130502/README_chrMT_phase3_callmom.md
# wget ${SERV_1000G}/release/20130502/README_known_issues_20200731
# wget ${SERV_1000G}/release/20130502/README_phase3_callset_20150220
# wget ${SERV_1000G}/release/20130502/README_phase3_chrY_calls_20141104
# wget ${SERV_1000G}/release/20130502/README_vcf_info_annotation.20141104
# wget ${SERV_1000G}/release/20130502/20140625_related_individuals.txt
# 
# echo "STEP 2: Download 1000 Genomes PED file."
# 
# wget ${SERV_1000G}/technical/working/20130606_sample_info/20130606_g1k.ped ;
# 
# echo "STEP 3: Download the GRCh37 / hg19 reference genome."
# 
# wget ${SERV_1000G}/technical/reference/human_g1k_v37.fasta.gz ;
# 
# wget ${SERV_1000G}/technical/reference/human_g1k_v37.fasta.fai ;
# 
# gzip -dv human_g1k_v37.fasta.gz ;

echo "STEP 4: Convert the 1000 Genomes files to BCF."

# - Ensure that multi-allelic calls are split and that indels are left-aligned compared to reference genome (1st pipe)
# - Sets the ID field to a unique value: CHROM:POS:REF:ALT (2nd pipe)
# - Removes duplicates (3rd pipe)
# 
# -I +'%CHROM:%POS:%REF:%ALT' means that unset IDs will be set to CHROM:POS:REF:ALT
# 
# -x ID -I +'%CHROM:%POS:%REF:%ALT' first erases the current ID and then sets it to CHROM:POS:REF:ALT
#
# norm -Ob --rm-dup both creates binary zipped (Ob) BCF (this is faster than zipped VCF!) and removes duplicate variants

for chr in {1..22} ; do
	echo "> fixing, annotating, and normalizing chromosome: ${chr} ..."
	$bcftools norm -m-any --check-ref w -f human_g1k_v37.fasta \
		${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz | \
			$bcftools annotate -x ID -I +'%CHROM\:%POS\:%REF\:%ALT' | \
				$bcftools norm -Ob --rm-dup both \
					> ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf.gz ;

	$bcftools index ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
			
done

echo "> fixing, annotating, and normalizing chromosome: MT ..."
$bcftools norm -m-any --check-ref w -f human_g1k_v37.fasta \
	${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz | \
		$bcftools annotate -x ID -I +'%CHROM\:%POS\:%REF\:%ALT' | \
			$bcftools norm -Ob --rm-dup both \
				> ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
$bcftools index ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;

# echo "> fixing, annotating, and normalizing chromosome: X ..."
# $bcftools norm -m-any --check-ref w -f human_g1k_v37.fasta \
# 	${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz | \
# 		$bcftools annotate -x ID -I +'%CHROM\:%POS\:%REF\:%ALT' | \
# 			$bcftools norm -Ob --rm-dup both \
# 				> ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
# $bcftools index ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;

echo "> fixing, annotating, and normalizing chromosome: Y ..."
$bcftools norm -m-any --check-ref w -f human_g1k_v37.fasta \
	${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz | \
		$bcftools annotate -x ID -I +'%CHROM\:%POS\:%REF\:%ALT' | \
			$bcftools norm -Ob --rm-dup both \
				> ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
$bcftools index ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;


# echo "STEP 5: Convert the 1000 Genomes files to PLINK."
# 
# for POP in AFR EUR; do
# echo ">> STEP 5A: processing ${POP}-population."
# 	for chr in {1..22}; do
# 	echo "> converting chromosome: ${chr} ..."
# 		$PLINK2 \
# 		  --bcf ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 		  --vcf-idspace-to _ \
# 		  --const-fid \
# 		  --split-par b37 \
# 		  --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
# 		  --make-bed \
# 		  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502."${POP}".chr"${chr}" \
# 		  --remove ${GEN1000P3}/remove.non"${POP}".individuals.txt ;
# 	done
# 
# 	echo "> converting chromosome: MT ..."
# 	$PLINK2 \
# 	  --bcf ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 	  --vcf-idspace-to _ \
# 	  --const-fid \
# 	  --split-par b37 \
# 	  --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
# 	  --make-bed \
# 	  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502."${POP}".chr26 \
# 	  --remove ${GEN1000P3}/remove.non"${POP}".individuals.txt ;
# 
# 	echo "> converting chromosome: X ..."
# 	$PLINK2 \
# 	  --bcf ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 	  --vcf-idspace-to _ \
# 	  --const-fid \
# 	  --split-par b37 \
# 	  --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
# 	  --make-bed \
# 	  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502."${POP}".chr23 \
# 	  --remove ${GEN1000P3}/remove.non"${POP}".individuals.txt ;
# 
# 	echo "> converting chromosome: Y ..."
# 	$PLINK2 \
# 	  --bcf ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 	  --vcf-idspace-to _ \
# 	  --const-fid \
# 	  --split-par b37 \
# 	  --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
# 	  --make-bed \
# 	  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502."${POP}".chr24 \
# 	  --remove ${GEN1000P3}/remove.non"${POP}".individuals.txt ;
# 	
# done
# 
# echo ">> STEP 5B: processing ALL populations, n=2534 samples."
# for chr in {1..22}; do
# echo "> converting chromosome: ${chr} ..."
# 	$PLINK2 \
# 	  --bcf ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 	  --vcf-idspace-to _ \
# 	  --const-fid \
# 	  --split-par b37 \
# 	  --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
# 	  --make-bed \
# 	  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr"${chr}" ;
# done
# 
# echo "> converting chromosome: MT ..."
# $PLINK2 \
#   --bcf ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
#   --vcf-idspace-to _ \
#   --const-fid \
#   --split-par b37 \
#   --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
#   --make-bed \
#   --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr26 ;
# 
# echo "> converting chromosome: X ..."
# $PLINK2 \
#   --bcf ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
#   --vcf-idspace-to _ \
#   --const-fid \
#   --split-par b37 \
#   --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
#   --make-bed \
#   --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr23 ;
# 
# echo "> converting chromosome: Y ..."
# $PLINK2 \
#   --bcf ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
#   --vcf-idspace-to _ \
#   --const-fid \
#   --split-par b37 \
#   --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
#   --make-bed \
#   --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr24

	

