use strict;
use warnings;
use Data::Dumper;

my %known;
$known{'CHR1'} = '1';
$known{'CHR2'} = '1';
$known{'CHR3'} = '1';
$known{'CHR4'} = '1';
$known{'CHR5'} = '1';
$known{'CHR6'} = '1';
$known{'CHR7'} = '1';
$known{'CHR8'} = '1';
$known{'CHR9'} = '1';
$known{'CHR10'} = '1';
$known{'CHR11'} = '1';
$known{'CHR12'} = '1';
$known{'CHR13'} = '1';
$known{'CHR14'} = '1';
$known{'CHR15'} = '1';
$known{'CHR16'} = '1';
$known{'CHR17'} = '1';
$known{'CHR18'} = '1';
$known{'CHR19'} = '1';
$known{'CHR20'} = '1';
$known{'CHR21'} = '1';
$known{'CHR22'} = '1';
$known{'CHRX'} = '1';
$known{'CHRY'} = '1';

open (READ, "<$ARGV[0]");

while (<READ>) {
	chomp;
	my @mas = split/\t/;
	next if m!^#!;
	my $tmp = uc($mas[0]);
	if ((not(defined($known{$tmp})))and(not(defined($known{"CHR$tmp"})))) {
		next;
		}
	print "$mas[0]:$mas[1]$mas[3]>$mas[4]\n";
	}

close READ;



