#!bin/bash

# Reference: https://stackoverflow.com/questions/3211595/renaming-files-in-a-folder-to-sequential-numbers

# Rename a bunch of files and give it a new name with sequential numbers
# Author: Sander W. van der Laan | s.w.vanderlaan@gmail.com

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "                        FILE RENAMER WITH SEQUENTIAL NUMBERS"
echo ""
echo "Author:      Sander W. van der Laan | s.w.vanderlaan@gmail.com"
echo "Date:        2019-01-06"
echo "Version:     1.0.0"
echo "Description: Rename a bunch of files to a new name with sequential numbers."
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Let's rename the shizzle."

echo ""

a=184 

for i in *.png; do
  new=$(printf "Foto %d.png" "$a") #04 pad to length of 4
  mv -iv -- "$i" "$new"
  let a=a+1
done

echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Wow, that was a lot. Let's have a 🍻 "
date