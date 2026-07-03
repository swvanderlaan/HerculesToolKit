#!/usr/bin/perl
# HTMLTable.pl--Create a *simple* HTML table from CSV or TAB delimited input.

# $Id: HTMLTable.pl 1.1 2003/11/10 00:13:41 JP Exp $
# $Log: HTMLTable.pl $
# Revision 1.1  2003/11/10 00:13:41  JP
# lc(tags), minor tweaks
#

#$ver = "v1.0"; # 2002-12-21 JP Vossen <jp@jpsdomain.org>

$ver = '$Revision: 1.1 $'; # JP Vossen <jp@jpsdomain.org>
##########################################################################
(($myname = $0) =~ s/^.*(\/|\\)//ig); # remove up to last "\" or "/"
$Greeting  = ("$myname $ver Copyright 2002-2003 JP Vossen (http://www.jpsdomain.org/)\n");
$Greeting .= ("    Licensed under the GNU GENERAL PUBLIC LICENSE:\n");
$Greeting .= ("    See http://www.gnu.org/copyleft/gpl.html for full text and details.\n");


if (("@ARGV" =~ /\?/) || ("@ARGV" =~ / -h/) || "@ARGV" =~ / --help/) {
    print STDERR ("\n$Greeting\n\n");
    print STDERR <<"EoN";    # Usage notes
Usage: $myname [OPTIONS] (-i [FILE]) (-o [FILE] | -W) (-q)

   -i {infile}  = Use infile as the input file, otherwise use STDIN.
   -o {outfile} = Use outfile as the output file, otherwise use STDOUT.
   -c           = Input is CSV, default is TAB delimited.
   -l           = Top row of table is NOT column Lables (headers).
   -t {Page title} = Output standalone HTML page with {Title}, default is just table code.
   -b {border size} = Table has {border size}, default is 1.

   -q           = Be quiet about it.

Create a *simple* HTML table from CSV or TAB delimited input.
EoN
    die ("\n");
} # end of usage


use Getopt::Std;           # Use Perl5 built-in program argument handler
getopts('i:o:t:b:clq');    # Define possible args.
if ($opt_c) {
    use Text::ParseWords;  # Use this to parse CSV input
} # end of if CSV


if (! $opt_q) { print STDERR ("\n$Greeting\n"); }

if ($opt_b) {
   $BorderSize = $opt_b;
} else {
   $BorderSize = 1;
} # end of set border size

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

print OUTFILE ("<table border=$BorderSize>\n");

while ($aline = <INFILE>) {
    chomp($aline);

    if ($opt_c) {
        @arecord = quotewords(",", 0, $aline);
    } else {
        @arecord = split (/\t/, $aline);
    } # end of who to parse

    print OUTFILE "  <tr>\n";
    if ((! $opt_l) and (! $LabelsDone)) {
        foreach $field (@arecord) {
            print OUTFILE "    <th>$field</th>\n";
        } # end of foreach field
        $LabelsDone = 1;
    } else {
        foreach $field (@arecord) {
            print OUTFILE "    <td>$field</td>\n";
        } # end of foreach field
    } # end of if labels    
    print OUTFILE "  </tr>\n";
    
} # end of while input

print OUTFILE ("</table>\n");

if ($opt_t) {
    print OUTFILE ("\n</body>\n");
    print OUTFILE ("</html>\n");
} # end of if standalone

if (! $opt_q) { print STDERR ("\n\a$myname finished in ",time()-$^T," seconds.\n"); }

