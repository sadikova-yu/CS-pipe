use strict;
use warnings;

open (BED, "<$ARGV[1]");

my @amplicons;
while (<BED>) {
	chomp;
	next if m!track!;
	my @mas = split/\t/;
	$mas[0] = lc($mas[0]);
	$mas[0] =~ s/chr//;
	$mas[0] = uc($mas[0]);
	$mas[0] = "chr$mas[0]";
	push(@amplicons, [$mas[0], $mas[1], $mas[2]]);
	}

close BED;

open (VarList, "<$ARGV[0]");

while (<VarList>) {
	chomp;
	my $line = $_;
	if ($line =~ /(\S+):(\d+)(\S+)>(\S+)/) {
		my $chr = $1;
		my $pos = $2;
		my $ref = $3;
		my $alt = $4;
		$chr = lc($chr);
		$chr =~ s/chr//;
		$chr = uc($chr);
		$chr = "chr$chr";
		my $check = 0;
		foreach my $arg (@amplicons) {
			next if $arg->[0] ne $chr;
			next if $pos < $arg->[1];
			next if $pos > $arg->[2];
			$check = 1;
			}
		print "$line\n" if $check eq 1;
		}
	}

close VarList;



