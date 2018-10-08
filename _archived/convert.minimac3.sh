#!/bin/bash

### Creating display functions
### Setting colouring
NONE='\033[00m'
BOLD='\033[1m'
FLASHING='\033[5m'
UNDERLINE='\033[4m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoerrorflash { 
    echo -e "${RED}${BOLD}${FLASHING}${1}${NONE}" 
}
function echoerror { 
    echo -e "${RED}${1}${NONE}"
}
function echosucces { 
    echo -e "${YELLOW}${1}${NONE}"
}

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
	echoerror "$1" # Additional message
	echoerror "- Argument #1 is path_to/ the configuration file."
	echoerror ""
	echoerror "An example command would be: convert.minimac3.sh [arg1]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                                   CONVERT MINIMAC3 M3VCF-FORMAT TO OXFORD-FORMAT"
echobold ""
echobold "* Version:      v1.0.0"
echobold ""
echobold "* Last update:  2018-07-17"
echobold "* Written by:   Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan-2@umcutrecht.nl."
echobold "* Description:  This script will convert Minimac3 formatted VCF-files (M3VCF) to Oxford-style formats "
echobold "                using PLINK2 alpha."
echoitalic "              After that it will calculate summary statistics for the samples and the variants."
echobold ""
echobold "* REQUIRED: "
echobold "  - A high-performance computer cluster with a qsub system"
echobold "  - R v3.2+, Python 2.7+, Perl."
echobold "  - Required Python 2.7+ modules: [pandas], [scipy], [numpy]."
echobold "  - Required Perl modules: [YAML], [Statistics::Distributions], [Getopt::Long]."
echobold "  - Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
### This might be a viable option! https://gist.github.com/JamieMason/4761049
echobold ""
echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

##########################################################################################
### SET THE SCENE FOR THE SCRIPT
##########################################################################################

### START of if-else statement for the number of command-line arguments passed ###
if [[ $# -lt 1 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [6] arguments when running *** META-ANALYZER OF GWAS -- MetaGWASToolKit ***!"
	script_arguments_error
else
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Processing arguments..."
	source ${1} # depends on arg1
	ROOTDIR=${ROOTDIR}
	PROJECTDIR=${PROJECTDIR} # depends on contents of arg1
	PROJECTNAME=${PROJECTNAME}
	FILEBASENAME=${FILEBASENAME}
	
	PLINK2MEMORY=${PLINK2MEMORY}
	PLINK2FORMAT=${PLINK2FORMAT}
	PLINK2FIELD=${PLINK2FIELD}
	
	QCTOOLMAPIDDATA=${QCTOOLMAPIDDATA}
	
	SCRIPTS=${HERCULESTOOLKITDIR} # depends on contents of arg1
	
	echo ""
	echo "All arguments are passed. These are the settings:"
	echo "Main project directory................................: "${PROJECTDIR}
	
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "We will start conversion now for each chromosome"
	
	echo ""
	### Make directories for script if they do not exist yet (!!!PREREQUISITE!!!)
	if [ ! -d ${PROJECTDIR}/minimac3_vcf/ ]; then
		mkdir -v ${PROJECTDIR}/minimac3_vcf/
	fi
	MINIMAC3_VCF=${PROJECTDIR}/minimac3_vcf
	
	echo ""
	for CHR in $(seq 1 22); do 
		echo "Processing chromosome [ ${CHR} ] ..."
	
		echo ""
		echo "- convert to .gen-format"
		echo "mv -v ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.vcf.gz ${MINIMAC3_VCF}/" > ${PROJECTDIR}/convert.minimac3.${PROJECTNAME}.chr${CHR}.sh
		echo "mv -v ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.vcf.gz.tbi ${MINIMAC3_VCF}/" > ${PROJECTDIR}/convert.minimac3.${PROJECTNAME}.chr${CHR}.sh
		echo "${PLINK2ALPHA} --vcf ${MINIMAC3_VCF}/${FILEBASENAME}.chr${CHR}.vcf.gz dosage=${PLINK2FIELD} --export ${PLINK2FORMAT} --out ${PROJECTDIR}/${FILEBASENAME}.chr${CHR} --debug --memory ${PLINK2MEMORY}" >> ${PROJECTDIR}/convert.minimac3.${PROJECTNAME}.chr${CHR}.sh
		qsub -S /bin/bash -N convert.minimac3.${PROJECTNAME}.chr${CHR} -e ${PROJECTDIR}/convert.minimac3.${PROJECTNAME}.chr${CHR}.errors -o ${PROJECTDIR}/convert.minimac3.${PROJECTNAME}.chr${CHR}.output -l h_rt=${QRUNTIME} -l h_vmem=${QMEM} -l tmpspace=${QTEMP} -M ${QMAIL} -m ${QMAILOPTIONS} -wd ${PROJECTDIR} ${PROJECTDIR}/convert.minimac3.${PROJECTNAME}.chr${CHR}.sh

		echo ""
		echo "- update variantIDs"
		echo "mv -v ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.gen ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.foo" > ${PROJECTDIR}/update.variantids.${PROJECTNAME}.chr${CHR}.sh
		echo "${QCTOOL2} -g ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.foo -og ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.gen.gz -map-id-data ${ROOTDIR}/${QCTOOLMAPIDDATA} " >> ${PROJECTDIR}/update.variantids.${PROJECTNAME}.chr${CHR}.sh
		echo "rm -v ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.foo" >> ${PROJECTDIR}/update.variantids.${PROJECTNAME}.chr${CHR}.sh
		qsub -S /bin/bash -N update.variantids.${PROJECTNAME}.chr${CHR} -hold_jid convert.minimac3.${PROJECTNAME}.chr${CHR} -e ${PROJECTDIR}/update.variantids.${PROJECTNAME}.chr${CHR}.errors -o ${PROJECTDIR}/update.variantids.${PROJECTNAME}.chr${CHR}.output -l h_rt=${QRUNTIMEQCTOOL} -l h_vmem=${QMEMQCTOOL} -M ${QMAIL} -m ${QMAILOPTIONS} -wd ${PROJECTDIR} ${PROJECTDIR}/update.variantids.${PROJECTNAME}.chr${CHR}.sh

		echo ""
		echo "- convert to .bgen"
		echo "${QCTOOL2} -g ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.gen.gz -og ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.bgen" > ${PROJECTDIR}/convert.gen2bgen.${PROJECTNAME}.chr${CHR}.sh
		qsub -S /bin/bash -N convert.gen2bgen.${PROJECTNAME}.chr${CHR} -hold_jid update.variantids.${PROJECTNAME}.chr${CHR} -e ${PROJECTDIR}/convert.gen2bgen.${PROJECTNAME}.chr${CHR}.errors -o ${PROJECTDIR}/convert.gen2bgen.${PROJECTNAME}.chr${CHR}.output -l h_rt=${QRUNTIMEQCTOOL} -l h_vmem=${QMEMQCTOOL} -M ${QMAIL} -m ${QMAILOPTIONS} -wd ${PROJECTDIR} ${PROJECTDIR}/convert.gen2bgen.${PROJECTNAME}.chr${CHR}.sh
		
		echo ""
		echo "- calculate sample statistics"
		echo "${QCTOOL2} -g ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.bgen -s ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.sample -sample-stats -osample ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.sample_stats.txt" > ${PROJECTDIR}/calculate.samplestats.${PROJECTNAME}.chr${CHR}.sh
		qsub -S /bin/bash -N calculate.samplestats.${PROJECTNAME}.chr${CHR} -hold_jid convert.gen2bgen.${PROJECTNAME}.chr${CHR} -e ${PROJECTDIR}/calculate.samplestats.${PROJECTNAME}.chr${CHR}.errors -o ${PROJECTDIR}/calculate.samplestats.${PROJECTNAME}.chr${CHR}.output -l h_rt=${QRUNTIMEQCTOOL} -l h_vmem=${QMEMQCTOOL} -M ${QMAIL} -m ${QMAILOPTIONS} -wd ${PROJECTDIR} ${PROJECTDIR}/calculate.samplestats.${PROJECTNAME}.chr${CHR}.sh
		
		echo ""
		echo "- calculate variant statistics"
		echo "${QCTOOL2} -g ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.bgen -s ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.sample -snp-stats -osnp ${PROJECTDIR}/${FILEBASENAME}.chr${CHR}.variant_stats.txt" > ${PROJECTDIR}/calculate.variantstats.${PROJECTNAME}.chr${CHR}.sh
		qsub -S /bin/bash -N calculate.variantstats.${PROJECTNAME}.chr${CHR} -hold_jid convert.gen2bgen.${PROJECTNAME}.chr${CHR} -e ${PROJECTDIR}/calculate.variantstats.${PROJECTNAME}.chr${CHR}.errors -o ${PROJECTDIR}/calculate.variantstats.${PROJECTNAME}.chr${CHR}.output -l h_rt=${QRUNTIMEQCTOOL} -l h_vmem=${QMEMQCTOOL} -M ${QMAIL} -m ${QMAILOPTIONS} -wd ${PROJECTDIR} ${PROJECTDIR}/calculate.variantstats.${PROJECTNAME}.chr${CHR}.sh
		
	done
	

### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message