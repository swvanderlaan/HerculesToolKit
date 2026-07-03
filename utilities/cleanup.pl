#!/usr/bin/perl
# CleanUp.pl -- Clean up badly formatted files
#$ver = "A0.6"; # 15-Mar-1998 JPV
#$ver = "v0.6a"; # 19-Mar-2000 JPV Minor message changes, fixed $0 problem
#$ver = "v0.7"; # 21-Mar-2000 JPV Testing and updates
#$ver = "v0.8"; # 25-Mar-2000 JPV Added run time option notification, cleanup
#$ver = "v0.9"; # 26-Mar-2000 JPV Added -fF, -w options.
#$ver = "v0.10"; # 27-Mar-2000 JPV Added -W option.
#$ver = "v1.0"; # 29-Mar-2000 JPV Cleaned up redundant code, made more modular,
	# Re-wrote to not suck entire input file into memory unless necessary!
	# Used associative array and key order array for option info.
#$ver = "v1.1"; # 03-Apr-2000 JPV Added -P
#$ver = "v1.1a"; # 09-Apr-2000 JPV Make -e to work after -p
#$ver = "v1.1b"; # 12-May-2000 JPV Minor bugfix for -P output in help screen
#$ver = "v1.2"; # 17-Aug-2000 JPV Added -S (-sw does not work), and Program options feedback -s bugfix
#$ver = "v1.2a"; # 05-Dec-2000 JPV Updated $myname for UNIX too
#$ver = "v1.2b"; # 25-Jun-2001 JPV Bugfix for Excel -wWt problem, introduced by Win32::Clipboard change in Perl 5.6.1 (b626)
#$ver = "v1.3"; # 02-Jul-2001 JPV Added -gG sort options
#$ver = "v1.3a"; # 20-Aug-2001 JPV Bugfix, -T option was "T:" needed to be "T"
#$ver = "v1.4"; # 21-Aug-2001 JPV Added -D to replace returns with a space, removed ? pause, print ? to STDOUT
#$ver = "v1.5"; # 22-Sep-2001 JPV Added -E to double hard returns, and -v, -V
#$ver = "v1.6"; # 06-Feb-2002 JPV Added -B to remove hard returns
#$ver = "v1.7"; # 2002-09-13 JPV Added -U to reformat uniq -c output
#$ver = "v1.8"; # 2002-09-19 JPV Added -q for quiet output
$ver = "v1.9"; # 2002-10-06 JPV Changed -k to work with '-k 0'

# TODO
# Add -# to "normalize" US phone numbers to +1 NNN-NNN-NNNN

# TODO
# Fix interaction between sucking entire file into memory (like $opt_D) and
#	running &cleanit (like $opt_T) on each "line" >>>>>> v1.6???
# Better temp file(s):
#	use IO:File; $fh = IO:File->new_tmpfile or die "$myname: error creating temp file = $!";
# Search&Replace lists (see Word Macro)
# Opt_l and Opt_m do not work yet.
# Add Tk interface too?  For v2.0?

# Notes
# Carriage Return (\r Dec 13, Hex \x0D, Ctrl ^m) (DOS = CRLF)
# Line Feed       (\n Dec 10, Hex \x0A, Ctrl ^j) (UNIX = LF)
# $/ is the INPUT line terminator, $\ is the OUTPUT line terminator
##########################################################################
# Main Program

&Initialize;      # Initialize program and variables, check options

&Process;         # Read and process input into output

if (! $opt_q) { print STDERR ("\n\a$myname finished in ",time()-$^T," seconds."); }

# End of Main Program
##########################################################################

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub Initialize {

    (($myname = $0) =~ s/^.*(\/|\\)|\..*$//ig); # remove up to last "\" or "/" and after any "."
#    (($myname = $0) =~ s/^.*\\|\..*$//ig);  # remove stuff up to the last "\" and after the "."
    $Greeting =  ("$myname $ver Copyright 1998-2002 JP Vossen (http://www.jpsdomain.org/)\n");
    $Greeting .= ("    Licensed under the GNU GENERAL PUBLIC LICENSE:\n");
    $Greeting .= ("    See http://www.gnu.org/copyleft/gpl.html for full text and details.\n"); # Version and copyright info

    # Define some (global) Variables
    $spaces = "";                # The number of spaces specified by -v or -w
    $tempfile = "$myname.tmp";   # Temp file name
    $aline = "";                 # A line
    $cntr = 1;                   # Line number counter
    $backfileext = ".bak";       # Backup File extension

    &DefineOpts;                 # Define options and usage for same

    &CheckOptUse;                # Check for option use, the help switch, etc.

} # end of sub Initialize

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub Process {

    my @afile = "";        # Holder for input file

    &OpenFiles;            # Open files, and provide option feedback

    &PrepWork;             # Set input line termination type(s)

    # Get input
    # Normally, we want to read input, process it, and write it out line-by-line.  That way, we can handle
    # files of arbitrary size (though it is slower).  However, when using the Windows clipboard, Opt_r,
    # or Opt_O we must take the entire input file into memory at once!  This limits the size of the input
    # files we can handle.  That's not a problem for processing the clipbaord (given the clipboard size),
    # but we want to handle files of any size for as many functions as possible.

    if ($opt_w) {                               # If we are getting our input from the Windows Clipboard
        use Win32::Clipboard;                   # Import the clipboard module
        # my $cboard = Win32::Clipboard::Get();     # Old version, seems to have changed
        my $cboard  = Win32::Clipboard::GetText();  # (Have to) Read entire clipboard contents
        $cboard =~ s/\r//g;                     # Remove odd CRs ("\r"), if any, the clipboard sticks in
        if ($opt_r) { $cboard =~ s/\n\n/\n/g; } # If Opt r: Remove hard-coded double Returns
        if ($opt_B) { $cboard =~ s/\n//g; }     # If Opt D: Replace ALL returns with a space
        if ($opt_D) { $cboard =~ s/\n/ /g; }    # If Opt D: Replace ALL returns with a space
        if ($opt_E) { $cboard =~ s/\n/\n\n/g; } # If Opt E: Double hard returns
        @afile = split(/\n/,$cboard);           # Break up by lines into array
        if ($opt_g) { @afile = sort { uc($a) cmp uc($b) } @afile; }   # If Opt g, Sort the file, case insensitive
        if ($opt_G) { @afile = sort @afile; }   # If Opt G, Sort the file, case sensitive
        foreach $aline (@afile) {               # For each line in the array
            &CleanIt;                           # Clean it and write it
        } # end of foreach aline
    } elsif ($opt_S) {                          # If we are fixing InfoMan Input (implies -w)
        use Win32::Clipboard;                   # Import the clipboard module
        my $cboard  = Win32::Clipboard::Get();  # (Have to) Read entire clipboard contents
        $cboard =~ s/"//g;                      # Remove quotes around address
        $cboard =~ s/\r\r$//;                   # Remove trailing CR's ("\r") the clipboard sticks in
        if ($opt_r) { $cboard =~ s/\n\n/\n/g; } # If Opt r: Remove hard-coded double Returns
        @afile = split(/\r/,$cboard);           # Break up by lines into array
        foreach $aline (@afile) {               # For each line in the array
            &CleanIt;                           # Clean it and write it
        } # end of foreach aline
    } elsif ($opt_B) {                          # Opt B: Remove ALL Returns
        undef($/);                              # Undefine the INPUT line terminator
        my $afile = <INFILE>;                   # For $opt_B, MUST Read entire input file into memory
        $afile =~ s/\n/~~~/g;                      # Opt B: Remove ALL Returns
        foreach $aline (@afile) {               # For each line in the array
            &CleanIt;                           # Clean it and write it
        } # end of foreach aline
    } elsif ($opt_D) {                          # Opt D: Replace ALL Returns w/ space
        undef($/);                              # Undefine the INPUT line terminator
        my $afile = <INFILE>;                   # For $opt_D, MUST Read entire input file into memory
        $afile =~ s/\n/ /g;                     # Opt D: Replace ALL Returns w/ space
        foreach $aline (@afile) {               # For each line in the array
            &CleanIt;                           # Clean it and write it
        } # end of foreach aline
    } elsif ($opt_E) {                          # Opt E: Double hard returns
        undef($/);
        my $afile = <INFILE>;                   # For $opt_E, MUST Read entire input file into memory
        $afile =~ s/\n/\n\n/g;                  # Opt E: Double hard returns
        foreach $aline (@afile) {               # For each line in the array
            &CleanIt;                           # Clean it and write it
        } # end of foreach aline
    } elsif ($opt_r) {                          # Opt r: Remove hard-coded double Returns
        undef($/);
        my $afile = <INFILE>;                   # For $opt_r, MUST Read entire input file into memory
        $afile =~ s/\n\n/\n/g;                  # Opt r: Remove hard-coded double Returns
        @afile = split(/\n/,$afile);            # Break up by lines into array
        if ($opt_g) { @afile = sort { uc($a) cmp uc($b) } @afile; }   # If Opt g, Sort the file, case insensitive
        if ($opt_G) { @afile = sort @afile; }   # If Opt G, Sort the file, case sensitive
        foreach $aline (@afile) {               # For each line in the array
            &CleanIt;                           # Clean it and write it
        } # end of foreach aline
    } else {                                    # Otherwise, 
        while ($aline = <INFILE>) {             # We read input line-by-line
            &CleanIt;                           # Clean it and write it
        } # end of while input
    } # end of if

    &FinishUp;

} # end of sub Process

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub DefineOpts {

    # Define the options, and usage messages here, since they are used several times.
    # Any changes here must still be reflected below in @optorder,
    # "Some logical error checking for options" and "Program options feedback" though...
    %options = (
        "q" => "Quiet mode",
        "a" => "Remove All leading \">\" or whitespace",
        "t" => "Trim leading and/or trailing whitespace from each line",
        "b" => "Trim leading whitespace from the Beginning of each line",
        "e" => "Trim trailing whitespace from the End of each line",

        "d" => "Use DOS EoL  (Lf --> CRLf) (Default)",
        "u" => "Use UNIX EoL (CRLf --> Lf)",
        "s" => "Fix Screwy CR only EoL (Cr --> [EoL defined by -d or -u])",
        "S" => "Fix Screwy CR only EoL from InfoMan (implies -w)",

        "B" => "Remove ALL Returns",
        "D" => "Replace ALL Returns with a space",
        "E" => "Expand (double) single hard-coded returns (CrLf --> CrLfCrLf)",
        "r" => "Remove hard-coded double Returns (CrLfCrLf -- > CrLf)",
        "R" => "Remove ALL blank lines",
        "g" => "Sort input (-G = case sensitive), requires -w, or -r",
    #    "l" => "Fix chopped up numbered Lists",

        "C" => "Convert to all UPPER CASE",
        "c" => "Convert to all lower CASE",
        "T" => "Convert to all Title Case",
        "n" => "Number each output line",

        "f" => "{string1} F {string2} = Find & replace {string1} with {string2}",
        "p" => "{string} = Prepend (-P = postpend) {string} to each output file line",
        "y" => "{string} = Yank {string} from the beginning (-Y = end) of each line",

    #   "m" => "{number} = The number of spaces of a new paragraph indent",
        "j" => "{number} = {Number} of consecutive spaces to be replace by a TAB",
        "k" => "{number} = Each TAB is replaced by {number} of consecutive spaces",
        "U" => "Reformate 'uniq -c' output with a TAB instead of space.",

        "L" => "In pLace editing (input file renamed - $backfileext)",
        "w" => "Read input from the Windows Clipboard",
        "W" => "Write output to the Windows Clipboard");

    # The order in which options are listed in usage and options reports
    @optorder = ("a", "t", "b", "e", "d", "u", "s", "S", "B", "D", "E", "r", "R", "g", "C", "c", "T", "n", "f", "p", "y", "j", "k", "U", "w", "W");

} # end of sub DefineOpts

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub CheckOptUse {

    # Check options and output usage if needed
    if (("@ARGV" =~ /\?/) || (@ARGV < 1) || (@ARGV > 9)) { #if wrong # of args, or a ? in args - die
        #print STDERR ("\n$Greeting\n  Usage: $myname -i {input file} -o {output file} [other options]\n\n");
        print STDOUT ("\n$Greeting\n  Usage: $myname -i {input file} -o {output file} [other options]\n\n");

        #print STDERR ("\nPress ENTER for option summary.\n");
        #my $in = <STDIN>;

        foreach my $option (@optorder) {                         # For each option, in listed order
            #print STDERR ("  -$option = $options{$option}\n");   # Print option summary
            print STDOUT ("  -$option = $options{$option}\n");   # Print option  summary (to STDOUT so make piping easier
        } # end of foreach option

        die ("  If neither -i nor -o are specified, STDIN/STDOUT are used, respectively.\n");
    } #end of option check if

    # Option Map.  "f" = flag or switch, "a" = parameter takes argument
    # abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
    # fffffaf aaa??faafffffff   fffffaf    f f f ffffff

    # This must go here, though I'd rather put it in the sub above.  getopts removes things from @ARGV
    # so the option check just above would fail...
    use Getopt::Std;                                       # Use Perl5 built-in program option handler
    getopts('abcCdBDeEf:F:gGi:j:k:lLno:p:P:rqRsStTuUvVwWy:Y');   # Define possible flags and parms.

    if (! $opt_q) { print STDERR ("\n$Greeting\n"); }

    if (($opt_v) || ($opt_V)) {     # If we just want the version
        # Just die, since we've already printed the greeting header
        die ("\n");
    } # end of if

    # Some logical error checking for options
    if (($opt_L) && ($opt_o)) { die "$myname: Can't use in pLace editing with an output file name!\n"; }
    if (($opt_s) && (($opt_w) || ($opt_W))) { die "$myname: Can't fix screwy CR with the Windows clipboard! Use -S.\n"; }
    if (($opt_L) && (($opt_w) || ($opt_W))) { die "$myname: Can't use in pLace editing with the Windows clipboard!\n"; }
    if (($opt_S) && ($opt_w)) { die "$myname: -S with -w is redundant.  -S impies -w!\n"; }
    if (($opt_i) && ($opt_w)) { die "$myname: Can't get input from file and Windows clipboard at the same time!\n"; }
    if (($opt_o) && ($opt_W)) { die "$myname: Can't send output to file and Windows clipboard at the same time!\n"; }
    if (($opt_F) && (! $opt_f)) { die "$myname: Can't have -F without -f!\n"; }  # But you can have -f without -F!!!
    if (($opt_c) && ($opt_C)) { die "$myname: Can't convert to upper AND lower case!\n"; }
    if (($opt_c) && ($opt_T)) { die "$myname: Can't convert to lower AND title case!\n"; }
    if (($opt_C) && ($opt_T)) { die "$myname: Can't convert to upper AND title case!\n"; }
    if (($opt_d) && ($opt_u)) { die "$myname: Can't use DOS and UNIX line termination!\n"; }
    if (($opt_D) && (($opt_g) || ($opt_G))) { die "$myname: Can't remove all returns and sort at the same time!\n"; }
    if (($opt_r) && ($opt_R)) { die "$myname: Can't remove double returns at the same time as all blank lines!\n"; }
    if (($opt_E) && ($opt_R)) { die "$myname: Can't add double returns when removing all blank lines!\n"; }
    if (($opt_r) && ($opt_E)) { die "$myname: Can't add and remove returns at the same time!\n"; }
    if (($opt_j) && ($opt_k)) { die "$myname: Can't convert tabs to spaces and spaces to tabs at the same time!\n"; }
    if (($opt_B) && ($opt_D)) { die "$myname: Can't replace Returns with space and remove them at the same time!\n"; }
    if (($opt_B) && (($opt_t) || ($opt_b) || ($opt_e))) { die "$myname: Can't trip and remove Returns at the same time yet!\n"; }
    if (($opt_D) && (($opt_t) || ($opt_b) || ($opt_e))) { die "$myname: Can't trip and replace Returns at the same time yet!\n"; }
    if (($opt_g) && (! (($opt_w) || ($opt_r)))) { die "$myname: Can't have -g without -w or -r!\n"; }
    if (($opt_G) && (! (($opt_w) || ($opt_r)))) { die "$myname: Can't have -G without -w or -r!\n"; }

} # end of sub CheckOptUse

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub OpenFiles {

    if ($opt_L) {                             # If we are doing "in pLace" editing
        $opt_o = $opt_i;                      # The output file is the "real name"
        $opt_i = $opt_i . $backfileext;       # The input file is the "backup file" name
        rename ($opt_o, $opt_i) || die "\n$myname: Fatal Error backing up $opt_o to $opt_i. $!\n";  # Rename 'em
    } # end of if in place editing

    if ($opt_W) { $opt_o = "$tempfile"; }     # If output to Windows clipboard, use temp file
    if (! $opt_i) { $opt_i = "-"; }           # If no input file specified, use STDIN
    if (! $opt_o) { $opt_o = "-"; }           # If no input file specified, use STDOUT

    open (INFILE, "$opt_i") || die "$myname: error opening $opt_i = $!";
    open (OUTFILE, ">$opt_o") || die "$myname: error opening $opt_o = $!";

    binmode (OUTFILE); # Put the output file into binary mode so we control the line termination

    if ($opt_i =~ /-/) { $opt_i = "STDIN"; }   # If no input file specified, display STDIN
    if ($opt_o =~ /-/) { $opt_o = "STDOUT"; }  # If no input file specified, display STDOUT
    if ($opt_w) { $opt_i = "CLIPBOARD"; }      # If using it, display CLIPBOARD
    if ($opt_W) { $opt_o = "CLIPBOARD"; }      # If using it, display CLIPBOARD

    if (! $opt_q) {
        print STDERR ("\tCleaning up $opt_i to $opt_o using options:\n");
    
        # Program options feedback
        if ($opt_a) { print STDERR ("\t-a = $options{a}\n"); }
        if ($opt_t) { print STDERR ("\t-t = $options{t}\n"); }
        if ($opt_b) { print STDERR ("\t-b = $options{b}\n"); }
        if ($opt_e) { print STDERR ("\t-e = $options{e}\n"); }
        if ($opt_E) { print STDERR ("\t-E = $options{E}\n"); }
        if ($opt_d) { print STDERR ("\t-d = $options{d}\n"); }
        if ($opt_s) { print STDERR ("\t-s = $options{s}\n"); }
        if ($opt_S) { print STDERR ("\t-S = $options{S}\n"); }
        if ($opt_u) { print STDERR ("\t-u = $options{u}\n"); }
        if ($opt_R) { print STDERR ("\t-R = $options{R}\n"); }
        if (($opt_g) || ($opt_G)) { print STDERR ("\t-gG $options{g}\n"); }
        if ($opt_C) { print STDERR ("\t-C = $options{C}\n"); }
        if ($opt_c) { print STDERR ("\t-c = $options{c}\n"); }
        if ($opt_B) { print STDERR ("\t-B = $options{B}\n"); }
        if ($opt_D) { print STDERR ("\t-D = $options{D}\n"); }
        if ($opt_r) { print STDERR ("\t-r = $options{r}\n"); }
        if ($opt_T) { print STDERR ("\t-T = $options{T}\n"); }
        if ($opt_n) { print STDERR ("\t-n = $options{n}\n"); }
        if ($opt_f) { print STDERR ("\t-f $options{f}\n"); }
        if (($opt_p) || ($opt_P)) { print STDERR ("\t-pP $options{p}\n"); }
        if (($opt_y) || ($opt_Y)) { print STDERR ("\t-yY $options{y}\n"); }
        if ($opt_j) { print STDERR ("\t-j $options{j}\n"); }
        if (defined ($opt_k)) { print STDERR ("\t-k $options{k}\n"); }
        if ($opt_U) { print STDERR ("\t-U $options{U}\n"); }
        if ($opt_L) { print STDERR ("\t-L = $options{L}\n"); }
        if ($opt_w) { print STDERR ("\t-w = $options{w}\n"); }
        if ($opt_W) { print STDERR ("\t-W = $options{W}\n"); }
    
        if (($opt_b) && ($opt_e)) { warn "\tNext time, try using -t instead of -b -e!\n"; }
        print STDERR ("");
    } # end of if quiet mode

} # end of sub OpenFiles

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub PrepWork {

    if ($opt_s) {
        $/ = "\r";                                  # Set input line termination to screwy CR only EoL Style
    } # end of opt_s if

    # Setting this option results in automatic line termination, so if you add "\n" in the string, you get doubles!
    if ($opt_u) {
        $\ = "\n";                                  # Set output line termination to UNIX Style
    } else {
        $\ = "\r\n";                                # Set output line termination to DOS Style (Default)
    } # end of line term. if

    # If doing space <--> tab conversion, create "$spaces variable
    if ($opt_j) {
        for (1..$opt_j) { $spaces .= " "; }
    } elsif (defined ($opt_k)) {
        $spaces = "";
        for (1..$opt_k) { $spaces .= " "; }
    } # end of if

} # end of sub PrepWork

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub CleanIt {

    chomp ($aline);                              # remove trailing line term. defined by $\

    ###### Stuff to do on input...
    if ($opt_f) { $aline =~ s/$opt_f/$opt_F/g; } # Opt fF: Search & Replace
    if ($opt_p) { $aline =  $opt_p . $aline; }   # Opt p: Prepend {string}
    if ($opt_P) { $aline .= $opt_P; }            # Opt P: Postpend {string}
    if ($opt_y) { $aline =~ s/^$opt_y//g; }      # Opt y: Remove leading {string}
    if ($opt_Y) { $aline =~ s/$opt_Y$//g; }      # Opt Y: Remove trailing {string}

    if ($opt_j) { $aline =~ s/$spaces/\t/g; }    # Opt j: Replace # of spaces with a TAB
    if (defined ($opt_k)) { $aline =~ s/\t/$spaces/g; }    # Opt k: Replace TAB with # of spaces
    if ($opt_U) { $aline =~ s/^\s+(\d+)\s+(.*)$/$1\t$2/g; }    # Opt U: Replace space w/ TAB in uniq -c

    if ($opt_a) { $aline =~ s/^(>|\s)+//g; }     # Opt a: Remove all leading ">" or whitespace
    if ($opt_t) { $aline =~ s/^\s+|\s+$//g; }    # Opt t: Remove all leading/trailing whitespace
    if ($opt_b) { $aline =~ s/^\s+//g; }         # Opt b: Remove all leading whitespace
    if ($opt_e) { $aline =~ s/\s+$//g; }         # Opt e: Remove all trailing whitespace
    if (($opt_R) && ($aline =~ /^$/)) { next; }  # Opt R: Remove blank lines

    if ($opt_c) { $aline = lc($aline); }         # Opt c: lower case line
    if ($opt_C) { $aline = uc($aline); }         # Opt C: UPPER case line
    if ($opt_T) { $aline =~ s/(\w+)/\u\L$1/g; }  # Opt T: Title Case Line

    ###### Stuff to do on output...
    if ($opt_n) {
        printf OUTFILE ("%4d $aline\n",$cntr++); # Opt n: Output has numbered lines
    } else {
        print OUTFILE ("$aline");                # Default Output
    } # end of if

} # end of sub CleanIt

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FinishUp {
    close (INFILE);
    close (OUTFILE);

    if ($opt_W) {                            # If we are sending output to the Windows clipboard

        use Win32::Clipboard;                # Import the module
        open (TMPFILE, "$tempfile") || die "$myname: error opening temp file $tempfile = $!";

        binmode (TMPFILE);                   # Put into BINMODE so we don't mess with line termination
        undef ($/);                          # Undefine the input line terminator so we grab the whole thing
        my $cboard = <TMPFILE>;              # Grab it
        Win32::Clipboard::Set("$cboard");    # Send it to the clipboard

        close (TMPFILE);                     # Close, then delete (unlink) the temp file
        unlink("$tempfile") || die "$myname: Could not delete temp file $tempfile: $!\n";

    } # end of if using windows clipboard
} # end of sub FinishUp
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Broken Stuff!
#### Broken opt_l = fix numbered list
#    if (($opt_l) && ($aline =~ /^\d/)) {          # Opt l: and the line starts with a number
#    ($templine .= $aline) =~ s/^(\s+|>+)|\s+$//g; # Cat the current line, without leading or trailing whitespace
#    $curline++;
#
#    chomp ($aline);                               # remove trailing CR, LF or both
#       if ($aline =~ /^\d|^\s*\n$/) {             # keep going until we hit another number
#            $curline--;
#            $aline = $templine;
#            $templine = "";
#        } else {
#            (($templine .= " ") .= $aline) =~ s/^(\s+|>+)|\s+$//g; # Cat the current line, without leading or trailing whitespace
#            $curline++;
#            chomp ($aline);                       # remove trailing CR, LF or both
#        } # end of if
#    } # end opt_l if
#### end Broken opt_l = fix numbered list

# Fix Sentence (Search and Replace)
	# Replace "{whitespace}" with " " (this might be a bit dangerous?)
	# Replace ".{whitespace}" with ".  "
	# Replace "Mr.  " with "Mr. "
	# Replace "Mrs.  " with "Mrs. "
	# Replace "Ms.  " with "Ms. "
	# Replace "St.  " with "St. "
	# Replace "Fr.  " with "Fr. "
	# Replace "Jr.  " with "Jr. "
	# Replace "Sr.  " with "Sr. "
	# Replace "Misc.  " with "Misc. "
	# Replace "etc.  " with "etc. "
	# Replace "?{whitespace}" with "?  "
	# Replace "!{whitespace}" with "!  "
	# Replace '."{whitespace}' with '."  '
	# Replace '?"{whitespace}' with '?"  '
	# Replace '!"{whitespace}' with '!"  '
	# Replace ":{whitespace}" with ":  "
	# Capitalize the first letter of the sentence
	# Capitalize " I "
	# Capitalize " I'm "
	# Capitalize " I'll "
	# Remove trailing whitespace at end of paragraph



# From Word Macro, Reformat ASCII (much of this is redundant with "Fix Sentence (Search and Replace)"
#****************************************************** Initialization
#Marker1$ = ".)@(."          'Marking character for Periods
#Marker2$ = "?)@(?"          'Marking character for Question Marks
#Marker3$ = "!)@(!"          'Marking character for Exclamation points
#Marker4$ = ":)@(:"          'Marking character for Colons
#
#****************************************************** Phase 1
#Replace all CR with marker character.
#Replace single marker followed by Tab with 2CR & tab.
#Replace single marker followed by $IndentSpaces with 2CR & tab.
#Replace marker pairs with a double CR.
#Replace each remaining marker with a space.
#
#****************************************************** Phase 2
#Replace each period & space with a marker1.
#Replace each question Mark & space with a marker2.
#Replace each exclamation mark & space with a marker3.
#Replace each colon & space with a marker4.
#
#****************************************************** Phase 3
#Replace all double spaces with a space.
#Replace all double spaces with a space again to catch odd numbers.
#
#****************************************************** Phase 4
#Replace each marker1 with a period & 2space.
#Replace each marker2 with an question mark & 2space.
#Replace each marker3 with a exclamation point & 2space.
#Replace each marker4 with a colon & 2space.
#
#****************************************************** Phase 5
#Replace each 3space with a 2space.
#Replace each 2space CR with a CR.

