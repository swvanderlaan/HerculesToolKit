#!/bin/bash
#

#$ -S /bin/bash 																			# the type of BASH you'd like to use
#$ -N get.info  																	# the name of this script
# -hold_jid some_other_basic_bash_script  													# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/data/UPDATE_VARIANTIDs/get.info.log  								# the log file of this job
#$ -e /hpc/dhl_ec/data/UPDATE_VARIANTIDs/get.info.errors 							# the error file of this job
#$ -l h_rt=24:00:00  																		# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=64G  																			#  h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
# -l tmpspace=64G  																		# this is the amount of temporary space you think your script will use
#$ -M s.w.vanderlaan-2@umcutrecht.nl  														# you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m ea  																					# you can choose: b=begin of job; e=end of job; a=abort of job; s=suspended job; n=no mail is send
#$ -cwd  																					# set the job start to the current directory - so all the things in this script are relative to the current directory!!!
#
### INTERACTIVE SHELLS
# You can also schedule an interactive shell, e.g.:
#
# qlogin -N "basic_bash_script" -l h_rt=02:00:00 -l h_vmem=24G -M s.w.vanderlaan-2@umcutrecht.nl -m ea
#
# You can use the variables above (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

### Creating display functions
### Setting colouring
NONE='\033[00m'
BOLD='\033[1m'
OPAQUE='\033[2m'
FLASHING='\033[5m'
UNDERLINE='\033[4m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
### Regarding changing the 'type' of the things printed with 'echo'
### Refer to: 
### - http://askubuntu.com/questions/528928/how-to-do-underline-bold-italic-strikethrough-color-background-and-size-i
### - http://misc.flogisoft.com/bash/tip_colors_and_formatting
### - http://unix.stackexchange.com/questions/37260/change-font-in-echo-command

### echo -e "\033[1mbold\033[0m"
### echo -e "\033[3mitalic\033[0m" ### THIS DOESN'T WORK ON MAC!
### echo -e "\033[4munderline\033[0m"
### echo -e "\033[9mstrikethrough\033[0m"
### echo -e "\033[31mHello World\033[0m"
### echo -e "\x1B[31mHello World\033[0m"

function echocyan { #'echobold' is the function name
    echo -e "${CYAN}${1}${NONE}" # this is whatever the function needs to execute.
}
function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { #'echobold' is the function name
    echo -e "\033[3m${1}\033[0m" # this is whatever the function needs to execute.
}
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echocyan "                    CREATE NEW VARIANTID MAPPING FILES"
echo ""
echoitalic "* Written by  : Sander W. van der Laan"
echoitalic "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
echoitalic "* Last update : 2018-08-22"
echoitalic "* Version     : v1.1.0"
echo ""
echoitalic "* Description : This script get data from the .info-files and creates new  "
echoitalic "                variantID map-files to remap the variantIDs after imputation "
echoitalic "                using the Michigan Imputation Server."
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Today's: "$(date)
TODAY=$(date +"%Y%m%d")
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

# HPC

DATADIR="/hpc/dhl_ec/data"
AAAGS_1kG_DIR="${DATADIR}/_aaa_originals/AAAGS_EAGLE2_1000Gp3"
AAAGS_HRC_DIR="${DATADIR}/_aaa_originals/AAAGS_EAGLE2_HRC_r11_2016"

AEGS1_1kG_DIR="${DATADIR}/_ae_originals/AEGS1_AffySNP5/AEGS1_MICHIMP_1000Gp3"
AEGS1_HRC_DIR="${DATADIR}/_ae_originals/AEGS1_AffySNP5/AEGS1_MICHIMP_HRC_r1_1_2016"

AEGS2_1kG_DIR="${DATADIR}/_ae_originals/AEGS2_AffyAxiomGWCEU1/AEGS2_MICHIMP_1000Gp3"
AEGS2_HRC_DIR="${DATADIR}/_ae_originals/AEGS2_AffyAxiomGWCEU1/AEGS2_MICHIMP_HRC_r1_1_2016"

CTMMGS_1kG_DIR="${DATADIR}/_ctmm_originals/CTMMAxiomTX_EAGLE2_1000Gp3"
CTMMGS_HRC_DIR="${DATADIR}/_ctmm_originals/CTMMAxiomTX_EAGLE2_HRC_r11_2016"

UPDATEVARIANTSDIR="${DATADIR}/UPDATE_VARIANTIDs"

SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"
METAGWASTOOLKITDIR="${SOFTWARE}/MetaGWASToolKit"

QTIME="00:15:00"
QMEM="8G"
QMAIL="s.w.vanderlaan-2@umcutrecht.nl"
QMAILSETTINGS="ea"

# echo ""
# echobold "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echobold "Creating lists of RSIDs from dbSNP and 1000G."
# 
# # echo ""
# # echoitalic "* dbSNP v150, hg19"
# # zcat ${METAGWASTOOLKITDIR}/RESOURCES/dbSNP150_GRCh37_hg19_Feb2009.allVariants.txt.gz | awk ' $12 == "single" ' |  sed 's/chr//g' | awk ' { print $5, $2, $4  } ' > ${UPDATEVARIANTSDIR}/dbSNP150.foo
# # echo "RSID CHR BP" > ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.single.txt
# # cat ${UPDATEVARIANTSDIR}/dbSNP150.foo >> ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.single.txt
# # rm -v ${UPDATEVARIANTSDIR}/dbSNP150.foo
# 
# echoitalic "* dbSNP v150, hg19 - singletons, i.e. variants, only "
# echo "SNPID RSID_new" > ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.4UpdateMichImp.txt
# cat ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.single.txt | awk '{ print $2":"$3, $1 }' | tail -n +2 >> ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.4UpdateMichImp.txt
# 
# echo ""
# echoitalic "Getting a head and count ..."
# head ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.4UpdateMichImp.txt
# tail ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.4UpdateMichImp.txt
# cat ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.4UpdateMichImp.txt | wc -l
# 
# echo ""
# echoitalic "* 1000G phase 1, version 3"
# echo "SNPID RSID_new" > ${UPDATEVARIANTSDIR}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt
# zcat ${METAGWASTOOLKITDIR}/RESOURCES/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz | grep -v "##" | \
# awk ' { if($3 == ".") { print $1":"$2, $1":"$2 } else { print $1":"$2, $3 } } ' | tail -n +2 >> ${UPDATEVARIANTSDIR}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt
# 
# echo ""
# echoitalic "Getting a head and count ..."
# head ${UPDATEVARIANTSDIR}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt
# tail ${UPDATEVARIANTSDIR}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt
# cat ${UPDATEVARIANTSDIR}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt | wc -l
# 
# echo ""
# echoitalic "* 1000G phase 3, version 5b"
# echo "SNPID RSID_new" > ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt
# zcat ${METAGWASTOOLKITDIR}/RESOURCES/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz | grep -v "##" | \
# awk ' { if($3 == ".") { print $1":"$2, $1":"$2 } else { print $1":"$2, $3 } } ' | tail -n +2 >> ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt
# 
# echo ""
# echoitalic "Getting a head and count ..."
# head ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt
# tail ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt
# cat ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.txt | wc -l
# 
# 
# for CHR in $(seq 1 22); do 
# 	
# 	echobold "Processing [ chromosome $CHR ] ..."
# 	echo ""
# 	echoitalic "* dbSNP v150, hg19"
# 	echo "SNPID RSID_new" > ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.4update.chr${CHR}.txt
# 	cat ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.single.txt | awk ' $2 == '$CHR' ' | awk '{ print $2":"$3, $1 }' >> ${UPDATEVARIANTSDIR}/dbSNP150_GRCh37_hg19_Feb2009.4update.chr${CHR}.txt
# 
# 	echo ""
# 	echoitalic "* 1000G phase 1, version 3"
# 	echo "SNPID RSID_new" > ${UPDATEVARIANTSDIR}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt
# 	zcat ${METAGWASTOOLKITDIR}/RESOURCES/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz | grep -v "##" | \
# 	awk ' $1 == '$CHR' ' | awk ' { if($3 == ".") { print $1":"$2, $1":"$2 } else { print $1":"$2, $3 } } ' >> ${UPDATEVARIANTSDIR}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt
# 
# 	echo ""
# 	echoitalic "* 1000G phase 3, version 5b"
# 	echo "SNPID RSID_new" > ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt
# 	zcat ${METAGWASTOOLKITDIR}/RESOURCES/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz | grep -v "##" | \
# 	awk ' $1 == '$CHR' ' | awk ' { if($3 == ".") { print $1":"$2, $1":"$2 } else { print $1":"$2, $3 } } ' >> ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt
# 
# done

echo ""
echobold "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "Processing each dataset and extracting information for map-id update."

for CHR in $(seq 1 22); do 
	echobold "Processing [ chromosome $CHR ]..."
	echoitalic "* [ ctmmgs-1kgp3 ] "
	echo "SNPID RSID CHR POS REF ALT SNPID_new RSID_new CHR_new POS_new REF_new ALT_new" > ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.info.4update.chr${CHR}.temp
	zcat ${CTMMGS_1kG_DIR}/ctmmgs.1kgp3.info.txt.gz | awk -F: '{ print $1, $2}' | awk '{ print $1":"$2, $1":"$2, $1, $2, $3, $4, $1":"$2, $1":"$2, $1, $2, $3, $4 }' | awk '$3 == '$CHR'' | tail -n +2 >> ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.info.4update.chr${CHR}.temp
	echoitalic "* [ ctmmgs-hrc_r11_2016 ] "
	echo "SNPID RSID CHR POS REF ALT SNPID_new RSID_new CHR_new POS_new REF_new ALT_new" > ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.info.4update.chr${CHR}.temp
	zcat ${CTMMGS_HRC_DIR}/ctmmgs.hrc_r11_2016.info.txt.gz | awk -F: '{ print $1, $2}' | awk '{ print $1":"$2, $1":"$2, $1, $2, $3, $4, $1":"$2, $1":"$2, $1, $2, $3, $4 }' | awk '$3 == '$CHR'' | tail -n +2 >> ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.info.4update.chr${CHR}.temp

	echoitalic "* [ aaags-1kgp3 ] "
	echo "SNPID RSID CHR POS REF ALT SNPID_new RSID_new CHR_new POS_new REF_new ALT_new" > ${UPDATEVARIANTSDIR}/aaags.1kgp3.info.4update.chr${CHR}.temp
	zcat ${AAAGS_1kG_DIR}/aaags.1kgp3.info.txt.gz | awk -F: '{ print $1, $2}' | awk '{ print $1":"$2, $1":"$2, $1, $2, $3, $4, $1":"$2, $1":"$2, $1, $2, $3, $4 }' | awk '$3 == '$CHR'' | tail -n +2 >> ${UPDATEVARIANTSDIR}/aaags.1kgp3.info.4update.chr${CHR}.temp
	echoitalic "* [ aaags-hrc_r11_2016 ] "
	echo "SNPID RSID CHR POS REF ALT SNPID_new RSID_new CHR_new POS_new REF_new ALT_new" > ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.info.4update.chr${CHR}.temp
	zcat ${AAAGS_HRC_DIR}/aaags.hrc_r11_2016.info.txt.gz | awk -F: '{ print $1, $2}' | awk '{ print $1":"$2, $1":"$2, $1, $2, $3, $4, $1":"$2, $1":"$2, $1, $2, $3, $4 }' | awk '$3 == '$CHR'' | tail -n +2 >> ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.info.4update.chr${CHR}.temp

	echoitalic "* [ aegs1-1kgp3 ] "
	echo "SNPID RSID CHR POS REF ALT SNPID_new RSID_new CHR_new POS_new REF_new ALT_new" > ${UPDATEVARIANTSDIR}/aegs1.1kgp3.info.4update.chr${CHR}.temp
	zcat ${AEGS1_1kG_DIR}/aegs1.1kgp3.info.txt.gz | awk -F: '{ print $1, $2}' | awk '{ print $1":"$2, $1":"$2, $1, $2, $3, $4, $1":"$2, $1":"$2, $1, $2, $3, $4 }' | awk '$3 == '$CHR'' | tail -n +2 >> ${UPDATEVARIANTSDIR}/aegs1.1kgp3.info.4update.chr${CHR}.temp
	echoitalic "* [ aegs1-hrc_r11_2016 ] "
	echo "SNPID RSID CHR POS REF ALT SNPID_new RSID_new CHR_new POS_new REF_new ALT_new" > ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.info.4update.chr${CHR}.temp
	zcat ${AEGS1_HRC_DIR}/aegs1.hrc_r11_2016.info.txt.gz | awk -F: '{ print $1, $2}' | awk '{ print $1":"$2, $1":"$2, $1, $2, $3, $4, $1":"$2, $1":"$2, $1, $2, $3, $4 }' | awk '$3 == '$CHR'' | tail -n +2 >> ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.info.4update.chr${CHR}.temp

	echoitalic "* [ aegs2-1kgp3 ] "
	echo "SNPID RSID CHR POS REF ALT SNPID_new RSID_new CHR_new POS_new REF_new ALT_new" > ${UPDATEVARIANTSDIR}/aegs2.1kgp3.info.4update.chr${CHR}.temp
	zcat ${AEGS2_1kG_DIR}/aegs2.1kgp3.info.txt.gz | awk -F: '{ print $1, $2}' | awk '{ print $1":"$2, $1":"$2, $1, $2, $3, $4, $1":"$2, $1":"$2, $1, $2, $3, $4 }' | awk '$3 == '$CHR'' | tail -n +2 >> ${UPDATEVARIANTSDIR}/aegs2.1kgp3.info.4update.chr${CHR}.temp
	echoitalic "* [ aegs2-hrc_r11_2016 ] "
	echo "SNPID RSID CHR POS REF ALT SNPID_new RSID_new CHR_new POS_new REF_new ALT_new" > ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.info.4update.chr${CHR}.temp
	zcat ${AEGS2_HRC_DIR}/aegs2.hrc_r11_2016.info.txt.gz | awk -F: '{ print $1, $2}' | awk '{ print $1":"$2, $1":"$2, $1, $2, $3, $4, $1":"$2, $1":"$2, $1, $2, $3, $4 }' | awk '$3 == '$CHR'' | tail -n +2 >> ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.info.4update.chr${CHR}.temp
done
echo ""
echobold "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "Merging the shizzle into new update-files."

### Usage: %>mergeTables.pl --file1 datafile_1 --file2 datafile_2 --index index_string --format [GZIP1/GZIP2/GZIPB/NORM] [--replace]
### Prints all contents of datafile_2, each row is followed by the corresponding columns from datafile_1 (indexed on index_string).
### The argument --format indicates which of the files are gzipped.
### If --replace is specified, only the contents of datafile_2 are output with relevant elements replaced by those in datafile_1.

for CHR in $(seq 1 22); do 

	echobold "Processing [ chromosome $CHR ] ..."
	echoitalic "* [ ctmmgs-1kgp3 ] "
	${METAGWASTOOLKITDIR}/SCRIPTS/mergeTables.pl --file1 ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt \
	--file2 ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.info.4update.chr${CHR}.temp --index SNPID --format NORM --replace > ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.info.4update.chr${CHR}.txt
	echoitalic "* [ ctmmgs-hrc_r11_2016 ] "
	${METAGWASTOOLKITDIR}/SCRIPTS/mergeTables.pl --file1 ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt \
	--file2 ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.info.4update.chr${CHR}.temp --index SNPID --format NORM --replace > ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.info.4update.chr${CHR}.txt
 	
 	echo ""
 	echoitalic "Gzipping ..."
	gzip -fv ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.info.4update.chr${CHR}.txt
	gzip -fv ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.info.4update.chr${CHR}.txt
 	
 	echoitalic "* [ aaags-1kgp3 ] "
	${METAGWASTOOLKITDIR}/SCRIPTS/mergeTables.pl --file1 ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt \
	--file2 ${UPDATEVARIANTSDIR}/aaags.1kgp3.info.4update.chr${CHR}.temp --index SNPID --format NORM --replace > ${UPDATEVARIANTSDIR}/aaags.1kgp3.info.4update.chr${CHR}.txt
	echoitalic "* [ aaags-hrc_r11_2016 ] "
	${METAGWASTOOLKITDIR}/SCRIPTS/mergeTables.pl --file1 ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt \
	--file2 ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.info.4update.chr${CHR}.temp --index SNPID GZIP1 --format NORM --replace > ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.info.4update.chr${CHR}.txt
	
	echo ""
 	echoitalic "Gzipping ..."
 	gzip -fv ${UPDATEVARIANTSDIR}/aaags.1kgp3.info.4update.chr${CHR}.txt
	gzip -fv ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.info.4update.chr${CHR}.txt

 	echoitalic "* [ aegs1-1kgp3 ] "
	${METAGWASTOOLKITDIR}/SCRIPTS/mergeTables.pl --file1 ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt \
	--file2 ${UPDATEVARIANTSDIR}/aegs1.1kgp3.info.4update.chr${CHR}.temp --index SNPID --format NORM -replace > ${UPDATEVARIANTSDIR}/aegs1.1kgp3.info.4update.chr${CHR}.txt
	echoitalic "* [ aegs1-hrc_r11_2016 ] "
	${METAGWASTOOLKITDIR}/SCRIPTS/mergeTables.pl --file1 ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt \
	--file2 ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.info.4update.chr${CHR}.temp --index SNPID --format NORM --replace > ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.info.4update.chr${CHR}.txt
	
	echo ""
 	echoitalic "Gzipping ..."
 	gzip -fv ${UPDATEVARIANTSDIR}/aegs1.1kgp3.info.4update.chr${CHR}.txt
	gzip -fv ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.info.4update.chr${CHR}.txt

	echoitalic "* [ aegs2-1kgp3 ] "
	${METAGWASTOOLKITDIR}/SCRIPTS/mergeTables.pl --file1 ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt \
	--file2 ${UPDATEVARIANTSDIR}/aegs2.1kgp3.info.4update.chr${CHR}.temp --index SNPID --format NORM --replace > ${UPDATEVARIANTSDIR}/aegs2.1kgp3.info.4update.chr${CHR}.txt
	echoitalic "* [ aegs2-hrc_r11_2016 ] "
	${METAGWASTOOLKITDIR}/SCRIPTS/mergeTables.pl --file1 ${UPDATEVARIANTSDIR}/1000Gp3v5b_20130502_integrated_ALL_snv_indels_sv.4UpdateMichImp.chr${CHR}.txt \
	--file2 ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.info.4update.chr${CHR}.temp --index SNPID --format NORM --replace > ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.info.4update.chr${CHR}.txt
	
	echo ""
 	echoitalic "Gzipping ..."
 	gzip -fv ${UPDATEVARIANTSDIR}/aegs2.1kgp3.info.4update.chr${CHR}.txt
	gzip -fv ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.info.4update.chr${CHR}.txt
	
done
echo ""
# 
# 
# echo ""
# echobold "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echobold "Deleting the temporary shizzle."
# rm -v ${UPDATEVARIANTSDIR}/*.temp
# 
# echo ""
# echobold "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echobold "Splitting into chromosomes."
# 
# for CHR in $(seq 1 22); do
# 
# 	echo "* processing chromosome [ ${CHR} ] ..."
# 	
#  	echo ""
#  	echo "- study: CTMMGS ..."
#  	echo "zcat ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.info.4update.txt.gz | awk ' \$3 == \"$CHR\" || \$1 ==\"SNPID\" ' | awk '{ print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12 } ' > ${CTMMGS_1kG_DIR}/ctmmgs.1kgp3.chr${CHR}.IDupdate.txt" > ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.chr${CHR}.IDupdate.sh
#   	qsub -S /bin/bash -N ctmmgs.1kgp3.chr${CHR}.IDupdate -e ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.chr${CHR}.IDupdate.errors -o ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.chr${CHR}.IDupdate.log -l h_rt=${QTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILSETTINGS} -wd ${UPDATEVARIANTSDIR} ${UPDATEVARIANTSDIR}/ctmmgs.1kgp3.chr${CHR}.IDupdate.sh
#   	
#   	echo "zcat ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.info.4update.txt.gz | awk ' \$3 == \"$CHR\" || \$1 ==\"SNPID\" ' | awk '{ print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12 } ' > ${CTMMGS_HRC_DIR}/ctmmgs.hrc_r11_2016.chr${CHR}.IDupdate.txt" > ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.chr${CHR}.IDupdate.sh
#  	qsub -S /bin/bash -N ctmmgs.hrc_r11_2016.chr${CHR}.IDupdate -e ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.chr${CHR}.IDupdate.errors -o ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.chr${CHR}.IDupdate.log -l h_rt=${QTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILSETTINGS} -wd ${UPDATEVARIANTSDIR} ${UPDATEVARIANTSDIR}/ctmmgs.hrc_r11_2016.chr${CHR}.IDupdate.sh
#   	
#   	echo ""
#   	echo "- study: AAAGS ..."	
#  	echo "zcat ${UPDATEVARIANTSDIR}/aaags.1kgp3.info.4update.txt.gz | awk ' \$3 == \"$CHR\" || \$1 ==\"SNPID\" ' | awk '{ print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12 } ' > ${AAAGS_1kG_DIR}/aaags.1kgp3.chr${CHR}.IDupdate.txt" > ${UPDATEVARIANTSDIR}/aaags.1kgp3.chr${CHR}.IDupdate.sh
#   	qsub -S /bin/bash -N aaags.1kgp3.chr${CHR}.IDupdate -e ${UPDATEVARIANTSDIR}/aaags.1kgp3.chr${CHR}.IDupdate.errors -o ${UPDATEVARIANTSDIR}/aaags.1kgp3.chr${CHR}.IDupdate.log -l h_rt=${QTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILSETTINGS} -wd ${UPDATEVARIANTSDIR} ${UPDATEVARIANTSDIR}/aaags.1kgp3.chr${CHR}.IDupdate.sh
#  
#   	echo "zcat ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.info.4update.txt.gz | awk ' \$3 == \"$CHR\" || \$1 ==\"SNPID\" ' | awk '{ print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12 } ' > ${AAAGS_HRC_DIR}/aaags.hrc_r11_2016.chr${CHR}.IDupdate.txt" > ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.chr${CHR}.IDupdate.sh
#  	qsub -S /bin/bash -N aaags.hrc_r11_2016.chr${CHR}.IDupdate -e ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.chr${CHR}.IDupdate.errors -o ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.chr${CHR}.IDupdate.log -l h_rt=${QTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILSETTINGS} -wd ${UPDATEVARIANTSDIR} ${UPDATEVARIANTSDIR}/aaags.hrc_r11_2016.chr${CHR}.IDupdate.sh
#   	
#  	echo ""
#  	echo "- study: AEGS1 ..."
#  	echo "zcat ${UPDATEVARIANTSDIR}/aegs1.1kgp3.info.4update.txt.gz | awk ' \$3 == \"$CHR\" || \$1 ==\"SNPID\" ' | awk '{ print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12 } ' > ${AEGS1_1kG_DIR}/aegs1.1kgp3.chr${CHR}.IDupdate.txt" > ${UPDATEVARIANTSDIR}/aegs1.1kgp3.chr${CHR}.IDupdate.sh
#  	qsub -S /bin/bash -N aegs1.1kgp3.chr${CHR}.IDupdate -e ${UPDATEVARIANTSDIR}/aegs1.1kgp3.chr${CHR}.IDupdate.errors -o ${UPDATEVARIANTSDIR}/aegs1.1kgp3.chr${CHR}.IDupdate.log -l h_rt=${QTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILSETTINGS} -wd ${UPDATEVARIANTSDIR} ${UPDATEVARIANTSDIR}/aegs1.1kgp3.chr${CHR}.IDupdate.sh
#  	
#  	echo "zcat ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.info.4update.txt.gz | awk ' \$3 == \"$CHR\" || \$1 ==\"SNPID\" ' | awk '{ print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12 } ' > ${AEGS1_HRC_DIR}/aegs1.hrc_r11_2016.chr${CHR}.IDupdate.txt" > ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.chr${CHR}.IDupdate.sh
# 	qsub -S /bin/bash -N aegs1.hrc_r11_2016.chr${CHR}.IDupdate -e ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.chr${CHR}.IDupdate.errors -o ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.chr${CHR}.IDupdate.log -l h_rt=${QTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILSETTINGS} -wd ${UPDATEVARIANTSDIR} ${UPDATEVARIANTSDIR}/aegs1.hrc_r11_2016.chr${CHR}.IDupdate.sh
#  	
#  	echo ""
#  	echo "- study: AEGS2 ..."
#  	echo "zcat ${UPDATEVARIANTSDIR}/aegs2.1kgp3.info.4update.txt.gz | awk ' \$3 == \"$CHR\" || \$1 ==\"SNPID\" ' | awk '{ print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12 } ' > ${AEGS2_1kG_DIR}/aegs2.1kgp3.chr${CHR}.IDupdate.txt" > ${UPDATEVARIANTSDIR}/aegs2.1kgp3.chr${CHR}.IDupdate.sh
#  	qsub -S /bin/bash -N aegs2.1kgp3.chr${CHR}.IDupdate -e ${UPDATEVARIANTSDIR}/aegs2.1kgp3.chr${CHR}.IDupdate.errors -o ${UPDATEVARIANTSDIR}/aegs2.1kgp3.chr${CHR}.IDupdate.log -l h_rt=${QTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILSETTINGS} -wd ${UPDATEVARIANTSDIR} ${UPDATEVARIANTSDIR}/aegs2.1kgp3.chr${CHR}.IDupdate.sh
#  	
#  	echo "zcat ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.info.4update.txt.gz | awk ' \$3 == \"$CHR\" || \$1 ==\"SNPID\" ' | awk '{ print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12 } ' > ${AEGS2_HRC_DIR}/aegs2.hrc_r11_2016.chr${CHR}.IDupdate.txt" > ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.chr${CHR}.IDupdate.sh
# 	qsub -S /bin/bash -N aegs2.hrc_r11_2016.chr${CHR}.IDupdate -e ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.chr${CHR}.IDupdate.errors -o ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.chr${CHR}.IDupdate.log -l h_rt=${QTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILSETTINGS} -wd ${UPDATEVARIANTSDIR} ${UPDATEVARIANTSDIR}/aegs2.hrc_r11_2016.chr${CHR}.IDupdate.sh
# 
# done

echo ""
echobold "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "Wow. I'm all done buddy. What a job! let's have a beer!"
date












