#!/hpc/local/CentOS7/common/lang/python/2.7.10/bin/python
# coding=UTF-8

# Alternative shebang for local Mac OS X: #!/usr/bin/python
# Linux version for HPC: #!/hpc/local/CentOS7/common/lang/python/2.7.10/bin/python

### ADD-IN:
### - flag to *optinally* determine which "COLUMNS_TO_KEEP"
# 
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
print "                                          MINIMAC3 VCF TO OXFOR GEN CONVERTER "
print ""
print "* Version          : v1.0.1"
print ""
print "* Last update      : 2018-08-23"
print "* Written by       : Tim Bezemer "
print "                     University Medical Center Utrecht | University Utrecht"
print "                     t.bezemer[at]]umcutrecht[dot]nl"
print "* Designed by      : Sander W. van der Laan "
print "                     University Medical Center Utrecht | University Utrecht | s.w.vanderlaan[at]]gmail[dot]com"
print "                     s.w.vanderlaan-2[at]]umcutrecht[dot]nl"
print ""
print "* Description      : This script will convert Michigan Imputation Server Minimax3-style VCF-files to "
print "                     Oxford-style GEN-files."
print ""
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

### ADD-IN: 
### - requirement check
### - if not present install
### - report that the requirements are met

import gzip
import io
from sys import argv, exit
import sys
from time import strftime
import argparse

COLUMNS_TO_KEEP = ["ID", "ID", "POS", "REF", "ALT", "UPID"]

# SOME_FILE=argv[1]

parser = argparse.ArgumentParser(description="Convert Minimac3-style VCF to Oxford-style GEN-files.")
## parser.add_argument("-s", "--subsample", help="Number of rows to use for subsampling, when determining the optimal VariantID (default = 100,000)", type=int)
#
requiredNamed = parser.add_argument_group('required named arguments')
#
requiredNamed.add_argument("-f", "--file", help="The Minimac3 VCF-file to convert.", type=str)
requiredNamed.add_argument("-o", "--output", help="The path to the output file.", type=str)
args = parser.parse_args()
#
if not args.file:

	print "Usage: " + argv[0] + " --help"
	print "Exiting..."
	exit()

try:
	#print "Opening the VCF file."
	with gzip.open(args.file, "rb") as gz:
		f = io.BufferedReader(gz)
		colmap = []
		with open(args.output "w") as output_file:

			for line in f.readlines():
				# print "Reading lines, while ignoring lines starting with '##'."
				line = line.strip()
				if line.startswith("##"): 
					continue;
				if line.startswith("#"):
					colmap = line.split('\t')
					continue		
				fields = line.split("\t")
				for col in COLUMNS_TO_KEEP:
					#print "Extracting relevant data."
					for index, field in enumerate(fields):
						if colmap[index] == col:
							#print " - writing variant information ..."
							output_file.write(field + " ")
						elif col == "UPID" and colmap[index].startswith("UPID"):
							#print " - extracting and writing the genotype probilities ..."
							UPID_GP = field.split(":")[2]
							UPID_GP = UPID_GP.split(",")
							output_file.write(" ".join(UPID_GP)+ " ")

				output_file.write('\n')

except IOError:
	
	exit()
	
print "\t ..." + strftime("%a, %H:%M:%S") + " All done converting. Let's have a beer, buddy!"

print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
print "+ The MIT License (MIT)                                                                                      +"
print "+ Copyright (c) 2018 Tim Bezemer, Sander W. van der Laan | UMC Utrecht, Utrecht, the Netherlands             +"
print "+                                                                                                            +"
print "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and          +"
print "+ associated documentation files (the \"Software\"), to deal in the Software without restriction, including  +"
print "+ without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    +"
print "+ copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the   +"
print "+ following conditions:                                                                                      +"
print "+                                                                                                            +"
print "+ The above copyright notice and this permission notice shall be included in all copies or substantial       +"
print "+ portions of the Software.                                                                                  +"
print "+                                                                                                            +"
print "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT    +"
print "+ LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  +"
print "+ EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER  +"
print "+ IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR    +"
print "+ THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                                                 +"
print "+                                                                                                            +"
print "+ Reference: http://opensource.org.                                                                          +"
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"