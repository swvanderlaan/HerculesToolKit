#!/bin/bash

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

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "         SCRIPT TO PREPARE AN APPLE COMPUTER TO DO 'OMICS'-SCIENCE"
echo ""
echoitalic "* Written by  : Sander W. van der Laan"
echoitalic "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
echoitalic "* Last update : 2017-07-13"
echoitalic "* Version     : 1.0.0"
echo ""
echoitalic "* Description : This script will prepare an Apple computer to do 'omics'-science."
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Today's: "$(date)
TODAY=$(date +"%Y%m%d")
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Prepare this Mac for 'Omics'-science."

echo ""
echo "Creating a bin-directory for programs"
mkdir $HOME/bin
chmod -vR 0777 $HOME/bin

echo ""
echo "Installing Homebrew, command line, Xcode, XQuartz, and R."
echo "Inspired by:"
echo "* http://www.benjack.io/2016/01/02/el-capitan-biocomputing.html"
echo "* http://www.r-bloggers.com/installing-r-on-os-x-100-homebrew-edition/ "
echo "* https://coolestguidesontheplanet.com/installing-homebrew-on-os-x-el-capitan-10-11-package-manager-for-unix-apps/ "

echo ""
echo "Installing 'command line tools for macOS Sierra', inspired by http://railsapps.github.io/xcode-command-line-tools.html"
# copy and paste to terminal and hit [enter]
xcode-select --install

echo ""
echo "Install Perl modules"
sudo cpan YAML Getopt::Long Statistics::Distributions

echo ""
echo "Installation of HOMEBREW via www.brew.sh or https://github.com/homebrew"
# copy and paste to terminal and hit [enter]

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo ""
# copy and paste to terminal and hit [enter]
brew doctor

echo ""
echo "Install the following packages:"
# copy and paste to terminal and hit [enter]
brew install coreutils gnu-sed wget rename git 

echo ""
echo "For FastQTL/QTLTools to work: installation of (GNU scientific libraries)"
# copy and paste to terminal and hit [enter]
brew install zlib boost gsl

echo ""
echo "Use “brew doctor” to diagnose in-between installations; "
echo "if there is a problem with ownership use “chown -vR MYUSERNAME A_FOLDER_NAME” to get ownership back recursively (‘R')."

echo ""
echo "Install the following Python:"
echo "* based on: http://www.benjack.io/2016/01/02/el-capitan-biocomputing.html"
echo "* and on: https://rud.is/b/2015/10/22/installing-r-on-os-x-100-homebrew-edition/"

brew install python 

pip install argparse numpy scipy scikit-learn pandas 

echo ""
echo "Install stuff for R"
echo "* based on: http://www.benjack.io/2016/01/02/el-capitan-biocomputing.html"
echo "* and on: https://rud.is/b/2015/10/22/installing-r-on-os-x-100-homebrew-edition/"
# copy and paste *each line separately* to terminal and hit [enter]
brew tap caskroom/cask && brew install cask
brew install Caskroom/cask/xquartz && brew cask install java
brew tap homebrew/science
brew install homebrew/science/r ##--with-openblas # added --with-openblas based on a spiffy comment by Lincoln Mullen
brew install Caskroom/cask/rstudio
