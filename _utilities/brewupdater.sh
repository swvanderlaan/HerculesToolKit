#!/bin/bash
VERSION="Version 1.4.3"
echo "============================================================================================"
echo "                            UPDATE, UPGRADE & CLEANUP HOMEBREW"
echo "                                       $VERSION"
echo "============================================================================================"

Today\'s $(date). Let\'s update your homebrew and its Cellar..."
say -v Karen "Updating, upgrading and cleaning up HomeBrew. $VERSION. Today\'s $(date). Let\'s update your homebrew and its Cellar..."

echo ""
echo "============================================================================================"
echo ""
echo "Checking the condition of Homebrew ... "
brew doctor

echo ""
echo "Listing what we have in the Cellar ... "
brew list
echo ""
echo "... and in the Cask ..."
brew list --cask

echo ""
echo "Updating Homebrew ... "
brew update

echo ""
echo "Upgrading Homebrew's Cellar ... " 
# As packages and workflows may be broken it is generally a bad idea to upgrade automatically...
# ...but I live on the edge.
brew upgrade 

echo ""
echo "... and its Cask ..."
brew upgrade --cask

echo ""
echo "Cleaning up the shizzle ... " 
# Cleanup shouldn't be done if versions of packages are important.
brew cleanup 

printf "
All done!
[\/]++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++[\/]
"
say -v Karen "All done. Have a nice day. The date is $(date)."
