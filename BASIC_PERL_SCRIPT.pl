#!usr/bin/perl 

# Convert IMPUTE2 to 1 dosage PLINK-format
#
# Description: 	convert IMPUTE2 data to PLINK-format, so 3 dosages (AA, AB, BB) to 1 
# 				dosage (B-allele) for PLINK usage. The resulting file can than be used
#				for polygenic scores or regular PLINK-style --dosage association analyses.
#
# Written by:	Jessica van Setten & Sander W. van der Laan; UMC Utrecht, Utrecht, the 
#               Netherlands, j.vansetten@umcutrecht.nl or s.w.vanderlaan-2@umcutrecht.nl.
# Version:		1.0
# Update date: 	2016-01-28
#
# Usage:		convert_impute2dosage.pl [INPUT.gen] [GZIP/NORM] [OUTPUT.dosage]

# Starting conversion
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "+                                  CONVERT IMPUTE2DOSAGE                                 +\n";
print "+                                        Version 1.0                                     +\n";
print "+                                         28-01-2016                                     +\n";
print "+                  Written by: Jessica van Setten & Sander W. van der Laan               +\n";
print "+                                                                                        +\n";
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "Hello. I am starting the conversion of an IMPUTE2 .gen-file to a PLINK-style .dosage-file.\n";
my $time = localtime; # scalar context
print "The current date and time is: $time.\n";
print "\n";

use strict;
use warnings; 
# Three arguments are required: 
# - the input file (IN)
# - whether the input file is zipped (GZIP/NORM)
# - the output file (OUT)
my $file = $ARGV[0]; # first argument
my $zipped = $ARGV[1]; # second argument
my $output = $ARGV[2]; # third argument

# IF/ELSE STATEMENTS
if ($zipped eq "GZIP") {
	open (IN, "gunzip -c $file |") or die "* ERROR: Couldn't open input file: $!";

} elsif ($zipped eq "NORM") {
	open (IN, $file) or die "* ERROR: Couldn't open input file: $!";

} else {
    print "* ERROR: Please, indicate the type of input file: gzipped [GZIP] or uncompressed [NORM]!\n";
    print "         (Arguments are case-sensitive.)\n";

}

open (OUT, ">$output") or die "* ERROR: Couldn't open output file: $!";

while( <IN> ){

	next if $_ =~ /==>/;
	next unless /\S/;
	
	# Remove newline at end
	chomp; 
	
	# Read in values
	my @fields = split;
	
	# Describe the input file
	my $CHR = shift(@fields);
	my $altID = shift(@fields);
	my $SNP = shift(@fields);
	my $BP = shift(@fields);
	my $alA = shift(@fields);
	my $alB = shift(@fields);
	my @VALS = ();
		while (@fields){
		# Calculate the dosage; $val3 == BB, meaning the dosage will be relative to
		# the B-allele
		my $val1 = (shift(@fields))*0; # dosage AA
		my $val2 = (shift(@fields))*1; # dosage AB
		my $val3 = (shift(@fields))*2; # dosage BB
		my $valT = $val3 + $val2;
		push(@VALS, $valT);
		}
	# Print out the new data - per line
	print OUT "$SNP $alA $alB @VALS \n";
	}
close IN; # stop reading the input-file
close OUT; # stop writing the output-file

print "Wow. That was a lot of work. I'm glad it's done. Let's have beer, buddy!\n";
my $newtime = localtime; # scalar context
print "The current date and time is: $newtime.\n";
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";

###	UtrechtSciencePark Colours Scheme
###
### Website to convert HEX to RGB: http://hex.colorrrs.com.
### For some functions you should divide these numbers by 255.
###
###	No.	Color				HEX		RGB							CMYK					CHR		MAF/INFO
### --------------------------------------------------------------------------------------------------------------------
###	1	yellow				#FBB820 (251,184,32)				(0,26.69,87.25,1.57) 	=>	1 		or 1.0 > INFO
###	2	gold				#F59D10 (245,157,16)				(0,35.92,93.47,3.92) 	=>	2		
###	3	salmon				#E55738 (229,87,56) 				(0,62.01,75.55,10.2) 	=>	3 		or 0.05 < MAF < 0.2 or 0.4 < INFO < 0.6
###	4	darkpink			#DB003F ((219,0,63)					(0,100,71.23,14.12) 	=>	4		
###	5	lightpink			#E35493 (227,84,147)				(0,63,35.24,10.98) 	=>	5 		or 0.8 < INFO < 1.0
###	6	pink				#D5267B (213,38,123)				(0,82.16,42.25,16.47) 	=>	6		
###	7	hardpink			#CC0071 (204,0,113)					(0,0,0,0) 	=>	7		
###	8	lightpurple			#A8448A (168,68,138)				(0,0,0,0) 	=>	8		
###	9	purple				#9A3480 (154,52,128)				(0,0,0,0) 	=>	9		
###	10	lavendel			#8D5B9A (141,91,154)				(0,0,0,0) 	=>	10		
###	11	bluepurple			#705296 (112,82,150)				(0,0,0,0) 	=>	11		
###	12	purpleblue			#686AA9 (104,106,169)				(0,0,0,0) 	=>	12		
###	13	lightpurpleblue		#6173AD (97,115,173/101,120,180)	(0,0,0,0) 	=>	13		
###	14	seablue				#4C81BF (76,129,191)				(0,0,0,0) 	=>	14		
###	15	skyblue				#2F8BC9 (47,139,201)				(0,0,0,0) 	=>	15		
###	16	azurblue			#1290D9 (18,144,217)				(0,0,0,0) 	=>	16		 or 0.01 < MAF < 0.05 or 0.2 < INFO < 0.4
###	17	lightazurblue		#1396D8 (19,150,216)				(0,0,0,0) 	=>	17		
###	18	greenblue			#15A6C1 (21,166,193)				(0,0,0,0) 	=>	18		
###	19	seaweedgreen		#5EB17F (94,177,127)				(0,0,0,0) 	=>	19		
###	20	yellowgreen			#86B833 (134,184,51)				(0,0,0,0) 	=>	20		
###	21	lightmossgreen		#C5D220 (197,210,32)				(0,0,0,0) 	=>	21		
###	22	mossgreen			#9FC228 (159,194,40)				(0,0,0,0) 	=>	22		or MAF > 0.20 or 0.6 < INFO < 0.8
###	23	lightgreen			#78B113 (120,177,19)				(0,0,0,0) 	=>	23/X
###	24	green				#49A01D (73,160,29)					(0,0,0,0) 	=>	24/Y
###	25	grey				#595A5C (89,90,92)					(0,0,0,0) 	=>	25/XY	or MAF < 0.01 or 0.0 < INFO < 0.2
###	26	lightgrey			#A2A3A4	(162,163,164)				(0,0,0,0) 	=> 	26/MT
### 
### ADDITIONAL COLORS
### 27	midgrey				#D7D8D7
### 28	very lightgrey		#ECECEC
### 29	white				#FFFFFF
### 30	black				#000000
### --------------------------------------------------------------------------------------------------------------------




