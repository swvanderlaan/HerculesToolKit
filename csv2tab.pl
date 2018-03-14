#!/usr/bin/perl -w
# csv2tab.pl--Convert CSV to TAB delimited

# $Id: csv2tab.pl 1521 2008-09-27 20:01:13Z jp $
# $URL: file:///i:/home/SVN/util/csv2tab.pl $

my $VERSION   = '$Version: 3.5 $';
my $COPYRIGHT = 'Copyright 2002-2008 JP Vossen (http://www.jpsdomain.org/)';
my $LICENSE   = 'GNU GENERAL PUBLIC LICENSE';
my $USAGE     = ''; # Placeholder for usage info below
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
((my $PROGRAM = $0) =~ s/^.*(\/|\\)//ig); # remove up to last "\" or "/"

# This sub is here for quick documentation purposes.  Other subs at bottom.
sub Usage {
    # Called like: Usage ({exit code})
    my $exit_code = $_[0] || 1; # Default of 1 if exit code not specified

    # Unlike sh, Perl does not have a built in way to skip leading
    # TABs (but not spaces) to allow indenting in HERE docs.  So we cheat.
    ($USAGE = sprintf <<"EoN") =~ s/^\t//gm;
	NAME
	    ${PROGRAM}--Convert CSV to TAB delimited

	SYNOPSIS
	    $PROGRAM [OPTIONS] [-i <file> | -w] [-o <file> | -W]

	OPTIONS
	    -i <file> = Input file (otherwise STDIN)
	    -o <file> = Output file (otherwise STDOUT)
	    -w = Take input from the Windows Clipboard instead of a file.
	    -W = Write output to the Windows Clipboard instead of a file.

	    -d {delimiter} = Use the specified delimiter instead of TAB.
	    -h = This usage
	    -v = Be verbose
	    -V = Show version, copyright and license information
	    -q = Ignored for backward compatability.

	    Examples:
	        $PROGRAM -i file | cut -f 5

	DESCRIPTION ($VERSION)
	    Parse a CSV formatted file and output a TAB delimited file.  This is very
	    handy for working with data in a spreadsheet (it can be faster than
	    dealing with the spreadsheet's import CSV wizard) or for using tools like
	    'cut -d' which will not work when a field contains a CSV legally quoted
	    comma.

	AUTHOR / BUG REPORTS
	    JP Vossen (jp {at} jpsdomain {dot} org)
	    http://www.jpsdomain.org/

	COPYRIGHT & LICENSE
	    $COPYRIGHT
	    $LICENSE

	SEE ALSO
	    "Parsing CSV files" on page 212 of Mastering Regular Expressions, 2nd
	    (http://regex.info/ and http://www.oreilly.com/catalog/regex2/index.html)
EoN

    print STDERR ("$USAGE");  # Print the usage
    exit $exit_code;          # exit with the specified error code
} # end of usage

# Declare everything to keep -w and use strict happy
my  ($INFILE, $OUTFILE, $aline, $delimiter, $outline, @arecord);
our ($opt_i, $opt_o, $opt_w, $opt_W, $opt_h, $opt_v, $opt_V, $opt_d);

use strict;
use Getopt::Std;
getopts('i:o:wWhvVdq');

Usage(0)   if $opt_h;
Version(0) if $opt_V;

# Set output delimiter (input is CSV)
$delimiter=$opt_d||"\t";        # Use the specified delimiter or TAB

Open_IO(); # Open input and outfile files

if ($opt_v) { print STDERR ("$PROGRAM version $VERSION\n\t$COPYRIGHT\n\t$LICENSE\n"); }
#print ("Starting at ", strftime("%Y-%m-%d %H:%M:%S %z", localtime), "\n");
#print ("Starting at ", strftime("%Y-%m-%d %H:%M:%S", gmtime), " UTC \n");
##########################################################################
# Main

while ($aline = <$INFILE>) {
    chomp($aline);
    ### @arecord = quotewords(",", $KeepSep, $aline);
    @arecord = &parse_csv_mre2 ($aline);
    $outline = join ($delimiter, @arecord);
    print $OUTFILE "$outline\n";
} # end of while input

# End of main
##########################################################################
if ($opt_W) { Send_to_Clipboard(); } # Send output directly into the Clipboard
if ($opt_v) { print STDERR ("\n\a$PROGRAM finished in ",time()-$^T," seconds.\n"); }


# Subroutines
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Emit version and other information
# Called like: Version ({exit code})
# Returns:  nothing
sub Version {
    my $exit_code = $_[0] || 1; # Default of 1 if exit code not specified
    print ("$PROGRAM version $VERSION\n\t$COPYRIGHT\n\t$LICENSE\n");
    exit $exit_code; # exit with the specified error code
} # end of sub Version


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Open input and output files, STDIN/STDOUT or Windows Clipboard
# Called like:  Open_IO()
# Returns:  nothing
sub Open_IO {

    if (! $opt_i) { $opt_i = "-"; } # If no input file specified, use STDIN
    if (! $opt_o) { $opt_o = "-"; } # If no output file specified, use STDOUT

    # Input
    if ($opt_w and ($^O eq "MSWin32")) { # If we're getting input from the Windows Clipboard
        eval "use Win32::Clipboard;";    # Import clipboard but don't die if we're not on Windows
        my $cboard  = Win32::Clipboard::GetText();  # (Have to) Read entire clipboard contents
        $cboard =~ s/\r//g;              # Remove odd CRs ("\r"), if any, the clipboard sticks in
        # Dump CDB into a secure temp file that's automatically deleted when we're finished,
        # then rewind it to the main look can read $INFILE as normal.
        use File::Temp;
        $INFILE = tmpfile() || die ("$PROGRAM: error creating temp file for -w: $!\n");
        print $INFILE ("$cboard");
        seek($INFILE, 0, 0) or die ("$PROGRAM: error couldn't rewind temp INPUT file: $!\n");
    } elsif ($opt_w and ($^O ne "MSWin32")) {
        die ("$PROGRAM: can't use -w on Linux or Unix!  What're you thinking?!?\n");
    } else {
        # Regular old input
        open ($INFILE, "$opt_i") or die ("$PROGRAM: error opening '$opt_i' for input: $!\n");
    } # end of get input from clipboard

    # Output
    if ($opt_W and ($^O eq "MSWin32")) { # We're sending the output directly into the Clipboard
        eval "use Win32::Clipboard;";    # Import clipboard but don't die if we're not on Windows
        # Use a secure temp file that's automatically deleted when we're finished.
        use File::Temp;
        $OUTFILE = tmpfile() || die ("$PROGRAM: error creating temp file for -W: $!\n");
    } elsif ($opt_W and ($^O ne "MSWin32")) {
        die ("$PROGRAM: can't use -W on Linux or Unix!  What're you thinking?!?\n");
    } else {
        # Regular old output
        # Note use of indirect file handle (e.g. '$' on $OUTFILE), needed for temp file
        open ($OUTFILE, ">$opt_o") or die ("$PROGRAM: error opening '$opt_o' for output: $!\n");
    } # end of if using clipboard
} # end of sub Open_IO


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# We're sending the output directly into the Clipboard
# Called like:  Send_to_Clipboard()
# Returns:  nothing
sub Send_to_Clipboard {

    seek($OUTFILE, 0, 0) or die ("$PROGRAM: error couldn't rewind temp OUTPUT file: $!\n");
    undef ($/);  # Undefine the input line terminator so we grab the whole thing
    my $cboard = <$OUTFILE>;          # Grab it ALL
    Win32::Clipboard::Set("$cboard"); # Send it to the clipboard
} # end of sub Send_to_Clipboard


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Regex to parse CSV from _Mastering_Regular_Expressions,_Second_Edition_;
# page 271. See http://regex.info/ esp. http://regex.info/dlisting.cgi?id=1253)
# Called like: @arecord = &parse_csv_mre2 ($aline);
# Returns:  an array of the parsed line
sub parse_csv_mre2 {

    if (scalar @_ == 0) { return(); }
    my $line = $_[0];
    my @parsedline = ();
    my $field = '';

    # See top for details about the regex
    while ($line =~ m{
              \G(?:^|,)
              (?:
                 # Either a double-quoted field (with "" for each ")...
                 " # field's opening quote
                  ( (?> [^"]* ) (?> "" [^"]* )*  )
                 " # field's closing quote
               # ..or...
               |
                 # ... some non-quote/non-comma text....
                 ( [^",]* )
              )
          }gx)
    {                         # OK, done with regex, NOW what...
       if (defined $2) {      # Got some non-quote/non-comma text
           $field = $2;
       } else {               # Got escaped quotes and stuff
           $field = $1;
           $field =~ s/""/"/g;
       }
    push (@parsedline, $field);
    } # end of while block

    return (@parsedline);
} # end of sub parse_csv_mre2