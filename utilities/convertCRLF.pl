#!/usr/bin/perl
#
# author: P.I.W. de Bakker
#

while (<STDIN>) {
    s/\r\n/\n/g;
    s/\r/\n/g;
    print $_;
}

