#!/usr/bin/perl
# WordFreq.pl -- Count word frequency in a text file
$ver = "v1.0"; # 05-Dec-2001 JP Vossen {jp@jpsdomain.org>

# Basics from 8.3, page 280 of _Perl_Cookbook_
# Added stop words

(($myname = $0) =~ s/^.*(\/|\\)|\..*$//ig); # remove up to last "\" or "/" and after any "."
$Greeting =  ("$myname $ver Copyright 12001 JP Vossen (http://www.jpsdomain.org/)\n");
$Greeting .= ("    Licensed under the GNU GENERAL PUBLIC LICENSE:\n");
$Greeting .= ("    See http://www.gnu.org/copyleft/gpl.html for full text and details.\n"); # Version and copyright info

%seen = ();   # Create the hash

# Define the stopwords
@stopwords = ("a", "an", "and", "are", "as", "at", "be", "but", "by", 
"does", "for", "from", "had", "have", "her", "his", "if", "in", "is",
"it", "not", "of", "on", "or", "that", "the", "this", "to", "was",
"which", "with", "you");


if (("@ARGV" =~ /\?/) || (@ARGV > 5) || (@ARGV < 0)) { #if wrong # of args, or a ? in args - die
    print STDERR ("\n$Greeting\n\tUsage: $myname -i {infile} [-s]\n");
    print STDERR ("\nIf -s is used, the list of stop words will NOT be used.\n");
    print STDERR ("The stopwords currently defined are:\n\n ");
    foreach $stopword (@stopwords) {
        print STDERR ("$stopword ");
    } # end of foreach stopword
    die ("\n");
}

use Getopt::Std;                 # User Perl5 built-in program argument handler
getopts('i:o:s');                # Define possible args.

if (! $opt_i) { $opt_i = "-"; }  # If no input file specified, use STDIN
if (! $opt_o) { $opt_o = "-"; }  # If no output file specified, use STDOUT

open (INFILE, "$opt_i") || die "$myname: error opening $opt_i $!\n";
open (OUTFILE, ">$opt_o") || die "$myname: error opening $opt_o $!\n";

print STDERR ("\n$Greeting\n");

while (<INFILE>) {                # Read the input file
    while ( /(\w['\w-]*)/g ) {    # If we have a "word"
        $seen{lc $1}++;           # Count it in the hash
    } # end of while words
} # end of while input

if (! $opt_s) {                       # If we're using stopwords
    foreach $stopword (@stopwords) {  # for each stopword
        delete($seen{$stopword});     # Remove it from the hash
    } # end of foreach stopword       # This way we only test once for each
} # end of if using stopwords           stopword, rather than in a loop!


# Print the results, sorted most frequent words at the top
foreach $word ( sort { $seen{$b} <=> $seen{$a} } keys %seen) {
    printf OUTFILE ("%6d %s\n", $seen{$word}, $word);
} # end of foreach word

