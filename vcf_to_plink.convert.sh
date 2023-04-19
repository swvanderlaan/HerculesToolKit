#!/bin/bash
#
# created by Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl
# last edit: 2023-04-19
#
#################################################################################################
### PARAMETERS SLURM
#SBATCH --job-name=convert_vcf_to_plink                                  														# the name of the job
#SBATCH -o /hpc/dhl_ec/data/references/1000G/Phase3/VCF_format/convert_vcf_to_plink.freqzip.pops.log 	        # the log file of this job
#SBATCH --error /hpc/dhl_ec/data/references/1000G/Phase3/VCF_format/convert_vcf_to_plink.freqzip.pops.errors	# the error file of this job
#SBATCH --time=02:15:00                                             														# the amount of time the job will take: -t [min] OR -t [days-hh:mm:ss]
#SBATCH --mem=4G                                                    														# the amount of memory you think the script will consume, found on: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/SlurmScheduler
#SBATCH --gres=tmpspace:128G                                        														# the amount of temporary diskspace per node
#SBATCH --mail-user=s.w.vanderlaan-2@umcutrecht.nl                  														# where should be mailed to?
#SBATCH --mail-type=ALL                                            														# when do you want to receive a mail from your job?  Valid type values are NONE, BEGIN, END, FAIL, REQUEUE
                                                                    														# or ALL (equivalent to BEGIN, END, FAIL, INVALID_DEPEND, REQUEUE, and STAGE_OUT), 
                                                                    														# Multiple type values may be specified in a comma separated list. 
####    Note:   You do not have to specify workdir: 
####            'Current working directory is the calling process working directory unless the --chdir argument is passed, which will override the current working directory.'
####            TODO: select the type of interpreter you'd like to use
####            TODO: Find out whether this job should dependant on other scripts (##SBATCH --depend=[state:job_id])
####
#################################################################################################

# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

echo ">-----------------------------------------------------------------------------------"
echo "                              CONVERT VCF FILES TO PLINK"
echo "                                  version 2.0 (20230419)"
echo ""
echo "* Written by  : Sander W. van der Laan"
echo "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
echo "* Last update : 2023-04-19"
echo "* Version     : convert_VCF_to_PLINK"
echo ""
echo "* Description : This script will convert 1000G phase 3 VCF into PLINK-files. For this"
echo "                we used information from the following websites:"
echo "                https://www.biostars.org/p/335605/"
echo "                http://apol1.blogspot.nl/2014/11/best-practice-for-converting-vcf-files.html"
echo ""
echo ">-----------------------------------------------------------------------------------"
echo "Today's: "`date`
echo ""
echo ">-----------------------------------------------------------------------------------"
echo "The following directories are set."
SERV_1000G="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp"

SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"

bcftools="${SOFTWARE}/bcftools_v1.6"
PLINK="${SOFTWARE}/plink_v1.90_beta7_20230116"
PLINK2="${SOFTWARE}/plink2_alpha3_7_final"

ORIGINALS="/hpc/dhl_ec/data/references/1000G"
GEN1000P3=${ORIGINALS}/Phase3

echo "Original data directory____: " ${ORIGINALS}
echo "Phase 3 data directory_____: " ${GEN1000P3}
echo "Software directory_________: " ${SOFTWARE}

echo ""
### 									IMPORTANT NOTICE							   ###
### Refer to these site for more information regarding the best practice of converting
### VCF files to PLINK-style formatted files.
###
### Reference: https://www.biostars.org/p/335605/
### http://apol1.blogspot.com/2014/11/best-practice-for-converting-vcf-files.html
### https://bioinformatics.stackexchange.com/questions/264/is-there-an-easy-way-to-create-a-summary-of-a-vcf-file-v4-1-with-structural-va
### https://github.com/pwwang/vcfstats
### https://www.biostars.org/p/274824/
###
### 						         END OF IMPORTANT NOTICE						   ###
echo ">-----------------------------------------------------------------------------------"

echo ""
echo ">-----------------------------------------------------------------------------------"
echo "STEP 1: Download the files as VCF.gz (and tab-indices)."

# prefix="${SERV_1000G}/release/20130502/ALL.chr" ;
# 
# suffix=".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz" ;
# 
# for chr in {1..22}; do
# 	echo "> processing chromosome: ${chr} ..."
# 	wget "${prefix}""${chr}""${suffix}" "${prefix}""${chr}""${suffix}".tbi ;
# done
# 
# echo "> processing chromosome: MT, X, and Y ..."
# wget ${SERV_1000G}/release/20130502/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz
# wget ${SERV_1000G}/release/20130502/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz.tbi
# wget ${SERV_1000G}/release/20130502/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz
# wget ${SERV_1000G}/release/20130502/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz.tbi
# wget ${SERV_1000G}/release/20130502/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz
# wget ${SERV_1000G}/release/20130502/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz.tbi
 
# echo "> getting site information ..."
# wget ${SERV_1000G}/release/20130502/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5c.20130502.sites.vcf.gz
# wget ${SERV_1000G}/release/20130502/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5c.20130502.sites.vcf.gz.tbi
 
# echo "> getting readme and sample information ..."
# wget ${SERV_1000G}/release/20130502/integrated_call_male_samples_v3.20130502.ALL.panel
# wget ${SERV_1000G}/release/20130502/integrated_call_samples_v3.20130502.ALL.panel
# wget ${SERV_1000G}/release/20130502/integrated_call_samples_v3.20200731.ALL.ped
# wget ${SERV_1000G}/release/20130502/README_chrMT_phase3_callmom.md
# wget ${SERV_1000G}/release/20130502/README_known_issues_20200731
# wget ${SERV_1000G}/release/20130502/README_phase3_callset_20150220
# wget ${SERV_1000G}/release/20130502/README_phase3_chrY_calls_20141104
# wget ${SERV_1000G}/release/20130502/README_vcf_info_annotation.20141104
# wget ${SERV_1000G}/release/20130502/20140625_related_individuals.txt
 
echo ""
echo ">-----------------------------------------------------------------------------------"
echo "STEP 2: Download 1000 Genomes PED file."

# wget ${SERV_1000G}/technical/working/20130606_sample_info/20130606_g1k.ped ;
 
echo ""
echo ">-----------------------------------------------------------------------------------"
echo "STEP 3: Download the GRCh37 / hg19 reference genome."

# wget ${SERV_1000G}/technical/reference/human_g1k_v37.fasta.gz ;
 
# wget ${SERV_1000G}/technical/reference/human_g1k_v37.fasta.fai ;
 
# gzip -dv human_g1k_v37.fasta.gz ;

echo ""
echo ">-----------------------------------------------------------------------------------"
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

# for chr in {1..22} ; do
# 	echo "> fixing, annotating, and normalizing chromosome: ${chr} ..."
# 	$bcftools norm -m-any --check-ref w -f ${GEN1000P3}/VCF_format/human_g1k_v37.fasta \
# 		${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz | \
# 			$bcftools annotate -x ID -I +'chr%CHROM\:%POS\:%REF\_%ALT' | \
# 				$bcftools norm -Ob --rm-dup both \
# 					> ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
# 	$bcftools index ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;	
# done
# 
# echo "> fixing, annotating, and normalizing chromosome: MT ..."
# $bcftools norm -m-any --check-ref w -f ${GEN1000P3}/VCF_format/human_g1k_v37.fasta \
# 	${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz | \
# 		$bcftools annotate -x ID -I +'chr%CHROM\:%POS\:%REF\_%ALT' | \
# 			$bcftools norm -Ob --rm-dup both \
# 				> ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
# $bcftools index ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
# 
# echo "> fixing, annotating, and normalizing chromosome: X ..."
# $bcftools norm -m-any --check-ref w -f ${GEN1000P3}/VCF_format/human_g1k_v37.fasta \
# 	${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz | \
# 		$bcftools annotate -x ID -I +'chr%CHROM\:%POS\:%REF\_%ALT' | \
# 			$bcftools norm -Ob --rm-dup both \
# 				> ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
# $bcftools index ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
# 
# echo "> fixing, annotating, and normalizing chromosome: Y ..."
# $bcftools norm -m-any --check-ref w -f ${GEN1000P3}/VCF_format/human_g1k_v37.fasta \
# 	${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz | \
# 		$bcftools annotate -x ID -I +'chr%CHROM\:%POS\:%REF\_%ALT' | \
# 			$bcftools norm -Ob --rm-dup both \
# 				> ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
# $bcftools index ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;

echo ""
echo ">-----------------------------------------------------------------------------------"
echo "STEP 5: Convert the 1000 Genomes files to PLINK for different populations."
echo ""
# echo "- create removal list"
# cat ${GEN1000P3}/VCF_format/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="AFR"' | awk '{ print 0, $1 }' | tail -n +2 > ${GEN1000P3}/PLINK_format/remove.nonAFR.individuals.txt
# cat ${GEN1000P3}/VCF_format/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="EUR"' | awk '{ print 0, $1 }' | tail -n +2 > ${GEN1000P3}/PLINK_format/remove.nonEUR.individuals.txt
# 
# echo ""
# echo "- create removal list"
# cat ${GEN1000P3}/VCF_format/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="EAS"' | awk '{ print 0, $1 }' | tail -n +2 > ${GEN1000P3}/PLINK_format/remove.nonEAS.individuals.txt
# cat ${GEN1000P3}/VCF_format/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="SAS"' | awk '{ print 0, $1 }' | tail -n +2 > ${GEN1000P3}/PLINK_format/remove.nonSAS.individuals.txt
# cat ${GEN1000P3}/VCF_format/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="AMR"' | awk '{ print 0, $1 }' | tail -n +2 > ${GEN1000P3}/PLINK_format/remove.nonAMR.individuals.txt
# 
# echo ""
# echo "> create PLINK-files"
# 
# for POP in AFR EUR EAS AMR SAS; do
# 	echo ">>> STEP 5A: processing ${POP}-population. <<<"
# 	for chr in {1..22}; do
# 	echo "> converting chromosome: ${chr} ..."
# 		$PLINK2 \
# 		  --bcf ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 		  --vcf-idspace-to _ \
# 		  --const-fid \
# 		  --split-par b37 \
# 		  --update-name ${GEN1000P3}/ALL.phase3_shapeit2_mvncall_integrated_v5b.20130502.VARIANTLIST.PLINKupdate.only_biallelic.only_rsIDs.txt \
# 		  --make-bed \
# 		  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502."${POP}".chr"${chr}" \
# 		  --remove ${GEN1000P3}/PLINK_format/remove.non"${POP}".individuals.txt ;
# 	done
# 
# 	echo "> converting chromosome: MT ..."
# 	$PLINK2 \
# 	  --bcf ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 	  --vcf-idspace-to _ \
# 	  --const-fid \
# 	  --split-par b37 \
# 	  --allow-extra-chr 0 \
# 	  --update-name ${GEN1000P3}/ALL.phase3_shapeit2_mvncall_integrated_v5b.20130502.VARIANTLIST.PLINKupdate.only_biallelic.only_rsIDs.txt \
# 	  --make-bed \
# 	  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502."${POP}".chr26 \
# 	  --remove ${GEN1000P3}/PLINK_format/remove.non"${POP}".individuals.txt ;
# 
# 	echo "> converting chromosome: X ..."
# 	$PLINK2 \
# 	  --bcf ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 	  --vcf-idspace-to _ \
# 	  --const-fid \
# 	  --split-par b37 \
# 	  --update-name ${GEN1000P3}/ALL.phase3_shapeit2_mvncall_integrated_v5b.20130502.VARIANTLIST.PLINKupdate.only_biallelic.only_rsIDs.txt \
# 	  --make-bed \
# 	  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502."${POP}".chr23 \
# 	  --remove ${GEN1000P3}/PLINK_format/remove.non"${POP}".individuals.txt ;
# 
# 	echo "> converting chromosome: Y ..."
# 	$PLINK2 \
# 	  --bcf ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 	  --vcf-idspace-to _ \
# 	  --const-fid \
# 	  --split-par b37 \
# 	  --update-name ${GEN1000P3}/ALL.phase3_shapeit2_mvncall_integrated_v5b.20130502.VARIANTLIST.PLINKupdate.only_biallelic.only_rsIDs.txt \
# 	  --make-bed \
# 	  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502."${POP}".chr24 \
# 	  --remove ${GEN1000P3}/PLINK_format/remove.non"${POP}".individuals.txt ;
# 	
# done
# 
# echo ">>> STEP 5B: processing ALL populations, 2534 samples. <<<"
# for chr in {1..22}; do
# 	echo "> converting chromosome: ${chr} ..."
# 	$PLINK2 \
# 	  --bcf ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 	  --vcf-idspace-to _ \
# 	  --const-fid \
# 	  --split-par b37 \
# 	  --update-name ${GEN1000P3}/ALL.phase3_shapeit2_mvncall_integrated_v5b.20130502.VARIANTLIST.PLINKupdate.only_biallelic.only_rsIDs.txt \
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
#   --update-name ${GEN1000P3}/ALL.phase3_shapeit2_mvncall_integrated_v5b.20130502.VARIANTLIST.PLINKupdate.only_biallelic.only_rsIDs.txt \
#   --make-bed \
#   --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr26 ;
# 
# echo "> converting chromosome: X ..."
# $PLINK2 \
#   --bcf ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
#   --vcf-idspace-to _ \
#   --const-fid \
#   --split-par b37 \
#   --update-name ${GEN1000P3}/ALL.phase3_shapeit2_mvncall_integrated_v5b.20130502.VARIANTLIST.PLINKupdate.only_biallelic.only_rsIDs.txt \
#   --make-bed \
#   --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr23 ;
# 
# echo "> converting chromosome: Y ..."
# $PLINK2 \
#   --bcf ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
#   --vcf-idspace-to _ \
#   --const-fid \
#   --split-par b37 \
#   --update-name ${GEN1000P3}/ALL.phase3_shapeit2_mvncall_integrated_v5b.20130502.VARIANTLIST.PLINKupdate.only_biallelic.only_rsIDs.txt \
#   --make-bed \
#   --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr24 ;

# echo ""
# echo ">-----------------------------------------------------------------------------------"
# echo "STEP 6: Merge PLINK files."
# 
# echo ""
# echo "> African (AFR) populations"
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AFR.chr1 \
# --pmerge-list ${GEN1000P3}/PLINK_format/merge.afr.list.txt --set-missing-var-ids "chr"@:#:\$r:\$a \
# --merge-max-allele-ct 2 \
# --memory 168960 \
# --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AFR
# 
# echo ""
# echo "> European (EUR) populations"
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EUR.chr1 \
# --pmerge-list ${GEN1000P3}/PLINK_format/merge.eur.list.txt --set-missing-var-ids "chr"@:#:\$r:\$a \
# --merge-max-allele-ct 2 \
# --memory 168960 \
# --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EUR
# 
# echo ""
# echo "> East-Asian (EAS) populations"
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EAS.chr1 \
# --pmerge-list ${GEN1000P3}/PLINK_format/merge.eas.list.txt --set-missing-var-ids "chr"@:#:\$r:\$a \
# --merge-max-allele-ct 2 \
# --memory 168960 \
# --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EAS
# 
# echo ""
# echo "> South-Asian (SAS) populations"
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.SAS.chr1 \
# --pmerge-list ${GEN1000P3}/PLINK_format/merge.sas.list.txt --set-missing-var-ids "chr"@:#:\$r:\$a \
# --merge-max-allele-ct 2 \
# --memory 168960 \
# --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.SAS
# 
# echo ""
# echo "> Admixed Americans (AMR) populations"
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AMR.chr1 \
# --pmerge-list ${GEN1000P3}/PLINK_format/merge.amr.list.txt --set-missing-var-ids "chr"@:#:\$r:\$a \
# --merge-max-allele-ct 2 \
# --memory 168960 \
# --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AMR
# 
# echo ""
# echo "> All populations"
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr1 \
# --pmerge-list ${GEN1000P3}/PLINK_format/merge.all.list.txt --set-missing-var-ids "chr"@:#:\$r:\$a \
# --merge-max-allele-ct 2 \
# --memory 168960 \
# --make-bed --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL

echo ""
echo ">-----------------------------------------------------------------------------------"
echo "STEP 7: Calculate some statistics."

# echo ""
# echo "- calculating frequencies"
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AFR \
# --freq --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AFR.FREQ
# 
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EUR \
# --freq --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EUR.FREQ
# 
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EAS \
# --freq --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.EAS.FREQ
# 
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.SAS \
# --freq --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.SAS.FREQ
# 
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AMR \
# --freq --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.AMR.FREQ
# 
# ${PLINK2} --bfile ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL \
# --freq --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.FREQ

gzip -v ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.*.FREQ.afrq

echo ""
echo ">-----------------------------------------------------------------------------------"
echo "Wow. I'm all done buddy. What a job! let's have a beer!"
echo "Today's "`date`
echo ">-----------------------------------------------------------------------------------"
echo "All done. Let's have a beer buddy!"
echo "Today's "`date`


