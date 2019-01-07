#!/usr/bin/perl
# Pivot.pl--Pivot cells (e.g. columns to rows) in a table

# $Id: pivot.pl 1.0 2003/09/19 23:39:23 jp Exp $
# $Log: pivot.pl $
# Revision 1.0  2003/09/19 23:39:23  jp
# Initial Revision
#

$ver = '$Revision: 1.0 $'; # JP Vossen <jp@jpsdomain.org>
##########################################################################
(($myname = $0) =~ s/^.*(\/|\\)//ig); # remove up to last "\" or "/"
$Greeting  = ("$myname $ver Copyright 2003 JP Vossen (http://www.jpsdomain.org/)\n");
$Greeting .= ("    Licensed under the GNU GENERAL PUBLIC LICENSE:\n");
$Greeting .= ("    See http://www.gnu.org/copyleft/gpl.html for full text and details.\n");


if (("@ARGV" =~ /\?/) || ("@ARGV" =~ / -h/) || "@ARGV" =~ /--help/) {
    print STDERR ("\n$Greeting\n\n");
    print STDERR <<"EoN";    # Usage notes
Usage: $myname [OPTIONS] (-i [FILE] | -w) (-o [FILE] | -W) (-q)

   -i {infile}    = Use infile as the input file, otherwise use STDIN.
   -o {outfile}   = Use outfile as the output file, otherwise use STDOUT.
   -w = Get input from the Windows Clipboard instead of a file.
   -W = Write output to the Windows Clipboard instead of a file.
   -d {delimiter} = Input delimiter (TAB is default)
   -D {delimiter} = Output delimiter (TAB is default)
   -q = Be quiet about it.

Pivot cells (e.g. columns to rows) in a table:

   Columns to rows  {-- same as --}  Rows to Columns
H1 H2 H3  -->  H1 A1 B1 C1     L1 A1 B1 C1  -->  L1 L2 L3
A1 A2 A3  -->  H2 A2 B2 C2     L2 A2 B2 C2  -->  A1 A2 A3
B1 B2 B3  -->  H3 A3 B3 C3     L3 A3 B3 C3  -->  B1 B2 B3
C1 C2 C3  --/                               --\  C1 C2 C3

The first row (headers) must be >= the longest row in the data. Any row
longer than the first row will be truncated and a warning will be emitted.
EoN
    die ("\n");
} # end of usage


use Getopt::Std;          # Use Perl5 built-in program argument handler
getopts('i:o:wWd:D:q');   # Define possible args.


# Set defaults, use better names and other variables
$delimit_in  = $opt_d || "\t";
$delimit_out = $opt_D || "\t";


if (! $opt_i) { $opt_i = "-"; } # If no input file specified, use STDIN
if (! $opt_o) { $opt_o = "-"; } # If no output file specified, use STDOUT

if ($opt_w) {    # If we are getting our input from the Windows Clipboard
    # If input not STDOUT, then we're confused:
    if ($opt_i ne "-") { die ("$myname: Can't use -i and -w at the same time!\n"); }

    # Use a secure temp file that's automatically deleted when we're finished.
    $INFILE = IO::File->new_tmpfile || die ("$myname: error opening temp input file: $!\n");

    use Win32::Clipboard;  # Import the clipboard module
    $input = Win32::Clipboard::GetText();  # (Have to) Read entire clipboard contents
    $input =~ s/\r//g;    # Remove odd CRs ("\r"), if any, the clipboard sticks in

    # Write to a temp file (because the cboard is just a string...)-:
    print $INFILE ("$input");
    seek($INFILE, 0, 0) or die ("$myname: error couldn't rewind temp input file: $!\n");
} else {
    open ($INFILE, "$opt_i") or die ("$myname: error opening '$opt_i' for input: $!\n");
} # end of figure out input

if ($opt_W) {   # We're sending the output directly into the Clipboard
    # If output not STDOUT, then we're confused:
    if ($opt_o ne "-") { die ("$myname: Can't use -o and -W at the same time!\n"); }

    use Win32::Clipboard;       # Import the clipboard module
    use IO::File;               # Import File IO (for a temp file)
    # Use a secure temp file that's automatically deleted when we're finished.
    $OUTFILE = IO::File->new_tmpfile || die ("$myname: error opening temp output file: $!\n");
} else {
    # Note use of indirect file handle (e.g. '$' on $OUTFILE), needed for temp file
    open ($OUTFILE, ">$opt_o") or die ("$myname: error opening '$opt_o' for output: $!\n");
} # end of figure out output

if (! $opt_q) { print STDERR ("\n$Greeting\n"); }


# Get the first line (i.e. the headers)
$aline = <$INFILE>;
chomp($aline);
@header = split(/$delimit_in/, $aline);
$header_len = @header+0;

# Process the rest of the file
while ($aline = <$INFILE>) {
    chomp($aline);

    @arecord = split(/$delimit_in/, $aline);
    $record_len = @arecord+0;
    if ($record_len > $header_len) {
        warn ("$myname warning: omitting cell(s) without header '@arecord[$header_len..$record_len]'!\n");
        warn ("There is a row longer than the header row--add header(s) as needed.\n");
    } # end of row length sanity check

    $idx = 0;  # Set a record index
    foreach $cell (@header) {  # Go down the list of "headers" (now lines)
        $pivot{$cell} .= "$arecord[$idx]$delimit_out";  # and build the output
        $idx++;
    } # end of this line
} # end of the input


# Write the output
foreach $cell (@header) {  # Go down the list of "headers" (now lines)
    $pivot{$cell} =~ s/$delimit_out$//;    # Remove trailing delimiter
    print $OUTFILE ("$cell$delimit_out$pivot{$cell}\n");
} # end of foreach output


if ($opt_W) {   # We're sending the output directly into the Clipboard
    seek($OUTFILE, 0, 0) or die ("$myname: error couldn't rewind temp output file: $!\n");
    undef ($/);                          # Undefine the input line terminator so we grab the whole thing
    my $cboard = <$OUTFILE>;             # Grab it ALL
    Win32::Clipboard::Set("$cboard");    # Send it to the clipboard
} # end of output to clipboard


if (! $opt_q) { print STDERR ("\n\a$myname finished in ",time()-$^T," seconds.\n"); }

##########################################################################

