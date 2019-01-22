#!/bin/bash
#
#$ -S /bin/bash 																			# the type of BASH you'd like to use
#$ -N IMPUTE_HRC  																			# the name of this script
# -hold_jid some_other_basic_bash_script  													# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/impute_hrc/impute_hrc.v2.3.1.v20190117.log  			# the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/impute_hrc/impute_hrc.v2.3.1.v20190117.errors 		# the error file of this job
#$ -l h_rt=00:15:00  																		# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=8G  																			#  h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
# -l tmpspace=64G  																			# this is the amount of temporary space you think your script will use
#$ -M s.w.vanderlaan-2@umcutrecht.nl  														# you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m beas  																				# you can choose: b=begin of job; e=end of job; a=abort of job; s=suspended job; n=no mail is send
#$ -cwd  																					# set the job start to the current directory - so all the things in this script are relative to the current directory!!!
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
OPAQUE='\033[2m'
FLASHING='\033[5m'
BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
STRIKETHROUGH='\033[9m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { 
    echo -e "${ITALIC}${1}${NONE}" 
}
function echonooption { 
    echo -e "${OPAQUE}${RED}${1}${NONE}"
}
function echoerrorflash { 
    echo -e "${RED}${BOLD}${FLASHING}${1}${NONE}" 
}
function echoerror { 
    echo -e "${RED}${1}${NONE}"
}
# errors no option
function echoerrornooption { 
    echo -e "${YELLOW}${1}${NONE}"
}
function echoerrorflashnooption { 
    echo -e "${YELLOW}${BOLD}${FLASHING}${1}${NONE}"
}

### MESSAGE FUNCTIONS
script_copyright_message() {
	echo ""
	THISYEAR=$(date +'%Y')
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "+ The MIT License (MIT)                                                                                 +"
	echo "+ Copyright (c) 1979-${THISYEAR} Sander W. van der Laan                                                        +"
	echo "+                                                                                                       +"
	echo "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and     +"
	echo "+ associated documentation files (the \"Software\"), to deal in the Software without restriction,         +"
	echo "+ including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, +"
	echo "+ and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, +"
	echo "+ subject to the following conditions:                                                                  +"
	echo "+                                                                                                       +"
	echo "+ The above copyright notice and this permission notice shall be included in all copies or substantial  +"
	echo "+ portions of the Software.                                                                             +"
	echo "+                                                                                                       +"
	echo "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT     +"
	echo "+ NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                +"
	echo "+ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES  +"
	echo "+ OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN   +"
	echo "+ CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                            +"
	echo "+                                                                                                       +"
	echo "+ Reference: http://opensource.org.                                                                     +"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

script_arguments_error() {
	echoerror "$1" # ERROR MESSAGE
	echoerror "- Argument #1  Project name, could be 'Athero-ExpressGenomicsStudy1' ."
	echoerror "- Argument #2  Dataset name to create directories and intermediate files, could be 'AEGS1'."
	echoerror "- Argument #3  File name of input file, could be 'aegs1_snp5brlmmp_b37_QCwithChrX'."
	echoerror "- Argument #4  complete/path_to where the original data resides, could be '/hpc/dhl_ec/data/_ae_originals'."
	echoerror "- Argument #5  complete/path_to where the project directory is, could be '/hpc/dhl_ec/svanderlaan/projects/impute_hrc'."
	echoerror ""
	echoerror "An example command would be: impute_hrc.sh [arg1: Athero-ExpressGenomicsStudy1] [arg2: AEGS1] [arg3: aegs1_snp5brlmmp_b37_QCwithChrX ] [arg4: /hpc/dhl_ec/data/_ae_originals] [arg5: /hpc/dhl_ec/svanderlaan/projects/impute_hrc]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
  	exit 1
}
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                      MICHIGAN IMPUTATION SERVER PREPARATOR"
echo ""
echoitalic "* Written by  : Sander W. van der Laan"
echoitalic "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
echoitalic "* Last update : 2019-01-22"
echoitalic "* Version     : 2.3.5"
echo ""
echoitalic "* Description : This script will prepare files for imputation using HRC on the"
echoitalic "                Michigan Imputation Server. Based on the GLGC-GIANT protocol"
echoitalic "                revised version 2 20170317."
echoitalic "                "
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Today's: "$(date)
TODAY=$(date +"%Y%m%d")
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "The following directories are set."

if [[ $# -lt 5 ]]; then 
	echo "Oh, computer says no! Number of arguments found "$#"."
	script_arguments_error "You must supply [5] correct arguments when running a *** MICHIGAN IMPUTATION SERVER PREPARATOR ***!"

else
	
echo "All arguments are passed and correct. These are the settings:"

	# Set these as an argument for your study
	PROJECTNAME="$1" # "Athero-Express Genomics Study 1"
	DATASETNAME="$2" # "AEGS1"
	FILENAME="$3" # "aegs1_snp5brlmmp_b37_QCwithChrX", i.e. the original-dataset name
	ORIGINALS="$4" # "/hpc/dhl_ec/data/_ae_originals"

	# Set this to your root
	ROOTDIR="$5" # "/hpc/dhl_ec/svanderlaan/projects/impute_hrc"

	# You needn't change this - this should all be present
	if [ ! -d ${ROOTDIR}/PRE_IMP_CHECK/ ]; then
		mkdir -v ${ROOTDIR}/PRE_IMP_CHECK/
	fi
	PROJECTDIR="${ROOTDIR}/PRE_IMP_CHECK"
	
	# Software settings
	SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"
	QCTOOL15="${SOFTWARE}/qctool_v1.5-linux-x86_64-static/qctool"
	VCFTOOLS="${SOFTWARE}/vcftools-v0.1.14-10-g4491144/bin"
	BCFTOOLS="${SOFTWARE}/bcftools_v1.6"
	CHECKVCF="${SOFTWARE}/checkvcf"
	VCFSORT="${SOFTWARE}/vcftools-v0.1.14-10-g4491144/bin/vcf-sort"
	BGZIP16="${SOFTWARE}/bgzip_v1.6"
	TABIX16="${SOFTWARE}/tabix_v1.6"
	PLINK19="${SOFTWARE}/plink_v1.9"
	
	# QSUB settings
	QSUBTIME="01:00:00"
	QSUBMEM="8G"
	
	QSUBCHECKTIME="02:00:00"
	QSUBCHECKMEM="64G"
	
	QSUBMAIL="s.w.vanderlaan-2@umcutrecht.nl"
	QSUBMAILSETTING="a"

	echo "Original data directory_____________ ${ORIGINALS}"
	echo "Project directory___________________ ${PROJECTDIR}"
	echo "Software directory__________________ ${SOFTWARE}"
	echo "Where \"qctool\" resides____________ ${QCTOOL}"
	echo ""

	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echobold "Setting up the stage for the PLINK file checking."
	echo ""
	echobold "Making directories."
	## Make directories for script if they do not exist yet (!!!PREREQUISITE!!!)
	echo "* ${PROJECTNAME} [ ${DATASETNAME} ]"
	
	# directories to collect all the post-imputation-check data
	if [ ! -d ${PROJECTDIR}/${DATASETNAME}_HRC_r1_1_2016/ ]; then
		mkdir -v ${PROJECTDIR}/${DATASETNAME}_HRC_r1_1_2016/
	fi
	IMPDATA_HRC=${PROJECTDIR}/${DATASETNAME}_HRC_r1_1_2016
	
	if [ ! -d ${PROJECTDIR}/${DATASETNAME}_1000Gp3/ ]; then
		mkdir -v ${PROJECTDIR}/${DATASETNAME}_1000Gp3/
	fi
	IMPDATA_1KGp3=${PROJECTDIR}/${DATASETNAME}_1000Gp3

	echo ""
	echobold "Installing tools & references."
	echo "* Creating directories."
	if [ ! -d ${SOFTWARE}/wrayner_tools/ ]; then
		mkdir -v ${SOFTWARE}/wrayner_tools/
	fi
	WRAYNERTOOLS=${SOFTWARE}/wrayner_tools
	if [ ! -d ${WRAYNERTOOLS}/HRC_r1_1_2016/ ]; then
		mkdir -v ${WRAYNERTOOLS}/HRC_r1_1_2016/
	fi
	WRAYNERTOOLS_HRC=${WRAYNERTOOLS}/HRC_r1_1_2016
	if [ ! -d ${WRAYNERTOOLS}/1000GP_Phase3/ ]; then
		mkdir -v ${WRAYNERTOOLS}/1000GP_Phase3/
	fi
	WRAYNERTOOLS_1KGP3=${WRAYNERTOOLS}/1000GP_Phase3

	### On our HPC this is already done. Note that I had gotten a custom version from Rayner with 
	### that works on our system ("${SOFTWARE}/wrayner_tools/HRC-1000G-check-bim.v4.2.9.pl")

	echo "* Downloading tool -- do only once!!!"
	### wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim.v4.2.5.zip -O ${WRAYNERTOOLS}/HRC-1000G-check-bim.v4.2.5.zip
	### wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.6.zip -O ${WRAYNERTOOLS}/HRC-1000G-check-bim.v4.2.6.zip
	### wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip -O ${WRAYNERTOOLS}/HRC-1000G-check-bim.v4.2.7.zip
	### echo "* unzipping tool"
	### cd ${WRAYNERTOOLS}
	### unzip -o ${WRAYNERTOOLS}/HRC-1000G-check-bim.v4.2.6.zip

	### Just a sanity check: is it there?
	ls -lh ${WRAYNERTOOLS}

	# Setting Wrayner's CheckTool
	HRC1000GCHECK="${SOFTWARE}/wrayner_tools/HRC-1000G-check-bim.v4.2.9.pl"
		
		
	echo "* Downloading references -- do only once!!!"
	echo "  - Downloading HRC release 1.1 2016, b37."
	### wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz  -O ${WRAYNERTOOLS_HRC}/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
	### ${WRAYNERTOOLS_HRC}
	### gunzip -v ${WRAYNERTOOLS_HRC}/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz

	### Just a sanity check: is it there?
	ls -lh ${WRAYNERTOOLS_HRC}

	### On our HPC this is also already done.
	echo "  - Downloading 1000G phase 3 (combined), b37."
	### wget http://www.well.ox.ac.uk/~wrayner/tools/1000GP_Phase3_combined.legend.gz -O ${WRAYNERTOOLS_1KGP3}/1000GP_Phase3_combined.legend.gz
	### ${WRAYNERTOOLS_1KGP3}
	### gunzip -v ${WRAYNERTOOLS_1KGP3}/1000GP_Phase3_combined.legend.gz

	ls -lh ${WRAYNERTOOLS_1KGP3}

	echobold "Installing checkVCF -- do only once!!!"
	### RUN ONLY ONCE!!! 
	### On our HPC this is already done.
	### cd ${SOFTWARE}
	### mkdir -v checkvcf
	### cd checkvcf/
	### wget http://qbrc.swmed.edu/zhanxw/software/checkVCF/checkVCF-20140116.tar.gz
	### tar -zxvf checkVCF-20140116.tar.gz
	### rm -v checkVCF-20140116.tar.gz
	### samtools_v1.3 faidx hs37d5.fa
	### cd ..
	### chmod -Rv a+xrw checkvcf/


	echo ""
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echobold "Calculating frequencies."

	### HRC
	echo "* Frequencies in ${DATASETNAME}"
	cp -fv ${ORIGINALS}/${FILENAME}.bed ${IMPDATA_HRC}/${DATASETNAME}.postQC.bed
	cp -fv ${ORIGINALS}/${FILENAME}.bim ${IMPDATA_HRC}/${DATASETNAME}.postQC.bim
	cp -fv ${ORIGINALS}/${FILENAME}.fam ${IMPDATA_HRC}/${DATASETNAME}.postQC.fam
	
	cp -fv ${ORIGINALS}/${FILENAME}.bed ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.bed
	cp -fv ${ORIGINALS}/${FILENAME}.bim ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.bim
	cp -fv ${ORIGINALS}/${FILENAME}.fam ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.fam
	
	echo "${PLINK19} --bfile ${IMPDATA_HRC}/${DATASETNAME}.postQC --freq --out ${IMPDATA_HRC}/${DATASETNAME}.postQC_FREQ " > ${IMPDATA_HRC}/${DATASETNAME}.postQC.freq.sh
	qsub -S /bin/bash -N FREQ_HRC_MICHIMP -e ${IMPDATA_HRC}/${DATASETNAME}.postQC.freq.errors -o ${IMPDATA_HRC}/${DATASETNAME}.postQC.freq.log -l h_rt=${QSUBTIME} -l h_vmem=${QSUBMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_HRC} ${IMPDATA_HRC}/${DATASETNAME}.postQC.freq.sh
	
	echo "${PLINK19} --bfile ${IMPDATA_1KGp3}/${DATASETNAME}.postQC --freq --out ${IMPDATA_1KGp3}/${DATASETNAME}.postQC_FREQ " > ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.freq.sh
	
	qsub -S /bin/bash -N FREQ_1kG_MICHIMP -e ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.freq.errors -o ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.freq.log -l h_rt=${QSUBTIME} -l h_vmem=${QSUBMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_1KGp3} ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.freq.sh
	
	echo ""
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echobold "Checking PLINK files for [ ${DATASETNAME} ]."
	# Usage:
	# For HRC:
	# perl HRC-1000G-check-bim-v4.2.7.pl -b <bim file> -f <Frequency file> -r <Reference panel> -h [-v -t <allele frequency threshold -n]
	# 
	# For 1000G:
	# perl HRC-1000G-check-bim-v4.2.7.pl -b <bim file> -f <Frequency file> -r <Reference panel> -g -p <population> [-v -t <allele frequency threshold -n]
	# 
	# 
	# -b --bim          bim file         Plink format .bim file
	# -f --frequency    Frequency file   Plink format .frq allele frequency file, from plink --freq command
	# -r --ref          Reference panel  Reference Panel file, either 1000G or HRC
	# -h --hrc                           Flag to indicate Reference panel file given is HRC
	# -g --1000g                         Flag to indicate Reference panel file given is 1000G
	# -p --pop          Population       Population to check frequency against, 1000G only. Default ALL, options ALL, EUR, AFR, AMR, SAS, EAS
	# -v --verbose                       Optional flag to increase verbosity in the log file
	# -t --threshold    Freq threshold   Frequency difference to use when checking allele frequency of data set versus reference; default: 0.2; range: 0-1
	# -n --noexclude                     Optional flag to include all SNPs regardless of allele frequency differences, default is exclude based on -t threshold, overrides -t

	echo ""
	echo "* Checking for HRC imputation."
	cd ${IMPDATA_HRC}
	# old version: ${WRAYNERTOOLS}/HRC-1000G-check-bim.pl 
	echo "perl ${HRC1000GCHECK} -b ${IMPDATA_HRC}/${DATASETNAME}.postQC.bim -f ${IMPDATA_HRC}/${DATASETNAME}.postQC_FREQ.frq -r ${WRAYNERTOOLS_HRC}/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz -h -v " > ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcheck.sh
	qsub -S /bin/bash -N Check_HRC_MICHIMP -hold_jid FREQ_HRC_MICHIMP -e ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcheck.errors -o ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcheck.log -l h_rt=${QSUBCHECKTIME} -l h_vmem=${QSUBCHECKMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_HRC} ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcheck.sh
	
	echo ""
	echo "* Checking for 1000G imputation."
	cd ${IMPDATA_1KGp3}
	# old version: ${WRAYNERTOOLS}/HRC-1000G-check-bim.pl 
	echo "perl ${HRC1000GCHECK} -b ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.bim -f ${IMPDATA_1KGp3}/${DATASETNAME}.postQC_FREQ.frq -r ${WRAYNERTOOLS_1KGP3}/1000GP_Phase3_combined.legend.gz -g -p ALL -v " > ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcheck.sh
	qsub -S /bin/bash -N Check_1kG_MICHIMP -hold_jid FREQ_1kG_MICHIMP -e ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcheck.errors -o ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcheck.log -l h_rt=${QSUBCHECKTIME} -l h_vmem=${QSUBCHECKMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_1KGp3} ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcheck.sh

	echo ""
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echobold "Running PLINK-based corrections for [ ${DATASETNAME} ]."
	echo ""
	echo "* Correcting."
	cd ${IMPDATA_HRC}
	echo "bash ${IMPDATA_HRC}/Run-plink.sh \ " > ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcorr.sh
	qsub -S /bin/bash -N Corr_HRC_MICHIMP -hold_jid Check_HRC_MICHIMP -e ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcorr.errors -o ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcorr.log -l h_rt=${QSUBTIME} -l h_vmem=${QSUBMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_HRC} ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcorr.sh
	
	cd ${IMPDATA_1KGp3}
	echo "bash ${IMPDATA_1KGp3}/Run-plink.sh \ " > ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcorr.sh
	qsub -S /bin/bash -N Corr_1kG_MICHIMP -hold_jid Check_1kG_MICHIMP -e ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcorr.errors -o ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcorr.log -l h_rt=${QSUBTIME} -l h_vmem=${QSUBMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_1KGp3} ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcorr.sh

	echo ""
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echobold "Generating VCF files for HRC imputation of [ ${DATASETNAME} ]."
	echo ""
	echo "* Making VCF."
	cd ${IMPDATA_HRC}
	for CHR in $(seq 1 23); do 
		
		echo ""
		echo "- Converting"
		echo "${PLINK19} --bfile ${IMPDATA_HRC}/${DATASETNAME}.postQC-updated-chr${CHR} --chr ${CHR} --output-chr MT --keep-allele-order --recode vcf-iid --out ${IMPDATA_HRC}/${DATASETNAME}.postQC_inHRCr11_chr${CHR} " > ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCconvert.sh
		qsub -S /bin/bash -N Convert_HRC_MICHIMP -hold_jid Corr_HRC_MICHIMP -e ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCconvert.errors -o ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCconvert.log -l h_rt=${QSUBTIME} -l h_vmem=${QSUBMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_HRC} ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCconvert.sh
		
		echo ""
		echo "- BGzipping and indexing"
		echo "${VCFSORT} ${IMPDATA_HRC}/${DATASETNAME}.postQC_inHRCr11_chr${CHR}.vcf | ${BGZIP16} ${IMPDATA_HRC}/${DATASETNAME}.postQC_inHRCr11_chr${CHR}.vcf " > ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCindexzip.sh
		echo "${TABIX16} -p vcf ${IMPDATA_HRC}/${DATASETNAME}.postQC_inHRCr11_chr${CHR}.vcf.gz " >> ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCindexzip.sh
		qsub -S /bin/bash -N Index_HRC_MICHIMP -hold_jid Convert_HRC_MICHIMP -e ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCindexzip.errors -o ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCindexzip.log -l h_rt=${QSUBTIME} -l h_vmem=${QSUBMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_HRC} ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCindexzip.sh
	
	done

	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echobold "Generating VCF files for 1000G imputation of [ ${DATASETNAME} ]."
	echo ""
	echo "* Making VCF."
	cd ${IMPDATA_1KGp3}
	for CHR in $(seq 1 23); do 
	
		echo ""
		echo "${PLINK19} --bfile ${IMPDATA_1KGp3}/${DATASETNAME}.postQC-updated-chr${CHR} --chr ${CHR} --output-chr MT --keep-allele-order --recode vcf-iid --out ${IMPDATA_1KGp3}/${DATASETNAME}.postQC_in1KGp3_chr${CHR} " > ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGconvert.sh
		qsub -S /bin/bash -N Convert_1kG_MICHIMP -hold_jid Corr_1kG_MICHIMP -e ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGconvert.errors -o ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGconvert.log -l h_rt=${QSUBTIME} -l h_vmem=${QSUBMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_1KGp3} ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGconvert.sh
		
		echo ""
		echo "- BGzipping and indexing"
		echo "${VCFSORT} ${IMPDATA_1KGp3}/${DATASETNAME}.postQC_in1KGp3_chr${CHR}.vcf | ${BGZIP16} ${IMPDATA_1KGp3}/${DATASETNAME}.postQC_in1KGp3_chr${CHR}.vcf " > ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGindexzip.sh
		echo "${TABIX16} -p vcf ${IMPDATA_1KGp3}/${DATASETNAME}.postQC_in1KGp3_chr${CHR}.vcf.gz " >> ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGindexzip.sh
		qsub -S /bin/bash -N Index_1kG_MICHIMP -hold_jid Convert_1kG_MICHIMP -e ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGindexzip.errors -o ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGindexzip.log -l h_rt=${QSUBTIME} -l h_vmem=${QSUBMEM} -M ${QSUBMAIL} -m ${QSUBMAILSETTING} -wd ${IMPDATA_1KGp3} ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGindexzip.sh
	
	done

# 	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# 	echobold "Checking outputs." 
# 	### NOT FINISHED YET
# 	### - make it automatic
# 	### - make it write a report
# 	### - get in if-else statements, if error > do not remove etc files
# 	
# 	
# 	if [ ! -d ${IMPDATA_HRC}/_scripts_logs ]; then
# 		mkdir -v ${IMPDATA_HRC}/_scripts_logs
# 	fi
# 	SCRIPTLOGDIR_HRC="${IMPDATA_HRC}/_scripts_logs"
# 	
# 	if [ ! -d ${IMPDATA_1KGp3}/_scripts_logs ]; then
# 		mkdir -v ${IMPDATA_1KGp3}/_scripts_logs
# 	fi
# 	SCRIPTLOGDIR_1KGp3="${IMPDATA_1KGp3}/_scripts_logs"
# 	
# 	echo ""
# 	echoitalic "Frequencies calculations"
# 	cat ${IMPDATA_HRC}/${DATASETNAME}.postQC.freq.log | grep -e "--freq: Allele frequencies (founders only) written to"
# 	mv -v ${IMPDATA_HRC}/${DATASETNAME}.postQC.freq.* ${SCRIPTLOGDIR_HRC}/
# 	
# 	cat ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.freq.log | grep -e "--freq: Allele frequencies (founders only) written to"
# 	mv -v ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.freq.* ${SCRIPTLOGDIR_1KGp3}/
# 	
# 	echo ""
# 	echoitalic "Genotype checking"
# 	tail -30 ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcheck.log
# 	cat ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcorr.log | grep -e "people pass filters and QC."
# 	mv -v ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcheck.* ${SCRIPTLOGDIR_HRC}/
# 	mv -v ${IMPDATA_HRC}/${DATASETNAME}.postQC.HRCcorr.* ${SCRIPTLOGDIR_HRC}/
# 	
# 	tail -30 ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcheck.log
# 	cat ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcorr.log | grep -e "people pass filters and QC."
# 	mv -v ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcheck.* ${SCRIPTLOGDIR_1KGp3}/
# 	mv -v ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.1kGcorr.* ${SCRIPTLOGDIR_1KGp3}/
# 	
# 	echo ""
# 	echoitalic "PLINK corrections"
# 	echo "checking temporary files"
# 	for FILENO in $(seq 1 4); do 	
# 		cat ${IMPDATA_HRC}/TEMP${FILENO}.log | grep -e "people pass filters and QC."
# 		rm -v ${IMPDATA_HRC}/TEMP${FILENO}.*
# 		cat ${IMPDATA_1KGp3}/TEMP${FILENO}.log | grep -e "people pass filters and QC."
# 		rm -v ${IMPDATA_1KGp3}/TEMP${FILENO}.*			
# 	done
# 	
# 	for CHR in $(seq 1 23); do 
# 		echo "checking updated files for chromosome ${CHR}"
# 		cat ${IMPDATA_HRC}/${DATASETNAME}.postQC-updated-chr${CHR}.log | grep -e "Total genotyping rate is"
# 		cat ${IMPDATA_1KGp3}/${DATASETNAME}.postQC-updated-chr${CHR}.log | grep -e "Total genotyping rate is"
# 
# 	done
# 	
# 	echo ""
# 	echoitalic "VCF conversion"
# 	for CHR in $(seq 1 23) ; do 
# 		echo "checking conversion of chromosome $CHR"
# 		cat ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCconvert.log | grep -e "pass filters and QC."
# 		mv -v ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCconvert.* ${SCRIPTLOGDIR_HRC}/
# 		cat ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGconvert.log | grep -e "pass filters and QC."
# 		mv -v ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGconvert.* ${SCRIPTLOGDIR_1KGp3}/ 
# 	done
# 	
# 	echo ""
# 	echoitalic "- VCF indexing and bzgipping"
# 	for CHR in $(seq 1 23) ; do 
# 		echo "checking conversion of chromosome $CHR"
# 		cat ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCindexzip.log | grep -e "pass filters and QC."
# 		mv -v ${IMPDATA_HRC}/${DATASETNAME}.postQC.chr${CHR}.HRCindexzip.* ${SCRIPTLOGDIR_HRC}/
# 		cat ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGindexzip.log | grep -e "pass filters and QC."
# 		mv -v ${IMPDATA_1KGp3}/${DATASETNAME}.postQC.chr${CHR}.1kGindexzip.* ${SCRIPTLOGDIR_1KGp3}/ 
# 	done
# 
# # 	echo ""
# # 	echoitalic "- gzipping the txt-file-shizzle"
# # 
#  
	echo ""
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echobold "Wow. I'm all done buddy. What a job! let's have a beer!"
	date

### END of if-else statement for the number of command-line arguments passed ###
fi

script_copyright_message


# mich_imp_prep HELPFul_GSA HELPFul_GSA helpful.gsa.clean /hpc/dhl_ec/data/_helpful_originals/GENOTYPES2018 /hpc/dhl_ec/svanderlaan/projects/impute_hrc
# mich_imp_prep MYOMARKER_GSA MYOMARKER_GSA myomarker.gsa.clean /hpc/dhl_ec/data/_myomarker_originals/GENOTYPES2018 /hpc/dhl_ec/svanderlaan/projects/impute_hrc
# mich_imp_prep UCORBIO_GSA UCORBIO_GSA ucorbio.gsa.clean /hpc/dhl_ec/data/_ucorbio_originals/GENOTYPES2018 /hpc/dhl_ec/svanderlaan/projects/impute_hrc
# mich_imp_prep BIOSHIFTTRIUMPH_GSA BIOSHIFTTRIUMPH_GSA bioshifttriumph.gsa.clean /hpc/dhl_ec/data/_bioshift_triumph_originals/GENOTYPES2018 /hpc/dhl_ec/svanderlaan/projects/impute_hrc
# mich_imp_prep RIVM_GSA RIVM_GSA rivm.gsa.clean /hpc/dhl_ec/data/_rivm_originals/GENOTYPES2018 /hpc/dhl_ec/svanderlaan/projects/impute_hrc
# mich_imp_prep AEGS1_AFFYSNP5 AEGS1_AFFYSNP5 AEGS1.clean /hpc/dhl_ec/data/_ae_originals/AEGS1_AffySNP5/GENOTYPES2018 /hpc/dhl_ec/svanderlaan/projects/impute_hrc
# mich_imp_prep AEGS2_AFFYAXIOMCEU AEGS2_AFFYAXIOMCEU AEGS2.clean /hpc/dhl_ec/data/_ae_originals/AEGS2_AffyAxiomGWCEU1/GENOTYPES2018 /hpc/dhl_ec/svanderlaan/projects/impute_hrc
# mich_imp_prep AEGS3_GSA AEGS3_GSA aegs3.gsa.clean /hpc/dhl_ec/data/_ae_originals/AEGS3_GSA/GENOTYPES2018 /hpc/dhl_ec/svanderlaan/projects/impute_hrc
