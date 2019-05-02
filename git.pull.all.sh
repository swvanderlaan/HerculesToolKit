#!/bin/bash

##########################################################################################
# Created by		Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan[at]gmail[dot]com
# Last edit			2019-05-02
# Version			1.0.0
##########################################################################################


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

script_copyright_message() {
	echo ""
	THISYEAR=$(date +'%Y')
	echoitalic "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoitalic "+ The MIT License (MIT)                                                                                 +"
	echoitalic "+ Copyright (c) 1979-${THISYEAR} Sander W. van der Laan                                                        +"
	echoitalic "+                                                                                                       +"
	echoitalic "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and     +"
	echoitalic "+ associated documentation files (the \"Software\"), to deal in the Software without restriction,         +"
	echoitalic "+ including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, +"
	echoitalic "+ and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, +"
	echoitalic "+ subject to the following conditions:                                                                  +"
	echoitalic "+                                                                                                       +"
	echoitalic "+ The above copyright notice and this permission notice shall be included in all copies or substantial  +"
	echoitalic "+ portions of the Software.                                                                             +"
	echoitalic "+                                                                                                       +"
	echoitalic "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT     +"
	echoitalic "+ NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                +"
	echoitalic "+ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES  +"
	echoitalic "+ OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN   +"
	echoitalic "+ CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                            +"
	echoitalic "+                                                                                                       +"
	echoitalic "+ Reference: http://opensource.org.                                                                     +"
	echoitalic "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

echocyan "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echocyan "                           GIT REPOSITORY UPDATER"
echocyan ""
echocyan "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


HOME_MACPRO="/Users/svanderlaan"
GITDIR="${HOME_MACPRO}/git/swvanderlaan"
cd $GITDIR

for GIT in $(ls); do 
	
	echo "++++++++++++++++++++++++++++++++++++++++"
	echo ""
	echo "* Checking [ $GITDIR/$GIT ] ..."
	
	cd $GITDIR/$GIT
	
	echo ""
	echo "* Get status"
	git status
	
	echo ""
	echo "* Get remote information"
	git remote -v
	
	git remote set-url origin git@github.com:swvanderlaan/$GIT.git
	
# 	echo ""
# 	echo "* Pull"
# 	git pull
	
	cd $GITDIR
	
	echo ""
	echo "++++++++++++++++++++++++++++++++++++++++"
	echo ""
	
done

script_copyright_message