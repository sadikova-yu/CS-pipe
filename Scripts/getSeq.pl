use strict;
use warnings;
use XML::Simple;
use LWP::UserAgent;
use Data::Dumper;
use String::Util qw(trim);

my $ua = new LWP::UserAgent;


sub getSeq {
	my $build = shift;
	my $chr = shift;
	my $pos1 = shift;
	my $pos2 = shift;
	my $try = 0;
	FETCH:
#	print "http://genome.ucsc.edu/cgi-bin/das/$build/dna?segment=$chr:$pos1,$pos2\n";
	my $response = $ua->get("http://genome.ucsc.edu/cgi-bin/das/$build/dna?segment=$chr:$pos1,$pos2");
	unless ($response && $response->is_success) {
		++$try;
		print STDERR "try number $try\n";
		goto FETCH;
		}
	my $xmlString = $response->content;
	my @options = ();
	my $ref = XMLin($xmlString, @options);
	my $return = trim((((($ref)->{"SEQUENCE"})->{"DNA"})->{"content"}));
	$return =~ s/\n//g;
	return uc($return);
	}

print "",getSeq($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3]);













