#!/bin/bash

GITDIR="/Users/swvanderlaan/git"
cd $GITDIR

for GIT in $(ls); do 
	echo "* Checking [ $GIT ] ..."
	
	cd $GIT
	
	git status
	
	git pull
	
	cd $GITDIR

done
