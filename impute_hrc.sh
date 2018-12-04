#!/bin/bash
#
#$ -S /bin/bash 																			# the type of BASH you'd like to use
#$ -N IMPUTE_HRC  																	# the name of this script
# -hold_jid some_other_basic_bash_script  													# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/impute_hrc/impute_hrc.v2.2.0.v20171129.log  								# the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/impute_hrc/impute_hrc.v2.2.0.v20171129.errors 							# the error file of this job
#$ -l h_rt=04:00:00  																		# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=64G  																			#  h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
# -l tmpspace=64G  																		# this is the amount of temporary space you think your script will use
#$ -M s.w.vanderlaan-2@umcutrecht.nl  														# you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m beas  																					# you can choose: b=begin of job; e=end of job; a=abort of job; s=suspended job; n=no mail is send
#$ -cwd  																					# set the job start to the current directory - so all the things in this script are relative to the current directory!!!
#
# You can use the variables above (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

### Creating some function
function echobold { #'echobold' is the function name
    echo -e "\033[1m${1}\033[0m" # this is whatever the function needs to execute.
}
function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { #'echobold' is the function name
    echo -e "\033[3m${1}\033[0m" # this is whatever the function needs to execute.
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
	echoerror "An example command would be: gwastoolkit.analyzer.sh [arg1: VARIANT/REGION/GWAS] [arg2: AEGS/AAAGS/CTMM] [arg3: reference_to_use [1kGp3v5GoNL5/1kGp1v3/GoNL4] ] [arg4: SCORE/EXPECTED] [arg5: which_exclusion_list] [arg6: path_to_phenotype_file ] [arg7: path_to_covariates_file ] [arg8: path_to_project] [arg9: job_memory] [arg10: job_time] [arg11: your_email@domain.com] [arg12: mailsettings] [arg13: chromosome] [arg14: range] [arg15: standardize [STANDARDIZE/RAW]]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
  	exit 1
}
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                      MICHIGAN IMPUTATION SERVER PREPARATOR"
echo ""
echoitalic "* Written by  : Sander W. van der Laan"
echoitalic "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
echoitalic "* Last update : 2018-12-04"
echoitalic "* Version     : 2.2.0"
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
	FILENAME="$3" # "aegs1_snp5brlmmp_b37_QCwithChrX"
	ORIGINALS="$4" # "/hpc/dhl_ec/data/_ae_originals"

	# Set this to your root
	ROOTDIR="$5" # "/hpc/dhl_ec/svanderlaan/projects/impute_hrc"

	# You needn't change this - this should all be present
	PROJECTDIR="${ROOTDIR}/PRE_IMP_CHECK"
	SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"
	QCTOOL15="${SOFTWARE}/qctool_v1.5-linux-x86_64-static/qctool"
	VCFTOOLS="${SOFTWARE}/vcftools-v0.1.14-10-g4491144/bin"
	BCFTOOLS="${SOFTWARE}/bcftools_v1.6"
	CHECKVCF="${SOFTWARE}/checkvcf"
	BGZIP16="${SOFTWARE}/bgzip_v1.6"
	TABIX16="${SOFTWARE}/tabix_v1.6"
	PLINK19="${SOFTWARE}/plink_v1.9"
	HRC1000GCHECK="${SOFTWARE}/wrayner_tools/HRC-1000G-check-bim.v4.2.9.pl"

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
	echo "* creating directories"
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

	echo "* downloading tool"
	### wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim.v4.2.5.zip -O ${WRAYNERTOOLS}/HRC-1000G-check-bim.v4.2.5.zip
	### wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.6.zip -O ${WRAYNERTOOLS}/HRC-1000G-check-bim.v4.2.6.zip
	### wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip -O ${WRAYNERTOOLS}/HRC-1000G-check-bim.v4.2.7.zip
	### echo "* unzipping tool"
	### cd ${WRAYNERTOOLS}
	### unzip -o ${WRAYNERTOOLS}/HRC-1000G-check-bim.v4.2.6.zip

	### Just a sanity check: is it there?
	ls -lh ${WRAYNERTOOLS}

	echo "* downloading references"
	### echo "  - downloading HRC release 1.1 2016, b37"
	### wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz  -O ${WRAYNERTOOLS_HRC}/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
	### ${WRAYNERTOOLS_HRC}
	### gunzip -v ${WRAYNERTOOLS_HRC}/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz

	### Just a sanity check: is it there?
	ls -lh ${WRAYNERTOOLS_HRC}

	### On our HPC this is also already done.
	echo "  - downloading 1000G phase 3 (combined), b37"
	### wget http://www.well.ox.ac.uk/~wrayner/tools/1000GP_Phase3_combined.legend.gz -O ${WRAYNERTOOLS_1KGP3}/1000GP_Phase3_combined.legend.gz
	### ${WRAYNERTOOLS_1KGP3}
	### gunzip -v ${WRAYNERTOOLS_1KGP3}/1000GP_Phase3_combined.legend.gz

	ls -lh ${WRAYNERTOOLS_1KGP3}

	echobold "Installing checkVCF."
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
	cd ${IMPDATA_HRC}
	cp -fv ${ORIGINALS}/${FILENAME}.bed ${PROJECTDIR}
	cp -fv ${ORIGINALS}/${FILENAME}.bim ${PROJECTDIR}
	cp -fv ${ORIGINALS}/${FILENAME}.fam ${PROJECTDIR}
	${PLINK19} --bfile ${PROJECTDIR}/${FILENAME} --freq --out ${PROJECTDIR}/${FILENAME}_FREQ
	echo ""


	echo ""
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echobold "Checking PLINK files."
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
	cd ${PROJECTDIR}
	echo ""
	echo "* Checking AEGS1"
	cd ${AEGS1_HRC}
	perl ${WRAYNERTOOLS}/HRC-1000G-check-bim.pl -b ${PROJECTDIR}/${FILENAME}.bim -f ${IMPDATA_HRC}/${FILENAME}_FREQ.frq -r ${WRAYNERTOOLS_HRC}/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz -h -v
	cd ${AEGS1_1KGp3}
	perl ${WRAYNERTOOLS}/HRC-1000G-check-bim.pl -b ${PROJECTDIR}/${FILENAME}.bim -f ${IMPDATA_1KGp3}/${FILENAME}_FREQ.frq -r ${WRAYNERTOOLS_1KGP3}/1000GP_Phase3_combined.legend.gz -g -p ALL -v
	echo ""

	# echo ""
	# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	# echobold "Running PLINK-based corrections."
	# echo ""
	# echo "* Checking AEGS1"
	# cd ${IMPDATA_HRC}
	# bash Run-plink.sh 
	# cd ${IMPDATA_1KGp3}
	# bash Run-plink.sh 
	# echo ""

	# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	# echobold "Generating VCF files for HRC imputation."
	# echo ""
	# echo "* Making VCF for AEGS1"
	# cd ${IMPDATA_HRC}
	# for CHR in $(seq 1 23); do 
	# 	
	# 	echo ""
	# 	echo "- Converting"
	# 	${PLINK19} --bfile ${FILENAME}-updated-chr${CHR} --chr ${CHR} --output-chr MT --keep-allele-order --recode vcf-iid --out ${DATASETNAME}_inHRCr11_chr${CHR}
	# 	
	# 	echo ""
	# 	echo "- BGzipping and indexing"
	# 	${BGZIP16} ${DATASETNAME}_inHRCr11_chr${CHR}.vcf && ${TABIX16} -p vcf ${DATASETNAME}_inHRCr11_chr${CHR}.vcf.gz
	# 	
	# # 	skipped as it appears the above is suffice
	# # 	echo ""
	# # 	echo "- Checking chromosome ${CHR}"
	# # 	python ${CHECKVCF}/checkVCF.py -r ${CHECKVCF}/hs37d5.fa -o out ${DATASETNAME}_inHRCr11_chr${CHR}.vcf.gz
	# 	
	# done

	# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	# echobold "Generating VCF files for 1000G imputation."
	# echo ""
	# echo "* Making VCF for AEGS1"
	# cd ${IMPDATA_1KGp3}
	# for CHR in $(seq 1 23); do 
	# 	
	# 	echo ""
	# 	echo "- Converting"
	# 	${PLINK19} --bfile ${FILENAME}-updated-chr${CHR} --chr ${CHR} --output-chr MT --keep-allele-order --recode vcf-iid --out ${DATASETNAME}_in1KGp3_chr${CHR}
	# 	
	# 	echo ""
	# 	echo "- BGzipping and indexing"
	# 	${BGZIP16} ${DATASETNAME}_in1KGp3_chr${CHR}.vcf && ${TABIX16} -p vcf ${DATASETNAME}_in1KGp3_chr${CHR}.vcf.gz
	# 
	# done
	# # 
	# echo ""


	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echobold "Wow. I'm all done buddy. What a job! let's have a beer!"
	date

### END of if-else statement for the number of command-line arguments passed ###
fi

script_copyright_message

###	UtrechtSciencePark Colours Scheme
###
### Website to convert HEX to RGB: http://hex.colorrrs.com.
### For some functions you should divide these numbers by 255.
###
###	No.	Color				HEX		RGB							CMYK					CHR		MAF/INFO
### --------------------------------------------------------------------------------------------------------------------
###	1	yellow				#FBB820 (251,184,32)				(0,26.69,87.25,1.57) 	=>	1 		or 1.0 > INFO
###	2	gold				#F59D10 (245,157,16)				(0,35.92,93.47,3.92) 	=>	2		
###	3	salmon				#E55738 (229,87,56) 				(0,62.01,75.55,10.2) 	=>	3 		or 0.05 < MAF < 0.2 or 0.4 < INFO < 0.6
###	4	darkpink			#DB003F ((219,0,63)					(0,100,71.23,14.12) 	=>	4		
###	5	lightpink			#E35493 (227,84,147)				(0,63,35.24,10.98) 	=>	5 		or 0.8 < INFO < 1.0
###	6	pink				#D5267B (213,38,123)				(0,82.16,42.25,16.47) 	=>	6		
###	7	hardpink			#CC0071 (204,0,113)					(0,0,0,0) 	=>	7		
###	8	lightpurple			#A8448A (168,68,138)				(0,0,0,0) 	=>	8		
###	9	purple				#9A3480 (154,52,128)				(0,0,0,0) 	=>	9		
###	10	lavendel			#8D5B9A (141,91,154)				(0,0,0,0) 	=>	10		
###	11	bluepurple			#705296 (112,82,150)				(0,0,0,0) 	=>	11		
###	12	purpleblue			#686AA9 (104,106,169)				(0,0,0,0) 	=>	12		
###	13	lightpurpleblue		#6173AD (97,115,173/101,120,180)	(0,0,0,0) 	=>	13		
###	14	seablue				#4C81BF (76,129,191)				(0,0,0,0) 	=>	14		
###	15	skyblue				#2F8BC9 (47,139,201)				(0,0,0,0) 	=>	15		
###	16	azurblue			#1290D9 (18,144,217)				(0,0,0,0) 	=>	16		 or 0.01 < MAF < 0.05 or 0.2 < INFO < 0.4
###	17	lightazurblue		#1396D8 (19,150,216)				(0,0,0,0) 	=>	17		
###	18	greenblue			#15A6C1 (21,166,193)				(0,0,0,0) 	=>	18		
###	19	seaweedgreen		#5EB17F (94,177,127)				(0,0,0,0) 	=>	19		
###	20	yellowgreen			#86B833 (134,184,51)				(0,0,0,0) 	=>	20		
###	21	lightmossgreen		#C5D220 (197,210,32)				(0,0,0,0) 	=>	21		
###	22	mossgreen			#9FC228 (159,194,40)				(0,0,0,0) 	=>	22		or MAF > 0.20 or 0.6 < INFO < 0.8
###	23	lightgreen			#78B113 (120,177,19)				(0,0,0,0) 	=>	23/X
###	24	green				#49A01D (73,160,29)					(0,0,0,0) 	=>	24/Y
###	25	grey				#595A5C (89,90,92)					(0,0,0,0) 	=>	25/XY	or MAF < 0.01 or 0.0 < INFO < 0.2
###	26	lightgrey			#A2A3A4	(162,163,164)				(0,0,0,0) 	=> 	26/MT
### --------------------------------------------------------------------------------------------------------------------

### REGARDING FUNCTIONS
### Creating display functions
### Setting colouring
### NONE='\033[00m'
### BOLD='\033[1m'
### OPAQUE='\033[2m'
### FLASHING='\033[5m'
### UNDERLINE='\033[4m'
### 
### RED='\033[01;31m'
### GREEN='\033[01;32m'
### YELLOW='\033[01;33m'
### PURPLE='\033[01;35m'
### CYAN='\033[01;36m'
### WHITE='\033[01;37m'
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

# for i in $(seq 0 5) 7 8 $(seq 30 37) $(seq 41 47) $(seq 90 97) $(seq 100 107) ; do 
# 	echo -e "\033["$i"mYou can change the font...\033[0m"; 
# done
