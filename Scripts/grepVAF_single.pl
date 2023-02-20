use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Aoddb;

my $DB = AODDB->fast_connect();
my $Barcode = $DB->Barcode($ARGV[1]);
my $bam = $Barcode->bam->path;
my @files = ($ARGV[1]);
my $varList = $ARGV[0];
$varList = 'list' unless defined $varList;
open (READ, "<$varList");

while (<READ>) {
	chomp;
	my @mas = split/\t/;
	my $mut = $mas[0];
	print "$mut";
	my $chr;
	my $position;
	if ($mut =~ /(\S+):(\d+)(\S+)>(\S+)/) {$chr = lc($1);$position = $2;}
	for (my $i = 0; $i < scalar @files; $i++) {
		my $Barcode = $DB->Barcode($files[$i]);
		my $bam = $Barcode->bam->path;
		my $freq = `perl /home/onco-admin/ATLAS_software/aod-pipe/Pipe/popa/Scripts/HF_grep_var_count.pl $bam \$hg19 '$mut' both`;
		chomp $freq;
		$freq = 0 if $freq eq '';
		my $coverage = `samtools depth -d 100000 $bam -r '$chr:$position-$position'`;
		chomp $coverage;
		$coverage = [split /\t/, $coverage];
		$coverage = $coverage->[2];
		$coverage = 0 unless defined $coverage;
		chomp $freq;
		print "\t";
		print "$coverage\t";
		print "$freq";
		}
	print "\n";
	}

close READ;













