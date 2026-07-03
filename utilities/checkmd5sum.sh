#!/bin/sh
# checkmd5sum--Verify downloaded files against an MD5SUM file

# $Id: checkmd5sum,v 1.2 2004/01/03 08:27:17 root Exp $
# $Log: checkmd5sum,v $
# Revision 1.2  2004/01/03 08:27:17  root
# Added dos2unix and gawk for more robustness
#
# Revision 1.1  2003/10/30 23:45:13  root
# Added tr to nuke extra *'s when needed
#
# Revision 1.0  2003/08/30 06:35:21  root
# Initial Revision
#

VER='$Revision: 1.2 $' # JP Vossen <jp@jpsdomain.org>

CAT='/bin/cat'
if [ "$1" = "-h" -o "$1" = "--help" ]; then
    ${CAT} <<-EoN

	usage: $0 ({source to check}) ({md5sum file})
	    e.g.
	    $0
	    $0 *.zip
	    $0 *.iso MD5SUM

	Verify downloaded files against an MD5SUM file.
	'Source to check' defaults to '*.iso'.
	'Md5sum file' defaults to 'MD5SUM'.
EoN
    exit 1
fi

# Use variables to hard coded paths to prevent Bad Things(tm).
CAT='/bin/cat'
CUT='/bin/cut'
GREP='/bin/grep'
DIFF='/usr/bin/diff'
ECHO='/bin/echo'
RM='/bin/rm'
MD5SUM='/usr/bin/md5sum'
TR='/usr/bin/tr'
DOS2UNIX='/usr/bin/dos2unix'
GAWK='/bin/gawk'

# Check for an argument or use the default
SRC=${1:-*.iso}
SUMS=${2:-MD5SUM}

${ECHO} ''
${ECHO} "Verifying ${SRC} against ${SUMS}:"
${ECHO} ''

for srcfile in ${SRC} ; do
    # Start clean
    ${RM} -f Known_Good Calculated

    # Find and display the known good sum
    # Gawk removes extra spaces bewtween sum and file name
    ${GREP} ${srcfile} ${SUMS} | ${TR} '/*/' ' ' | ${GAWK} '{ print $1, $2 }' > Known_Good
    ${DOS2UNIX} -q Known_Good    # Remove DOS line endings, just in case
    ${CAT} Known_Good

    # Calculate and display the actual sum
    # Gawk removes extra spaces bewtween sum and file name
    ${MD5SUM} ${srcfile} | ${TR} '/*/' ' ' | ${GAWK} '{ print $1, $2 }' > Calculated
    ${DOS2UNIX} -q Calculated    # Remove DOS line endings, just in case
    ${CAT} Calculated

    # See if they are different and notify.  The cut removes the
    # leading word "File" from diff's output to be more readable.
    ${DIFF} -qs Known_Good Calculated | ${CUT} -f2- -d' '

    # Clean up
    ${RM} -f Known_Good Calculated
    ${ECHO} ''
done
