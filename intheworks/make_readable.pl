#! /usr/bin/perl -w

my $pad=" ";
if (@ARGV && $ARGV[0]=~m/^\d+$/ && !(-e $ARGV[0])) {
	my $padlength=shift(@ARGV) ;
	$pad="";
	$pad.=" " foreach(1..$padlength) ;
}

my @all=<>;
my @lengths;
my @numeric;
my $line=0;
foreach (@all) {
	my @this=split ' ';
	foreach $col (0..$#this) {
		push @lengths, 0 if $line==0;
		push @numeric, 1 if $line==0;
		$lengths[$col]=length($this[$col]) if $lengths[$col]<length($this[$col]) ;
		$numeric[$col]=0 if $this[$col]=~m/[A-z]+/ ;
	}
	$line++;
}
foreach (@all) {
	chomp;
	my @line=split ' ';
	my $out="";
	foreach $i (0..$#line) {
		if ($numeric[$i]) { $out.= " " foreach (length($line[$i])+1..$lengths[$i]) ; }
		$out.= "$line[$i]";
		if (!$numeric[$i] && $i<$#line) { $out.= " " foreach (length($line[$i])+1..$lengths[$i]) ; }
		$out.= "$pad" if $i<$#line;
	}
	print "$out\n";
}
