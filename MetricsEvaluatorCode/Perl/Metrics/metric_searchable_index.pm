#!/usr/bin/perl -w
use strict;
package Metrics::metric_searchable_index;

use LWP::Simple;
use RDF::Trine;
use JSON::Parse 'parse_json';
use DateTime;
use CGI;
use lib '../';
use FAIRMetrics::TesterHelper;

require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);


my %schemas = ('search_uri'  => ['string', "The URL, including GET string parameters, that will return a successful search for the subject resource"],
	       'subject' => ['string', "the GUID being tested"]);

my $helper = FAIRMetrics::TesterHelper->new(
				 title => "FAIR Metrics - Indexed in a Searchable Location",
				 description => "Metric to test if the GUID can be discovered through a search of some registry or index.",
				 tests_metric => 'https://purl.org/fair-metrics/FM_F4',
				 applies_to_principle => "F4",
				 organization => 'FAIR Metrics Authoring Group',
				 org_url => 'http://fairmetrics.org',
				 responsible_developer => "Mark D Wilkinson",
				 email => 'markw@illuminae.com',
				 developer_ORCiD => '0000-0001-6960-357X',
				 host => 'linkeddata.systems',
				 basePath => '/cgi-bin',
				 path => '/fair_metrics/Metrics/metric_searchable_index',
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
	my $check = $json->{'search_uri'};
	my $IRI = $json->{'subject'};

        my $valid = check_metric($check, $IRI);
        
        my $value;
        if( $valid) {
                $value = "1";
                $helper->addComment("All OK!");
        } else {
                $value = "0";
                $helper->addComment("Failed to find the UUID in the output from  '$check'");
        }

	my $response = $helper->createEvaluationResponse($IRI, $value);

	print "Content-type: application/json\n\n";
	print $response;
	exit 1;

}

sub check_metric {
	my ($check, $subject) = @_;
	my $result = get($check);
	require URI::Encode;
	my $uriencode = URI::Encode->new();
	my $encoded = $uriencode->encode($subject);
	return 1 if $result =~ /$subject/;
	return 1 if $result =~ /$encoded/;
	return 0;
}



1;

