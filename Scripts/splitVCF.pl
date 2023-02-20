use strict;
use warnings;
open (READ, "<$ARGV[0]");

while (<READ>) {
	chomp;
	if ($_ =~ /(\S+):(\d+)(\w+)>(\S+)/) {
		my @alleles = split/,/,$4;
		foreach my $allele (@alleles) {
			print "$1:$2$3>$allele\n";
			}
		}
	}

close READ;
