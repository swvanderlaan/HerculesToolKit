#!/usr/bin/perl
# Merge.pl -- Merge two files using some key
#$ver = "v1.0"; # 12-Mar-1998 JPV
#$ver = "v1.1"; # 25-Mar-1998 JPV minor bug fixes
#$ver = "v2.0"; # 08-June-1998 JPV Re-wrote to track multi-fields in both files, and deal with field collision
#$ver = "v2.1"; # 09-June-1998 JPV Added ability to override and re-order fields
#$ver = "v2.2"; # 10-June-1998 JPV Bug fix, added \S+ to whitespace removal, undef(@inrec), collision array, invalid key field
#$ver = "v2.2a"; # 23-July-1998 JPV Added $^T for time count
#$ver = "v2.3"; # 18-Mar-2000 JPV Bugfixs for Keyfield, case checking
#$ver = "v2.3a"; # 20-Mar-2000 JPV Bugfixs $f2keyfield
#$ver = "v2.4"; # 10-Oct-2000 JPV Added keyfield duplication detection
#$ver = "v2.4a"; # 11-Oct-2000 JPV Added listing dup. key to keyfield duplication detection
#$ver = "v2.5"; # 31-Mar-2001 JPV Fixed comment typos and NASTY whitespace trim bug (deleted feilds with whitespace instead of triming them), introduced in v2.2
#$ver = "v2.6"; # 2002-07-24 JPV Added \t in error output files
$ver = "v2.7"; # 2002-09-30 JPV Added note for %f1ovride

# Note: the array $outarray{$inrec[$f1keyfield]."+".$fld} has the ."+". because some records
# end with a number, which messes up the subscript.  E.G. "Record1" . 8 becomes "Record18";
# with the + it becomes "Record1+8".
#
# Also, Read1 and Read2 are very redundant, but this is because 1) it's a pain to pass
# arrays to Perl subroutines and 2) they *may* need to be different to deal with different
# source files.
####################################################################################
# Program initialization

(($myname = $0) =~ s/^.*\\|\..*$//ig);  # remove stuff up to the last "\" and after the "."
$Greeting =  ("$myname $ver Copyright 1998-2000 JP Vossen (http://www.jpsdomain.org/)\n");
$Greeting .= ("    Licensed under the GNU GENERAL PUBLIC LICENSE:\n");
$Greeting .= ("    See http://www.gnu.org/copyleft/gpl.html for full text and details.\n"); # Version and copyright info

if (("@ARGV" =~ /\?$/) || (@ARGV > 0) || (@ARGV < 0)) { #if wrong # of args, or a ? in args - die
    die ("\n$Greeting\n\n\tUsage: $myname\n");
} #end of argument check if

####################################################################################
# Program definitions (Probably need to be modified!)

# Input File 1 Parms =====================================
$infile1name = "File1.in";        # Input file 1 name (F1)
  $f1header = 0;                    # Get field Labels from top line (header) of File 1
  $f1keyfield = 0;                  # Input file 1 "key" or "index" field (fields start at Zero)
  $f1delim = "\t";                  # Input file 1 field delimiter (\t = tab)
# By default, F2 fields OVERWRITE F1 fields in field collisions.  F1 OverRide defines the fields in F1
# that take precedence over fields from F2.  Set the F1 field = to any non-zero number.
# Also see ReadInFile2 field collision section, where case sensitivity may be adjusted.
# NOTE: Even though this is for F1, you must use the F2 field numbers!!!
  # %f1ovride = (1=>1,2=>1);          # Typical, F1 fields 1 and 2 over-ride F2 fields 1 and 2
  # %f1ovride = (7=>1);               # Keeps the User Context from F1
# F1 input field number and output field location (fields start at Zero)
#  %f1fio = (0=>0,1=>2,2=>1);            # Typical, use fields 0, 1 and 2, and swap fields 1 and 2 in output
  %f1fio = (0=>0,1=>1,2=>2,3=>3,4=>4,5=>5,6=>6,7=>7,8=>8,9=>9);        # Typical
#  %f1fio = (0=>0,1=>2,2=>1);        # Typical, use fields 0, 1 and 2, and swap fields 1 and 2 in output

# Input File 2 Parms =====================================
$infile2name = "File2.in";        # Input file 2 name (F2)
  $f2header = 0;                    # Get field Labels from top line (header) of File 2
  $f2keyfield = 0;                  # Input file 2 "key" or "index" field (fields start at Zero)
  $f2delim = "\t";                  # Input file 2 field delimiter (\t = tab)
# F2 input field number and output field location (fields start at Zero)
#  %f2fio = (0=>3,1=>5,2=>4);            # Typical, append fields 0, 1 and 2, and swap fields 1 and 2 in output
  %f2fio = (0=>10,1=>11,2=>12,3=>13,4=>14,5=>15,6=>16,7=>17,8=>18,9=>19);        # Typical
#  %f2fio = (0=>0,3=>3,4=>4);        # Typical, use fields 0, 3 and 4 (so output is F1/F2-0; F1,2; F1,1; F2,3; F2,4)

# Output File Parms ======================================
$badrecfilename = "Merged.bad";     # Bad Record output file name (if any)
$collisionfilename = "Merged.col";  # field Collision output file name (if any)
$outfilename = "Merged.out";        # Merged data output file name
  $ofdelim = "\t";                  # Output file field delimiter (\t = tab)

####################################################################################
# Main Program

print STDERR ("\n$Greeting\nMerging $infile1name and $infile2name into $outfilename...\n");

open (INFILE1, $infile1name) || die ("$myname: Fatal Error opening $infile1name!\n");
open (INFILE2, $infile2name) || die ("$myname: Fatal Error opening $infile2name!\n");
open (OUTFILE, ">$outfilename") || die ("$myname: Fatal Error opening $outfilename for output!\n");

&ReadInFile1;     # Read the first file and load into output array

&ReadInFile2;     # Read the second file and load into output array

&WriteOutput;     # Write the output array to output file

print STDERR ("\n\a$myname finished in ",time()-$^T," seconds.\n\n");

# End of Main Program
####################################################################################

sub ReadInFile1 {

    while ($aline = <INFILE1>) {                         # While there is input
        chomp($aline);                                   # Remove trailing CR/LF
        undef(@inrec);                                   # Make sure array is empty
        @inrec = split (/$f1delim/,$aline);              # Split the line at the F1 Delimiter
        $inreckey = "\U$inrec[$f1keyfield]\E";           # Make record key field ALL CAPS
        if (! $inreckey) {                               # If the Key field is missing
            push(@badrecs, "Keyfield Missing in $infile1name:\t$aline");  # Remember the bad record
            $tlbadrecs++;                                # Count the bad record
            next;                                        # Do not process this record any further
        } # end of if not keyfield

        if (defined($f1keys{$inreckey})) {                # If we have a duplicate keyfield
            push(@badrecs, "Duplicate Keyfield '$inreckey' in $infile1name:\t$aline"); # Remember the bad record
            $tlbadrecs++;                                 # Count the bad record
            next;                                         # Do not process this record any further
        } else {                                          # Otherwise
            $f1keys{$inreckey} = $inreckey;               # Remember F1 Keys we've seen
        } # end of if duplicate keyfield

        foreach $fld (sort {$a <=> $b} keys %f1fio) {    # For each field to be included in output
            $inrec[$fld] =~ s/^\s+|\s+$//g;              # Remove leading/trailing whitespace around a field
        #   $inrec[$fld] = "\U$inrec[$fld]\E";           # Make field ALL CAPS (Function moved to compares)
            if ($f1header == "1") {                      # If F1 has a header
                $outarray{$f1fio{$fld}} = $inrec[$fld];  # Load header into Output Array
            } else {                                     # Otherwise
                $outarray{$inreckey."+".$f1fio{$fld}} = $inrec[$fld]; # Load record into Output Array
                $recordarray{$inreckey} = $infile1name;               # Load record key into record array
            } # end of if header
        } # end of foreach Fld
        $f1header = 2;                                    # We have processed the F1 header, if any
    } # end of while
    close (INFILE1);

} #End of sub ReadInFile1

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ReadInFile2 {

    while ($aline = <INFILE2>) {                         # While there is input
        chomp($aline);                                   # Remove trailing CR/LF
        undef(@inrec);                                   # Make sure array is empty
        @inrec = split (/$f2delim/,$aline);              # Split the line at the F2 Delimiter
        $inreckey = "\U$inrec[$f2keyfield]\E";           # Make record key field ALL CAPS
        if (! $inreckey) {                               # If the Key field is missing
            push(@badrecs, "Keyfield Missing in $infile2name:\t$aline");  # Remember the bad record
            $tlbadrecs++;                                # Count the bad record
            next;                                        # Do not process this record any further
        } # end of if not keyfield

        if (defined($f2keys{$inreckey})) {                # If we have a duplicate keyfield
            push(@badrecs, "Duplicate Keyfield '$inreckey' in $infile2name:\t$aline"); # Remember the bad record
            $tlbadrecs++;                                 # Count the bad record
            next;                                         # Do not process this record any further
        } else {                                          # Otherwise
            $f2keys{$inreckey} = $inreckey;               # Remember F2 Keys we've seen
        } # end of if duplicate keyfield

        foreach $fld (sort {$a <=> $b} keys %f2fio) {    # For each field to be included in output
            $inrec[$fld] =~ s/^\s+|\s+$//g;              # Remove leading/trailing whitespace around a field
        #   $inrec[$fld] = "\U$inrec[$fld]\E";           # Make field ALL CAPS (Function moved to compares)
            if ($f2header == "1") {                      # If F2 has a header
                $outarray{$f2fio{$fld}} = $inrec[$fld];  # Load header into Output Array
            } else {                                     # Otherwise

                # Look for field collisions and deal with them, see over-ride parms, above.
                # This only applies when cross-checking that a field from F1 matches a field from F2
                # E.G.   %f1fio = (0=>0,1=>1) and %f1fio = (0=>3,1=>1)
                $f1field = $outarray{$inreckey."+".$f2fio{$fld}};         # Use a simple name for the existing F1 field, if any

                # Adjust the following two lines for FIELD COLLISON CASE SENSITIVITY!!!
#               if (($f1field) && ($f1field ne $inrec[$fld])) {           # If we have a CASE MATTERS field collision
                if (($f1field) && (uc($f1field) ne uc($inrec[$fld]))) {   # If we have a CASE IGNORED field collision

                    $fldcollisions++;                                     # Count it
#                   warn "fld: ~$fld~\tinrec[fld]: ~$inrec[$fld]~\tf2fio{fld}: ~$f2fio{$fld}~\tf1field: ~$f1field~\n";
                    if ($f1ovride{$fld}) {                                # And it's an F1 over-ride field
                        $collisions{$fldcollisions} = $inreckey . "\t" . $outarray{$f2fio{$fld}} . " (F2)[F1OV]\t" . $f1field . "\t" . $inrec[$fld]; # Save it as F1
                    } else {                                              # Otherwise
                        $collisions{$fldcollisions} = $inreckey . "\t" . $outarray{$f2fio{$fld}} . " (F2)\t" . $f1field . "\t" . $inrec[$fld]; # Save it as F2
                    } # end of in f1override
                } # end of if

                if (! $f1ovride{$fld}) {                                  # If this field is NOT an F1 over-ride
                    $outarray{$inreckey."+".$f2fio{$fld}} = $inrec[$fld]; # OVERWRITE F1 field with F2 field
                } # end of if not                                         # If it IS, leave the field from F1 alone.
                $recordarray{$inreckey} = $infile2name;                   # Load record key into record array
            } # end of if header
        } # end of foreach Fld
        $f2header = 2;                                                    # We have processed the F2 header, if any
    } # end of while
    close (INFILE2);

} # End of sub ReadInFile2

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub WriteOutput {

    # Create Output Order list from Input field lists
    @oorder = values(%f1fio);                                 # Get the Output Order from File 1 fields
    push(@oorder, values(%f2fio));                            # Add the File 2 fields
    @oorder = sort {$a <=> $b} grep((! $Seen{$_}++),@oorder); # Sort, numerically, unique

    # Process Header
    if ($f1header || $f2header) {                      # If there is any header
        foreach $fld (@oorder) {                       # For each output field
            print OUTFILE ("$outarray{$fld}$ofdelim"); # Write the header
        } # end of foreach fld
        print OUTFILE ("\n");                          # End header record with NewLine
    } # end of if

    # Process Records
    foreach $rec (sort keys %recordarray) {                       # For each record in the record array
        foreach $fld (@oorder) {                                  # For each output field (already unique and sorted)
            print OUTFILE ("$outarray{$rec.\"+\".$fld}$ofdelim"); # write it
        } # end of foreach fld
        print OUTFILE ("\n");                                     # End record with a Newline
    } # end of foreach rec
    close (OUTFILE);

    # Process field Collisions, if any
    if ($fldcollisions) {
        print STDERR ("\n\tThere were $fldcollisions field Collisions written to $collisionfilename!\n"); # write header to the screen
        open (COLOUTFILE, ">$collisionfilename") || die "$myname: error opening $collisionfilename for output!\nCollision information lost!\n\n";
        print COLOUTFILE ("Key\tFld Hdr (Src File)\t$infile1name field\t$infile2name field\n"); # write header
        foreach $rec (sort keys %collisions) {                    # For each record in the collision array
            print COLOUTFILE ("$collisions{$rec}\n");             # write it
        } # end of foreach rec
    } # end if fldcollisions    
    close (COLOUTFILE);

    # Process Bad Records, if any
    if ($tlbadrecs) {
        print STDERR ("\n\tThere were $tlbadrecs Bad Records written to $badrecfilename!\n"); # write header to the screen
        open (BADOUTFILE, ">$badrecfilename") || die "$myname: error opening $badrecfilename for output!\nBad Record information lost!\n\n";
        print BADOUTFILE ("Records with errors!\n\n"); # write header
        foreach $rec (@badrecs) {                    # For each record in the bad record array
            print BADOUTFILE ("$rec\n");             # write it
        } # end of foreach rec
    } # end if tlbadrecs
    close (BADOUTFILE);

} # End of sub WriteOutput

