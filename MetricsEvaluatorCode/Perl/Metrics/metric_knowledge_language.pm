#!/usr/bin/perl -w
package Metrics::metric_knowledge_language;

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


my %schemas = ('bnf_uri'  => ['string', "The URL that points to the BNF for the knowledge representation language used by the Resource"],
	       'subject' => ['string', "the GUID being tested"]);

my $helper = FAIRMetrics::TesterHelper->new(
				 title => "FAIR Metrics - Use a knowledge representation language",
				 description => "Metric to test if the site uses a formal knowledge representation language (i.e. that a BNF exists for the language used by the Resource)",
				 tests_metric => 'https://purl.org/fair-metrics/FM_I1',
				 applies_to_principle => "I1",
				 organization => 'FAIR Metrics Authoring Group',
				 org_url => 'http://fairmetrics.org',
				 responsible_developer => "Mark D Wilkinson",
				 email => 'markw@illuminae.com',
				 developer_ORCiD => '0000-0001-6960-357X',
				 host => 'linkeddata.systems',
				 basePath => '/cgi-bin',
				 path => '/fair_metrics/Metrics/metric_knowledge_language',
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
	my $check = $json->{'bnf_uri'};
	my $IRI = $json->{'subject'};

        my $valid = check_metric($check, $IRI);

	my $value;
	
        if($valid) {
                $value = "1";
                $helper->addComment("All OK!");
        } else {
                $value = "0";
                $helper->addComment("The document at $check does not appear to be a BNF definition");
        }

	my $response = $helper->createEvaluationResponse($IRI, $value);
	print "Content-type: application/json\n\n";
	print $response;
	exit 1;
}

sub check_metric {
	my ($check, $subject) = @_;
	my $result = get($check);
	return 1 if $result =~ /\S+\s*\:\:\=\s*\S+/sg;
	return 0;
}


1; #


