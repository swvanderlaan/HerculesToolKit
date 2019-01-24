#!/bin/bash
year="/$(date +'%Y')"
columns="$(tput cols)"
text="QSTAT MONITORING UTILITY"
printf "%*s\n" $(( (${#text} + columns) / 2)) "$text"
DATE="$(date)"
printf "%*s\n" $(( (${#DATE} + columns) / 2)) "$DATE"
echo ""
echo "Running: $(qstat | tail -n +3 | tr -s ' ' | cut -d' ' -f5 | grep 'r' | wc -l)"
echo "Queued:  $(qstat | tail -n +3 | tr -s ' ' | cut -d' ' -f5 | grep 'qw' | wc -l)"
echo "Total:   $(qstat | tail -n +3 | wc -l)"
echo ""
qstat | grep -v -- "--------------------" | tr -s ' ' | sed -e 's,'"$year"',,g' | cut -d' ' -f3,5,6,7 | sed 's/ /  /g'