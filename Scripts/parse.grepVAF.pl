use strict;
use warnings;
use Data::Dumper;

open (READ, "<$ARGV[0]");

my %data;
my $head = <READ>;
while (<READ>) {
	chomp;
	my @mas = split/\t/;
	my @current = split/:/, $mas[1];
	my @result;
	foreach my $obs (@mas[2..(scalar @mas - 1)]) {
		my @data = split/:/, $obs;
		push @result, $current[1]/($data[1] + 0.0001);
		}
	@result = sort {$a <=> $b} @result;
	$data{$mas[0]} = [@result];
	}

close READ;

foreach my $key (sort {$data{$a}->[0] <=> $data{$b}->[0]} keys %data) {
	print "$key\t",join("\t", @{$data{$key}}),"\n";
	}















