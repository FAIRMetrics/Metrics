#!/usr/bin/perl -w
package Metrics::metric_detailed_provenance_A;

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


my %schemas = ('prov_vocab_uri'  => ['string', "The URL that points to the VoID Linkset describing the connectivity of the resource"],
	       'subject' => ['string', "the GUID being tested"]);

my $helper = FAIRMetrics::TesterHelper->new(
				 title => "FAIR Metrics - Detailed Provenance (part A)",
				 description => "Metric to test if the Resource uses a recognized provenance vocabulary",
				 tests_metric => 'https://purl.org/fair-metrics/FM_R1.2',
				 applies_to_principle => "R1.2",
				 organization => 'FAIR Metrics Authoring Group',
				 org_url => 'http://fairmetrics.org',
				 responsible_developer => "Mark D Wilkinson",
				 email => 'markw@illuminae.com',
				 developer_ORCiD => '0000-0001-6960-357X',
				 host => 'linkeddata.systems',
				 basePath => '/cgi-bin',
				 path => '/fair_metrics/Metrics/metric_detailed_provenance_A',
				 response_description => 'The response is a binary (1/0), success or failure',
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
	my $check = $json->{'prov_vocab_uri'};
	my $IRI = $json->{'subject'};

        my ($valid, $comment) = check_metric($check,$IRI);
	my $value;
	
        if($valid) {
                $value = "1";
                $helper->addComment("All OK!");
        } else {
                $value = "0";
                $helper->addComment($comment);
        }

	my $response = $helper->createEvaluationResponse($IRI, $value);
	print "Content-type: application/json\n\n";
	print $response;
	exit 1;
}

sub check_metric {
	my ($check, $subject) = @_;
	my $result = get($check) if $check;
	my $score = 0;
	my $comment = "";
	$comment = "no document returned" unless $score;
	$score = 1 if ($result);
	return $score, $comment;
}

1; #


