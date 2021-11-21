#!/bin/bash
#
# Description: SLURM job monitoring.
# 
# The MIT License (MIT)
# Copyright (c) 1979-2021, Sander W. van der Laan, UMC Utrecht, Utrecht, the Netherlands.
# 
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 

### Set text
### Reference #1: https://github.com/alrra/dotfiles/issues/19
### Reference #2: https://stackoverflow.com/questions/2924697/how-does-one-output-bold-text-in-bash/2924755
normal=$(tput sgr0)
bold=$(tput bold)
italic=$(tput italic)

black=$(tput setaf 0)
blue=$(tput setaf 33)
cyan=$(tput setaf 37)
green=$(tput setaf 64)
orange=$(tput setaf 166)
purple=$(tput setaf 125)
red=$(tput setaf 124)
white=$(tput setaf 15)
yellow=$(tput setaf 136)

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

### General settings
USER="svanderlaan"
BULK="/data/isi/d/dhl"
year="/$(date +'%Y')"
columns="$(tput cols)"


# HPC
volumeloc=$(df -h | grep dhl | awk '{ print $1 }')
totalvolume=$(df -h | grep dhl | awk '{ print $2 }')
volumeused=$(df -h | grep dhl | awk '{ print $3 }')
percvolumeused=$(df -h | grep dhl | awk '{ print $5 }')
volumeavail=$(df -h | grep dhl | awk '{ print $4 }')

# Bulk
volumelocbulk=$(df -h ${BULK} | tail -n +2 | awk '{ print $1 }')
totalvolumebulk=$(df -h ${BULK} | tail -n +2 | awk '{ print $2 }')
volumeusedbulk=$(df -h ${BULK} | tail -n +2 | awk '{ print $3 }')
percvolumeusedbulk=$(df -h ${BULK} | tail -n +2 | awk '{ print $5 }')
volumeavailbulk=$(df -h ${BULK} | tail -n +2 | awk '{ print $4 }')


text="QSTAT MONITORING UTILITY"
printf "%*s\n" $(( (${#text} + columns) / 2)) "$text"
DATE="$(date)"
printf "%*s\n" $(( (${#DATE} + columns) / 2)) "$DATE"
echo ""
echo "${bold}${cyan}>> Group volume statistics <<${normal}"
echo ""
echo "${italic}HPC${normal}"
echo "Location.............$volumeloc "
echo "Total volume.........$totalvolume "
echo "Volume used..........$volumeused ($percvolumeused) "
echo "Volume available.....$volumeavail "
echo ""
echo "Bulk${normal}"
echo "Location.............$volumelocbulk "
echo "Total volume.........$totalvolumebulk "
echo "Volume used..........$volvolumeusedbulkumeused ($percvolumeusedbulk) "
echo "Volume available.....$volumeavailbulk "

echo ""
echo "${bold}${orange}>> Job statistics <<${normal}"
echo "Running: $(squeue -u $USER | tail -n +3 | tr -s ' ' | cut -d' ' -f5 | grep -c 'r')"
echo "Queued:  $(squeue -u $USER | tail -n +3 | tr -s ' ' | cut -d' ' -f5 | grep -c 'qw')"
echo "Total:   $(squeue -u $USER | tail -n +3 | wc -l)"
echo ""

script_copyright_message

### Obsolete --SGE jobs
### year="/$(date +'%Y')"
### columns="$(tput cols)"
### text="QSTAT MONITORING UTILITY"
### printf "%*s\n" $(( (${#text} + columns) / 2)) "$text"
### DATE="$(date)"
### printf "%*s\n" $(( (${#DATE} + columns) / 2)) "$DATE"
### echo ""
### echo "Running: $(qstat | tail -n +3 | tr -s ' ' | cut -d' ' -f5 | grep 'r' | wc -l)"
### echo "Queued:  $(qstat | tail -n +3 | tr -s ' ' | cut -d' ' -f5 | grep 'qw' | wc -l)"
### echo "Total:   $(qstat | tail -n +3 | wc -l)"
### echo ""
### qstat | grep -v -- "--------------------" | tr -s ' ' | sed -e 's,'"$year"',,g' | cut -d' ' -f3,5,6,7 | sed 's/ /  /g'