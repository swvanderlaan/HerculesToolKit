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

# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

echo ">-----------------------------------------------------------------------------------"
echo "                              CONVERT VCF FILES TO PLINK"
echo "                                  version 2.0 (20230131)"
echo ""
echo "* Written by  : Sander W. van der Laan"
echo "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
echo "* Last update : 2023-01-31"
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

for chr in {1..22} ; do
	echo "> fixing, annotating, and normalizing chromosome: ${chr} ..."
	$bcftools norm -m-any --check-ref w -f human_g1k_v37.fasta \
		${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz | \
			$bcftools annotate -x ID -I +'chr%CHROM\:%POS\:%REF\:%ALT' | \
				$bcftools norm -Ob --rm-dup both \
					> ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf.gz ;

	$bcftools index ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
			
done

echo "> fixing, annotating, and normalizing chromosome: MT ..."
$bcftools norm -m-any --check-ref w -f human_g1k_v37.fasta \
	${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz | \
		$bcftools annotate -x ID -I +'chr%CHROM\:%POS\:%REF\:%ALT' | \
			$bcftools norm -Ob --rm-dup both \
				> ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
$bcftools index ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;

echo "> fixing, annotating, and normalizing chromosome: X ..."
$bcftools norm -m-any --check-ref w -f human_g1k_v37.fasta \
	${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz | \
		$bcftools annotate -x ID -I +'chr%CHROM\:%POS\:%REF\:%ALT' | \
			$bcftools norm -Ob --rm-dup both \
				> ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
$bcftools index ${GEN1000P3}/VCF_format/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;

echo "> fixing, annotating, and normalizing chromosome: Y ..."
$bcftools norm -m-any --check-ref w -f human_g1k_v37.fasta \
	${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz | \
		$bcftools annotate -x ID -I +'chr%CHROM\:%POS\:%REF\:%ALT' | \
			$bcftools norm -Ob --rm-dup both \
				> ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;
$bcftools index ${GEN1000P3}/VCF_format/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf ;


echo ""
echo ">-----------------------------------------------------------------------------------"
echo "STEP 5: Convert the 1000 Genomes files to PLINK for different populations."
echo ""
echo "- create removal list"
cat ${GEN1000P3}/VCF_format/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="AFR"' | awk '{ print 0, $1 }' | tail -n +2 > ${GEN1000P3}/PLINK_format/remove.nonAFR.individuals.txt
cat ${GEN1000P3}/VCF_format/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="EUR"' | awk '{ print 0, $1 }' | tail -n +2 > ${GEN1000P3}/PLINK_format/remove.nonEUR.individuals.txt

echo ""
echo "> create PLINK-files"

### # removed 
### --allow-extra-chr 0 \
### --set-missing-var-ids "chr"@:#:\$r:\$a \
### # obsolete
### --keep-allele-order \

for POP in AFR EUR; do
	echo ">>> STEP 5A: processing ${POP}-population. <<<"
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

	echo "> converting chromosome: MT ..."
	$PLINK2 \
	  --bcf ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
	  --vcf-idspace-to _ \
	  --const-fid \
	  --split-par b37 \
	  --allow-extra-chr 0 \
	  --update-name ${GEN1000P3}/VCF_format/_temp/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
	  --make-bed \
	  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502."${POP}".chr26 \
	  --remove ${GEN1000P3}/remove.non"${POP}".individuals.txt ;

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
	
done

echo ">>> STEP 5B: processing ALL populations, 2534 samples. <<<"
# for chr in {1..22}; do
# 	echo "> converting chromosome: ${chr} ..."
# 	$PLINK2 \
# 	  --bcf ${GEN1000P3}/VCF_format/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
# 	  --vcf-idspace-to _ \
# 	  --const-fid \
# 	  --split-par b37 \
# 	  --update-name ${GEN1000P3}/VCF_format/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
# 	  --make-bed \
# 	  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr"${chr}" ;
# done

echo "> converting chromosome: MT ..."
$PLINK2 \
  --bcf ${GEN1000P3}/VCF_format/ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.chrbprefalt.nodups.indel_leftalign.multi_split.bcf \
  --vcf-idspace-to _ \
  --const-fid \
  --split-par b37 \
  --update-name ${GEN1000P3}/VCF_format/_temp/1000G.variants_in_phase_3.all_rsids.only_biallelic.plink_map.b37_ens_r108.txt \
  --make-bed \
  --out ${GEN1000P3}/PLINK_format/1000Gp3v5.20130502.ALL.chr26 ;

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

echo ""
echo ">-----------------------------------------------------------------------------------"
echo "Wow. I'm all done buddy. What a job! let's have a beer!"
echo "Today's "`date`
echo ">-----------------------------------------------------------------------------------"
echo "All done. Let's have a beer buddy!"
echo "Today's "`date`

# #!/bin/bash
# #
# # You can use the variables below (indicated by "#$") to set some things for the 
# # submission system.
# #$ -S /bin/bash # the type of BASH you'd like to use
# #$ -o /hpc/dhl_ec/data/references/1000G/convert_VCF_to_PLINK.UPDATEnamesPLINK.log # the log file of this job
# #$ -e /hpc/dhl_ec/data/references/1000G/convert_VCF_to_PLINK.UPDATEnamesPLINK.errors # the error file of this job
# #$ -N Convert_VCF2PLINK 
# #$ -hold_jid MakeVariantList 
# #$ -q medium # which queue you'd like to use
# #$ -pe threaded 12 # how many threads (1 = 15 Gb) you want for the job
# #$ -M s.w.vanderlaan-2@umcutrecht.nl # you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
# #$ -m ea # you can choose: b=begin of job; e=end of job; a=abort of job; s=
# #$ -cwd # set the job start to the current directory - so all the things in this script are relative to the current directory!!!
# #
# # Another useful tip: you can set a job to run after another has finished. Name the job 
# # with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# # Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
# #
# # The command 'clear' cleares the screen.
# clear
# # It is good practice to properly name and annotate your script for future reference for
# # yourself and others. Trust me, you'll forget why and how you made this!!!
# echo ">-----------------------------------------------------------------------------------"
# echo "                              CONVERT VCF FILES TO PLINK"
# echo "                                  version 1.1 (20160221)"
# echo ""
# echo "* Written by  : Sander W. van der Laan"
# echo "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
# echo "* Last update : 2016-02-21"
# echo "* Version     : convert_VCF_to_PLINK_v1.1_20160221"
# echo ""
# echo "* Description : This script will convert 1000G phase 3 VCF into PLINK-files. For this"
# echo "                we used information from the following website:"
# echo "                http://apol1.blogspot.nl/2014/11/best-practice-for-converting-vcf-files.html"
# echo ""
# echo ">-----------------------------------------------------------------------------------"
# echo "Today's: "`date`
# echo ""
# echo ">-----------------------------------------------------------------------------------"
# echo "The following directories are set."
# ORIGINALS=/hpc/dhl_ec/data/references/1000G
# PHASE3=$ORIGINALS/Phase3
# SOFTWARE=/hpc/local/CentOS6/dhl_ec/software
# echo "Original data directory____: " $ORIGINALS
# echo "Phase 3 data directory_____: " $PHASE3
# echo "Software directory_________: " $SOFTWARE
# cd $ORIGINALS
# echo ""
# ### 									IMPORTANT NOTICE							   ###
# ### Refer to this site for more information regarding the best practice of converting
# ### VCF files to PLINK-style formatted files.
# ### >>> http://apol1.blogspot.nl/2014/11/best-practice-for-converting-vcf-files.html <<<
# ### 						         END OF IMPORTANT NOTICE						   ###
# echo ">-----------------------------------------------------------------------------------"
# #echo "Downloading b37 FASTA data..."
# #wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz 
# #echo "Unzipping b37 FASTA data..."
# #gunzip -v $ORIGINALS/human_g1k_v37.fasta.gz
# #echo "Indexing FASTA file..."
# #samtools_v13 faidx $ORIGINALS/human_g1k_v37.fasta
# #echo "Done!"
# #echo ""
# #echo ">-----------------------------------------------------------------------------------"
# #echo "* STEP 1: Getting a list of EUR-panel individuals."
# #	echo "The total number of 1000G phase 3 (version 5) ALL-panel individuals is:"
# #	cat $PHASE3/integrated_call_samples_v3.20130502.ALL.panel | tail -n +2 | wc -l
# #	cat $PHASE3/integrated_call_samples_v3.20130502.ALL.panel | awk '$3=="super_pop" || $3=="EUR"' > $PHASE3/integrated_call_samples_v3.20130502.EUR.panel
# #	cat $PHASE3/integrated_call_samples_v3.20130502.ALL.panel | awk '$3!="EUR"' | awk '{ print 0, $1 }' | tail -n +2 > $PHASE3/remove.nonEUR.individuals.txt
# #	echo "The total number of 1000G phase 3 (version 5) EUR-panel individuals is:"
# #	cat $PHASE3/integrated_call_samples_v3.20130502.EUR.panel | tail -n +2 | wc -l
# #	echo "The total number of 1000G phase 3 (version 5) nonEUR-panel individuals is (i.e. will be removed):"
# #	cat $PHASE3/remove.nonEUR.individuals.txt | wc -l
# #echo ""
# #echo ">-----------------------------------------------------------------------------------"
# #echo "* STEP 2: Transforming VCF files and making PLINK-formatted files."
# #for CHR in $(seq 1 23); do 
# #	echo "* STEP 1: Indexing VCF-file..."
# #	$SOFTWARE/tabix_v026 -p vcf $PHASE3/VCF_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes.vcf.gz 
# #	echo "* STEP 2: Processing chromosome ${CHR}: changing variant IDs and making BCF-files..."
# #	$SOFTWARE/bcftools_v13 norm -Ou -m -any $PHASE3/VCF_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes.vcf.gz | 
# #	$SOFTWARE/bcftools_v13 norm -Ou -f $ORIGINALS/human_g1k_v37.fasta | 
# #	$SOFTWARE/bcftools_v13 annotate -Ob -x ID -I +'%CHROM:%POS:%REF:%ALT' | $SOFTWARE/bcftools_v13 view -Ob -o $PHASE3/VCF_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes.variantID.bcf.gz
# #	echo ""
# #	echo "* STEP 3: Converting to PLINK-formatted files and make EUR-panel files."
# #	$SOFTWARE/plink2 --bcf $PHASE3/VCF_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes.variantID.bcf.gz --keep-allele-order --vcf-idspace-to _ --const-fid --allow-extra-chr 0 --split-x b37 no-fail --make-bed --out $PHASE3/PLINK_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes
# #	$SOFTWARE/plink2 --bcf $PHASE3/VCF_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes.variantID.bcf.gz --keep-allele-order --vcf-idspace-to _ --const-fid --allow-extra-chr 0 --split-x b37 no-fail --remove $PHASE3/remove.nonEUR.individuals.txt --make-bed --out $PHASE3/PLINK_format/EUR.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes  
# #	echo ""
# #done
# #echo ">-----------------------------------------------------------------------------------"
# #echo "* Step 3: Transforming VCF files and making PLINK-formatted files for MT, X and Y chromosomes."
# #for FILENAME in chrMT.phase3_callmom.20130502.genotypes chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes chrY.phase3_integrated_v1b.20130502.genotypes wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites ; do
# #	echo "* STEP 1: Indexing VCF-file..."
# #	$SOFTWARE/tabix_v026 -p vcf $PHASE3/VCF_format/ALL.${FILENAME}.vcf.gz 
# #	echo "* STEP 2: Processing chromosome ${CHR}: changing variant IDs and making BCF-files..."
# #	$SOFTWARE/bcftools_v13 norm -Ou -m -any $PHASE3/VCF_format/ALL.${FILENAME}.vcf.gz | 
# #	$SOFTWARE/bcftools_v13 norm -Ou -f $ORIGINALS/human_g1k_v37.fasta | 
# #	$SOFTWARE/bcftools_v13 annotate -Ob -x ID -I +'%CHROM:%POS:%REF:%ALT' | $SOFTWARE/bcftools_v13 view -Ob -o $PHASE3/VCF_format/ALL.${FILENAME}.variantID.bcf.gz
# #	echo ""
# #	echo "* STEP 3: Converting to PLINK-formatted files and make EUR-panel files."
# #	$SOFTWARE/plink2 --bcf $PHASE3/VCF_format/ALL.${FILENAME}.variantID.bcf.gz --keep-allele-order --vcf-idspace-to _ --const-fid --allow-extra-chr 0 --split-x b37 no-fail --make-bed --out $PHASE3/PLINK_format/ALL.${FILENAME}
# #	$SOFTWARE/plink2 --bcf $PHASE3/VCF_format/ALL.${FILENAME}.variantID.bcf.gz --keep-allele-order --vcf-idspace-to _ --const-fid --allow-extra-chr 0 --split-x b37 no-fail --remove $PHASE3/remove.nonEUR.individuals.txt --make-bed --out $PHASE3/PLINK_format/EUR.${FILENAME}
# #	echo ""
# #done
# #echo "Done."
# #echo ">-----------------------------------------------------------------------------------"
# #echo "* Step 4: Calculating some statistics."
# #for CHR in $(seq 1 23); do
# #	$SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes --freq --out $PHASE3/PLINK_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes.FREQ
# #	$SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/EUR.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes --freq --out $PHASE3/PLINK_format/EUR.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes.FREQ
# #	$SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes --missing --out $PHASE3/PLINK_format/ALL.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes.MISSING
# #	$SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/EUR.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes --missing --out $PHASE3/PLINK_format/EUR.chr${CHR}.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes.MISSING
# #done
# #for FILENAME in chrMT.phase3_callmom.20130502.genotypes chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes chrY.phase3_integrated_v1b.20130502.genotypes ; do
# #	$SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/ALL.${FILENAME} --freq --out $PHASE3/PLINK_format/ALL.${FILENAME}.FREQ
# #	$SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/EUR.${FILENAME} --freq --out $PHASE3/PLINK_format/EUR.${FILENAME}.FREQ
# #	$SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/ALL.${FILENAME} --missing --out $PHASE3/PLINK_format/ALL.${FILENAME}.MISSING
# #	$SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/EUR.${FILENAME} --missing --out $PHASE3/PLINK_format/EUR.${FILENAME}.MISSING
# #done
# #echo "Done."
# #echo ">-----------------------------------------------------------------------------------"
# #echo "* STEP 5: Merging PLINK files into one." 
# #echo ""
# #### $SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/EUR.chr1.phase3_shapeit2_mvncall_integrated_v5.20130502.genotypes --memory 168960 --merge-list $PHASE3/merge.list.txt --make-bed --out $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.raw
# #echo ""
# echo ">-----------------------------------------------------------------------------------"
# echo "* STEP 6: Update variant ID names in PLINK files and run some statistics." 
# echo ""
# $SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.raw --memory 168960 --update-name $PHASE3/ALL.phase3_shapeit2_mvncall_integrated_v5.20130502.VARIANTLIST.ALTID_NOBPREFALT.v2.PLINKupdate.txt --make-bed --out $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR
# $SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.raw --memory 168960 --update-name $PHASE3/ALL.phase3_shapeit2_mvncall_integrated_v5.20130502.VARIANTLIST.ALTID_NOBPREFALT.v2.PLINKupdate_shortINDELnames.txt --make-bed --out $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.shortINDELnames
# $SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR --memory 168960 --freq --out $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.FREQ
# $SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR --memory 168960 --missing --out $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.MISSING
# $SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.shortINDELnames --memory 168960 --freq --out $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.shortINDELnames.FREQ
# $SOFTWARE/plink2 --bfile $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.shortINDELnames --memory 168960 --missing --out $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.shortINDELnames.MISSING
# echo ""
# echo ">-----------------------------------------------------------------------------------"
# echo "* STEP 7: Copying the new merged file to the MANTEL-resources directory."
# cp -v $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.bed /hpc/local/CentOS6/dhl_ec/software/MANTEL/RESOURCES/1000Gp3v5_EUR/
# cp -v $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.bim /hpc/local/CentOS6/dhl_ec/software/MANTEL/RESOURCES/1000Gp3v5_EUR/
# cp -v $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.fam /hpc/local/CentOS6/dhl_ec/software/MANTEL/RESOURCES/1000Gp3v5_EUR/
# cp -v $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.log /hpc/local/CentOS6/dhl_ec/software/MANTEL/RESOURCES/1000Gp3v5_EUR/
# cp -v $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.shortINDELnames.bed /hpc/local/CentOS6/dhl_ec/software/MANTEL/RESOURCES/1000Gp3v5_EUR/
# cp -v $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.shortINDELnames.bim /hpc/local/CentOS6/dhl_ec/software/MANTEL/RESOURCES/1000Gp3v5_EUR/
# cp -v $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.shortINDELnames.fam /hpc/local/CentOS6/dhl_ec/software/MANTEL/RESOURCES/1000Gp3v5_EUR/
# cp -v $PHASE3/PLINK_format/1000Gp3v5.20130502.EUR.shortINDELnames.log /hpc/local/CentOS6/dhl_ec/software/MANTEL/RESOURCES/1000Gp3v5_EUR/
# echo ""
# echo ">-----------------------------------------------------------------------------------"
# echo "Wow. I'm all done buddy. What a job! let's have a beer!"
# echo "Today's "`date`
# echo ">-----------------------------------------------------------------------------------"
# echo "All done. Let's have a beer buddy!"
# echo "Today's "`date`




