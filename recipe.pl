use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Aoddb;
use Atlas;
use Dir::Self;
use lib __DIR__ . '/../../lib';
use AtlasPipe;
use Data::Dumper;

my $DB = AODDB->fast_connect();

my %options;
$options{current_dir} = __DIR__;
$options{config}   = "$options{current_dir}/../../lib/Config.json";
$options{config}   = AtlasPipe::file_to_json($options{config});

if ((defined($ARGV[0]))and(defined($ARGV[1]))and(defined($ARGV[2]))) {
	$options{bam} = $ARGV[0];
	$options{panel_dir} = $options{current_dir}.'/../../panel_info/'.$ARGV[1];
	$options{panel_file} = "$options{panel_dir}/".$ARGV[1].".designed.bed";
	$options{folder} = $ARGV[2];
	} else {
	$options{barcodeName} = $ARGV[0];
	my $Barcode = $DB->Barcode($ARGV[0]);
	die "Unknown barcode" unless defined $Barcode->get_id;
	if (defined $ARGV[1]) {
		$options{folder} = $ARGV[1];
		} else {
		$options{folder} = $Barcode->get_folder;
		}
	$options{bam} = $Barcode->bam->path;
	$options{panel_dir} = $options{current_dir}.'/../../panel_info/'.$Barcode->info->{panelcode};
	$options{panel_file} = "$options{panel_dir}/".$Barcode->info->{panelcode}.".designed.bed";
	unless (-s $options{panel_file}) {
		$options{panel_file} = "$options{panel_dir}/".$Barcode->info->{panelcode}.".targets.bed";
		}
	unless (-s $options{panel_file}) {
		die "Cant find panel file\n";
		}
	}

print STDERR "Input parameters:\n";
print STDERR Dumper \%options;
exit;

Atlas::execute_cmd($options{config}->{software}->{samtools}." index $options{bam}");
Atlas::execute_cmd("mkdir -p $options{folder}/analysis");
Atlas::execute_cmd($options{config}->{software}->{samtools}." depth -a -d 0 -b $options{panel_file} $options{bam}  > $options{folder}/analysis/depth");
Atlas::execute_cmd("awk '{print \$3}' $options{folder}/analysis/depth > $options{folder}/analysis/depth.r");
Atlas::execute_cmd($options{config}->{software}->{R}." --slave -f $options{current_dir}/Scripts/getC.R --args $options{folder}/analysis/depth.r");
Atlas::execute_cmd("mkdir -p $options{folder}/analysis/sinvict/tumor");
Atlas::execute_cmd("mkdir -p $options{folder}/analysis/sinvict/result");
Atlas::execute_cmd($options{config}->{software}->{bam_readcount}." -f ".$options{config}->{data_path}->{genome}." $options{bam} -l $options{panel_file} -w 10 > $options{folder}/analysis/sinvict/tumor/readcount");
Atlas::execute_cmd($options{config}->{software}->{sinvict}." -t $options{folder}/analysis/sinvict/tumor -o $options{folder}/analysis/sinvict/result");
Atlas::execute_cmd("perl $options{current_dir}/Scripts/callsToVcf.pl $options{folder}/analysis/sinvict/result/calls_level1.sinvict > $options{folder}/analysis/sinvict/sinvict.vcf");
Atlas::execute_cmd("perl $options{current_dir}/Scripts/vcfToList.pl $options{folder}//analysis/sinvict/sinvict.vcf > $options{folder}/analysis/variant.list");
Atlas::execute_cmd("mkdir $options{folder}/analysis/strelka/");
Atlas::execute_cmd($options{config}->{software}->{strelka}." --bam $options{bam} --referenceFasta ".$options{config}->{data_path}->{genome}." --runDir $options{folder}/analysis/strelka/");
Atlas::execute_cmd("$options{folder}/analysis/strelka/runWorkflow.py -m local");
Atlas::execute_cmd("gunzip $options{folder}/analysis/strelka/results/variants/variants.vcf.gz");
Atlas::execute_cmd($options{config}->{software}->{bedtools}." intersect -a $options{folder}/analysis/strelka/results/variants/variants.vcf -b $options{panel_file} > $options{folder}/analysis/strelka/results/variants/variants.focus.vcf");
Atlas::execute_cmd("perl $options{current_dir}/Scripts/vcfToList.pl $options{folder}/analysis/strelka/results/variants/variants.focus.vcf >> $options{folder}/analysis/variant.list");
Atlas::execute_cmd("perl $options{current_dir}/Scripts/grepVAF.pl $options{folder}/analysis/variant.list $options{barcodeName} > $options{folder}/analysis/res.raw");
Atlas::execute_cmd("perl $options{current_dir}/Scripts/parse.grepVAF.pl $options{folder}/analysis/res.raw > $options{folder}/analysis/res.filter");




