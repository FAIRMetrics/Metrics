#!/usr/bin/perl -w
package Metrics::metric_accessible_license;

use strict;
use LWP::Simple qw/$ua get/;
use JSON::Parse 'parse_json';
use CGI;
use lib '../';
use FAIRMetrics::TesterHelper;

require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);


my %schemas = ('datalicense_uri'  => ['string', "The URL that points to the usage license pertaining to the data (or leave blank)"],
	       'metadatalicense_uri'  => ['string', "The URL that points to the usage license pertaining to the metadata (or leave blank)"],
	       'subject' => ['string', "the GUID being tested"]);

my $helper = FAIRMetrics::TesterHelper->new(
				 title => "FAIR Metrics - Accessible Usage License",
				 description => "Metric to test if the Resource has a usage license for its data and metadata",
				 tests_metric => 'https://purl.org/fair-metrics/FM_R1.1',
				 applies_to_principle => "R1.1",
				 organization => 'FAIR Metrics Authoring Group',
				 org_url => 'http://fairmetrics.org',
				 responsible_developer => "Mark D Wilkinson",
				 email => 'markw@illuminae.com',
				 developer_ORCiD => '0000-0001-6960-357X',
				 host => 'linkeddata.systems',
				 basePath => '/cgi-bin',
				 path => '/fair_metrics/Metrics/metric_accessible_license',
				 response_description => 'The response is 0, 0.5 or 1 depending on how many licenses were successfully resolved',
				 schemas => \%schemas,
				 fairsharing_key_location => '../fairsharing.key'
				);

my $cgi = CGI->new();
if (!$cgi->request_method() || $cgi->request_method() eq "GET") {
        print "Content-type: application/openapi+yaml;version=3.0\n\n";
        print $helper->getSwagger();
	
} else {
	return 1;  # this is returning 1 for the "require" statement in fair_metrics!!!!
}


sub execute_metric_test {

	my ($self, $body) = @_;

	my $json = parse_json($body);
	my $check1 = $json->{'datalicense_uri'};
	my $check2 = $json->{'metadatalicense_uri'};

	my $IRI = $json->{'subject'};

        my ($value, $comment) = check_metric($check1, $check2, $IRI);

	my $response = $helper->createEvaluationResponse($IRI, $value);
	print "Content-type: application/json\n\n";
	print $response;
	exit 1;
}

sub check_metric {
	my ($check1, $check2, $subject) = @_;

	$ua->agent('Mozilla/5.0');  # needed by creative commons
	my ($result1, $result2, $comment) = ("","","");

	$result1 = get($check1) if $check1;
	$comment .="  Failed to locate data license at $check1.  " unless $result1;
	$result2 = get($check2) if $check2;
	$comment .="  Failed to locate metadata license at $check2.  " unless $result2;
	my $score = 0;
	$score += .5 if $result1;
	$score += .5 if $result2;
	$comment = "All OK" if $score == 1;
	return ($score, $comment);
}

1; #


