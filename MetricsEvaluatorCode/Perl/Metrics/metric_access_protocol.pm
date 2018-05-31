#!/usr/bin/perl -w
package Metrics::metric_access_protocol;

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


my %schemas = ('protocol_uri'  => ['string', "The URL that points to the VoID Linkset describing the connectivity of the resource"],
	       'subject' => ['string', "the GUID being tested"]);

my $helper = FAIRMetrics::TesterHelper->new(
				 title => "FAIR Metrics - Access Protocol",
				 description => "Metric to test if the access protocol is open, free, and universally implementable",
				 tests_metric => 'https://purl.org/fair-metrics/FM_A1.1',
				 applies_to_principle => "A1.1",
				 organization => 'FAIR Metrics Authoring Group',
				 org_url => 'http://fairmetrics.org',
				 responsible_developer => "Mark D Wilkinson",
				 email => 'markw@illuminae.com',
				 developer_ORCiD => '0000-0001-6960-357X',
				 host => 'linkeddata.systems',
				 basePath => '/cgi-bin',
				 path => '/fair_metrics/Metrics/metric_access_protocol',
				 response_description => 'The response is a binary (1/0), success or failure',
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
	my $check = $json->{'protocol_uri'};
	my $IRI = $json->{'subject'};

        my $valid = check_metric($check, $IRI);

	my $value;
	
        if($valid) {
                $value = "1";
                $helper->addComment("All OK!");
        } else {
                $value = "0";
                $helper->addComment("The URI $check did not return a valid response");
        }

	my $response = $helper->createEvaluationResponse($IRI, $value);
	print "Content-type: application/json\n\n";
	print $response;
	exit 1;
}

sub check_metric {
	my ($check, $subject) = @_;
	my $result = get($check);
	return 1 if $result;
	return 0;
}


1; #


