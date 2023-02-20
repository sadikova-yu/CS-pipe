use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Aoddb;

my $DB = AODDB->fast_connect();
my $barcodeName = $ARGV[1];
my @files = ($barcodeName);
print "Variant\t$barcodeName";
foreach my $Barcode ($DB->barcodes) {
	next if $Barcode->get_id eq $barcodeName;
	next unless defined $Barcode->info->{panelcode};
	next if $Barcode->info->{panelcode} ne $DB->Barcode($barcodeName)->info->{'panelcode'};
	push (@files, $Barcode->get_id);
	print "\t",$Barcode->get_id;
	}
print "\n";

#my @files = qw(/media/aod/DATA/data/samples/94484-01-02/raw/106S-57G-4-Kaliuta-Svetlana-Nikolaevna-cfDNA-131956.bam);
#my @files = qw(/media/aod/DATA/data/samples/29027-01-01/raw/CMB2_73-S_75-S-57G-Dokuchaeva-Nataliya-Anatolevna-cfDNA-112584.bam);
#my @files = qw(/media/aod/DATA/data/samples/57854-02-01/raw/99-S-57G-1-Kazak-Lyudmila-Ivanovna-cfDNA-125310.bam);
#my @files = qw(/media/aod/DATA/data/samples/31781-01-04/raw/103-S-57G-10-Antonov-Ivan-Ivanovich-cfDNA-129284.bam);

my $varList = $ARGV[0];
$varList = 'list' unless defined $varList;
open (READ, "<$varList");

while (<READ>) {
	chomp;
	my @mas = split/\t/;
	my $mut = $mas[0];
	print "$mut";
	#my $freq_ref = `perl ../ATLAS_software/aod-pipe/Pipe/popa/Scripts/HF_grep_var_count.pl $files[0] \$hg19 '$mut'`;
	#chomp $freq_ref;
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
		$freq = int($freq*100000)*100/100000;
		print "\t";
		print "$coverage:";
		print "$freq";
		}
	print "\n";
	}

close READ;













