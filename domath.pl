#!/usr/bin/perl
# DoMath.pl -- Perform math operations on arbitrary lines of numerical input
#$ver = "v1.0"; # 2002-09-10 JPV
#$ver = "v1.1"; # 2002-09-26 JPV Added -p
$ver = "v1.2"; # 2002-10-22 JPV Reversed -p (remove punctuation now default)

# ToDo:	Add more options for calculation?
#	Add precision and format specifications?
##########################################################################
(($myname = $0) =~ s/^.*(\/|\\)|\..*$//ig); # remove up to last "\" or "/" and after any "."
$Greeting =  ("$myname $ver Copyright 2002 JP Vossen (http://www.jpsdomain.org/)\n");
$Greeting .= ("    Licensed under the GNU GENERAL PUBLIC LICENSE:\n");
$Greeting .= ("    See http://www.gnu.org/copyleft/gpl.html for full text and details.\n"); # Version and copyright info

if (("@ARGV" =~ /\?/) || ("@ARGV" =~ /h/) || (@ARGV < 1)) { # Need help?
    print STDERR ("\n$Greeting\n\tUsage: $myname [-i {infile}] [-o {outfile}] [-s] [-a] [-q]\n");
    print STDERR ("\n\tPerform math operations on arbitrary lines of numerical input.\n");
    print STDERR ("\n\t-i {infile} = Use infile as the input file, otherwise use STDIN.\n");
    print STDERR ("\t-o {outfile} = Use outfile as the output file, otherwise use STDOUT.\n");
    print STDERR ("\n\t-s = Display the Sum of the input.\n");
    print STDERR ("\t-a = Display the Average of the input.\n");
    print STDERR ("\t-c = Display a Count of the lines of input.\n");
    print STDERR ("\t-p = DON'T Remove all punctuation (actually, anything other than 0-9)\n");
    print STDERR ("\t\tbefore processing\n");
    print STDERR ("\t-q = Only display the answer.\n");
    die ("\n");
}

use Getopt::Std;                   # Use Perl5 built-in program argument handler
getopts('i:o:acpqs');              # Define possible args.

if (! $opt_i) { $opt_i = "-"; }  # If no input file specified, use STDIN
if (! $opt_o) { $opt_o = "-"; }  # If no output file specified, use STDOUT

open (INFILE, "$opt_i") || die "$myname: error opening $opt_i $!\n";
open (OUTFILE, ">$opt_o") || die "$myname: error opening $opt_o $!\n";

if (! $opt_q) { print STDERR ("\n$Greeting\n"); }


while (<INFILE>) {

    if (! $opt_p) { tr/[0-9]//cd; }  # Remove everything BUT numbers

    $count++;
    $total+=$_;
} # end of while


if ($opt_s) {
    if ($opt_q) {
        print ("$total\n");
    } else {
        print ("Sum:\t$total\n");
    } # end of quiet
} # end of sum


if ($opt_a) {
    $average=$total/$count;
    if ($opt_q) {
        print ("$average\n");
    } else {
        print ("Average:\t$average\n");
    } # end of quiet
} # end of sum


if ($opt_c) {
    if ($opt_q) {
        print ("$count\n");
    } else {
        print ("Line Count:\t$count\n");
    } # end of quiet
} # end of sum


if (! $opt_q) { print STDERR ("\n\a$myname finished in ",time()-$^T," seconds.\n"); }

