!#!/usr/bin/env bash

# Description
# An example script on how to extract a variant of interest.
# I am fascinated by rs12539895 on chr7:107091849 (b37).

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

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                        VCF Variant Extraction"
echo ""
echoitalic "* Written by  : Sander W. van der Laan"
echoitalic "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
echoitalic "* Last update : 2020-04-23"
echoitalic "* Version     : v1.0.0"
echo ""
echoitalic "* Description : This script will parse VCF-files from Michigan "
echoitalic "                Imputation Server and extract variant(s) of "
echoitalic "                interest."
echoitalic "                "

echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Today's: "$(date)
TODAY=$(date +"%Y%m%d")
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "The following directories are set."

### General settings
ORIGINALS="/hpc/dhl_ec/data/_ae_originals"

AEGS_COMBINED="${ORIGINALS}/AEGS_COMBINED_EAGLE2_1000Gp3v5HRCr11"

SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"
PLINK2="${SOFTWARE}/plink_v1.9"
QCTOOL2="${SOFTWARE}/qctool_v204"
SNPTEST2="${SOFTWARE}/snptest_v2.5.4beta3"
BCFTOOLS="${SOFTWARE}/bcftools_v1.6"

echo "Original data directory________ ${ORIGINALS}"
echo "Software directory_____________ ${SOFTWARE}"
echo "Where \"plink\" resides________ ${PLINK2}"
echo "Where \"qctool\" resides_______ ${QCTOOL2}"
echo "Where \"snptest\" resides______ ${SNPTEST2}"
echo "Where \"bcftools\" resides_____ ${BCFTOOLS}"
echo ""

echo ""
# First we create a list of variant(s)
touch ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.rs12539895.variants.list
echo 7:107091849 > ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.rs12539895.variants.list

# Next we extract the data into a new file format

# PLINK binary-style
${QCTOOL2} -g ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.vcf.gz -s ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.sample \
-ofiletype binary_ped \
-og ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.rs12539895 \
-incl-rsids ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.rs12539895.variants.list

# OXFORD format
${QCTOOL2} -g ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.vcf.gz -s ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.sample \
-og ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.rs12539895.gen -os ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.rs12539895.sample \
-incl-rsids ${AEGS_COMBINED}/aegs.qc.1kgp3hrcr11.chr7.rs12539895.variants.list

echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "Wow. I'm all done buddy. What a job! let's have a beer!"
date

script_copyright_message
