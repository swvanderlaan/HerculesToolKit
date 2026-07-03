#!/usr/bin/perl
# HTMLList.pl--Create a *simple* HTML list from text input.

# $Id: HTMLList.pl 1.0 2003/11/30 21:05:53 JP Exp $
# $Log: HTMLList.pl $
# Revision 1.0  2003/11/30 21:05:53  JP
# Initial Revision
#

$ver = '$Revision: 1.0 $'; # JP Vossen <jp@jpsdomain.org>
##########################################################################
(($myname = $0) =~ s/^.*(\/|\\)//ig); # remove up to last "\" or "/"
$Greeting  = ("$myname $ver Copyright 2003 JP Vossen (http://www.jpsdomain.org/)\n");
$Greeting .= ("    Licensed under the GNU GENERAL PUBLIC LICENSE:\n");
$Greeting .= ("    See http://www.gnu.org/copyleft/gpl.html for full text and details.\n");


if (("@ARGV" =~ /\?/) || ("@ARGV" =~ / -h/) || "@ARGV" =~ / --help/) {
    print STDERR ("\n$Greeting\n\n");
    print STDERR <<"EoN";    # Usage notes
Usage: $myname [OPTIONS] (-i [FILE]) (-o [FILE] | -W) (-q)

   -i {infile}  = Use infile as the input file, otherwise use STDIN.
   -o {outfile} = Use outfile as the output file, otherwise use STDOUT.
   -u           = Output an un-ordered list, default is ordered.
   -t {Page title} = Output standalone HTML page with {Title}, default is just table code.

   -q           = Be quiet about it.

Create a *simple* HTML list from text input.
EoN
    die ("\n");
} # end of usage

use Getopt::Std;       # Use Perl5 built-in program argument handler
getopts('i:o:ut:q');   # Define possible args.

if (! $opt_q) { print STDERR ("\n$Greeting\n"); }

if (! $opt_i) { $opt_i = "-"; } # If no input file specified, use STDIN
if (! $opt_o) { $opt_o = "-"; } # If no output file specified, use STDOUT
open (INFILE, "$opt_i")   or die ("$myname: error opening $opt_i for input: $!\n");
open (OUTFILE, ">$opt_o") or die ("$myname: error opening $opt_o for output: $!\n");

if ($opt_t) {
    print OUTFILE ("<html>\n");
    print OUTFILE ("<head><title>$opt_t</title></head>\n");
    print OUTFILE ("<body>\n\n");
    print OUTFILE ("<h1>$opt_t</h1>\n\n");
} # end of if standalone

if ($opt_u) {
    print OUTFILE "<ul>\n";
} else {
    print OUTFILE "<ol>\n";
} # end of list style

while ($aline = <INFILE>) {
    chomp($aline);
    print OUTFILE "  <li>$aline</li>\n";
} # end of while input

if ($opt_u) {
    print OUTFILE "</ul>\n";
} else {
    print OUTFILE "</ol>\n";
} # end of list style

if ($opt_t) {
    print OUTFILE ("\n</body>\n");
    print OUTFILE ("</html>\n");
} # end of if standalone

if (! $opt_q) { print STDERR ("\n\a$myname finished in ",time()-$^T," seconds.\n"); }

