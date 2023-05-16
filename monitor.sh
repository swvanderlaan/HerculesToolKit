#!/bin/bash
#
# Description: SLURM job monitoring.
# 
# The MIT License (MIT)
# Copyright (c) 1979-2023, Sander W. van der Laan, UMC Utrecht, Utrecht, the Netherlands.
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
# normal=$(tput sgr0)
# bold=$(tput bold)
# italic=$(tput italic)
# 
# black=$(tput setaf 0)
# blue=$(tput setaf 33)
# cyan=$(tput setaf 37)
# green=$(tput setaf 64)
# orange=$(tput setaf 166)
# purple=$(tput setaf 125)
# red=$(tput setaf 124)
# white=$(tput setaf 15)
# yellow=$(tput setaf 136)

### MESSAGE FUNCTIONS
script_copyright_message() {
	echo ""
	THISYEAR=$(date +'%Y')
	echo "The MIT License (MIT)"
	echo "Copyright (c) 1979-${THISYEAR} Sander W. van der Laan | s.w.vanderlaan@gmail.com | vanderlaanand.science"
	echo ""
	echo "version: v1.2_20230516"
	echo "last edit: 2023-05-16"
	echo ""
	echo "Reference: http://opensource.org."
}

### General settings
USER="$(whoami)" #"svanderlaan"
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

# UKBiobank
volumeloc_ukb=$(df -h | grep ukbiobank | awk '{ print $1 }')
totalvolume_ukb=$(df -h | grep ukbiobank | awk '{ print $2 }')
volumeused_ukb=$(df -h | grep ukbiobank | awk '{ print $3 }')
percvolumeused_ukb=$(df -h | grep ukbiobank | awk '{ print $5 }')
volumeavail_ukb=$(df -h | grep ukbiobank | awk '{ print $4 }')

text="SLURM MONITORING UTILITY"
printf "%*s\n" $(( (${#text} + columns) / 2)) "$text"
DATE="$(date)"
printf "%*s\n" $(( (${#DATE} + columns) / 2)) "$DATE"
echo ""
echo ">> Group volume statistics <<"
echo ""
echo "HPC"
echo "Location............./hpc/dhl_ec | $volumeloc "
echo "Total volume.........$totalvolume "
echo "Volume used..........$volumeused ($percvolumeused) "
echo "Volume available.....$volumeavail "
echo ""
echo "Bulk - only authorized access"
echo "Location............./data/isi/d/dhl | $volumelocbulk "
echo "Total volume.........$totalvolumebulk "
echo "Volume used..........$volumeusedbulk ($percvolumeusedbulk) "
echo "Volume available.....$volumeavailbulk "
echo ""
echo "UKBiobank data - only authorized access"
echo "Location............./hpc/ukbiobank | $volumeloc_ukb "
echo "Total volume.........$totalvolume_ukb "
echo "Volume used..........$volumeused_ukb ($percvolumeused_ukb) "
echo "Volume available.....$volumeavail_ukb "

echo ""
echo ">> Job statistics | current user: $USER <<"
echo "Running: $(squeue -u $USER | tail -n +2 | awk '$5=="R"' | wc -l)" #OLD: tr -s ' ' | cut -d' ' -f5 | grep -c 'r')"
echo "Queued:  $(squeue -u $USER | tail -n +2 | awk '$5=="PD"' | wc -l)" #OLD: tr -s ' ' | cut -d' ' -f5 | grep -c 'qw')"
echo "Total:   $(squeue -u $USER | tail -n +2 | wc -l)"
echo ""

script_copyright_message

