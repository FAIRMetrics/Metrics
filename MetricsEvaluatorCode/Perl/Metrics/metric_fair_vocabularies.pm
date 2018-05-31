#!/usr/bin/perl -w
package Metrics::metric_fair_vocabularies;

use strict;
use LWP::Simple;
use JSON::Parse 'parse_json';
use CGI;
use lib '../';
use FAIRMetrics::TesterHelper;

require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);


my %schemas = ('vocab1_uri'  => ['string', "The URL that points to the first FAIR Vocabulary used in the Resource (or leave blank if not applicable)"],
	       'vocab2_uri'  => ['string', "The URL that points to the second FAIR Vocabulary used in the Resource (or leave blank if not applicable)"],
	       'vocab3_uri'  => ['string', "The URL that points to the third FAIR Vocabulary used in the Resource (or leave blank if not applicable)"],
	       'subject' => ['string', "the GUID being tested"]);

my $helper = FAIRMetrics::TesterHelper->new(
				 title => "FAIR Metrics - Use FAIR Vocabularies",
				 description => "Metric to test if the Resource uses FAIR Vocabularies",
				 tests_metric => 'https://purl.org/fair-metrics/FM_I2',
				 applies_to_principle => "I2",
				 organization => 'FAIR Metrics Authoring Group',
				 org_url => 'http://fairmetrics.org',
				 responsible_developer => "Mark D Wilkinson",
				 email => 'markw@illuminae.com',
				 developer_ORCiD => '0000-0001-6960-357X',
				 host => 'linkeddata.systems',
				 basePath => '/cgi-bin',
				 path => '/fair_metrics/Metrics/metric_has_linkset',
				 response_description => 'The response is 0, .33, .66, .99 depending on how many vocabularies are entered that also return parsable',
				 schemas => \%schemas,
				 fairsharing_key_location => '../fairsharing.key'
				);

my $cgi = CGI->new();
if (!$cgi->request_method() || $cgi->request_method() eq "GET") {
        print "Content-type: application/openapi+yaml;version=3.0\n\n";
        print $helper->getSwagger();
	
}


sub execute_metric_test {


	my ($self, $body) = @_;

	my $json = parse_json($body);
	my $check1 = $json->{'vocab1_uri'};
	my $check2 = $json->{'vocab2_uri'};
	my $check3 = $json->{'vocab3_uri'};
	my $IRI = $json->{'subject'};

        my $value = check_metric($check1, $check2, $check3, $IRI);


        if ($value == .99){
		$helper->addComment("Three vocabularies confirmed...");
	}
	elsif ($value < .7 && $value > .4){
		$helper->addComment("Two vocabularies confirmed...");
        }
	elsif ($value > 0 && $value < .4) {
		$helper->addComment("One vocabulary confirmed...");
        }
	else {
		$helper->addComment("No vocabularies confirmed...");
        }

	my $response = $helper->createEvaluationResponse($IRI, $value);
	print "Content-type: application/json\n\n";
	print $response;
	exit 1;

}

sub check_metric {
	my ($check1, $check2, $check3, $subject) = @_;
	my $result1 = get($check1) if $check1;
	my $result2 = get($check2) if $check2;
	my $result3 = get($check3) if $check3;
	
	my $test = 'rdf-syntax';
	my $score = 0;
	$score += .33 if $result1 && $result1 =~ /$test/sg;
	$score += .33 if $result2 && $result2 =~ /$test/sg;
	$score += .33 if $result3 && $result3 =~ /$test/sg;
	return $score;
}



1; #


