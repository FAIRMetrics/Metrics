#!/usr/bin/perl -w
package Metrics::metric_has_linkset;

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


my %schemas = ('linkset_uri'  => ['string', "The URL that points to the VoID Linkset describing the connectivity of the resource"],
	       'subject' => ['string', "the GUID being tested"]);

my $helper = FAIRMetrics::TesterHelper->new(
				 title => "FAIR Metrics - Use Qualified References",
				 description => " Metric to test if the Resource uses qualified references",
				 tests_metric => 'https://purl.org/fair-metrics/FM_I3',
				 applies_to_principle => "I3",
				 organization => 'FAIR Metrics Authoring Group',
				 org_url => 'http://fairmetrics.org',
				 responsible_developer => "Mark D Wilkinson",
				 email => 'markw@illuminae.com',
				 developer_ORCiD => '0000-0001-6960-357X',
				 host => 'linkeddata.systems',
				 basePath => '/cgi-bin',
				 path => '/fair_metrics/Metrics/metric_has_linkset',
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
	my $check = $json->{'linkset_uri'};
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
	my $test = "http://rdfs.org/ns/void";
	if ($result && ($result =~ /$test/sg)) {
		$comment += "void namespace PASS\n";
		if ($result =~ /Linkset/) {  # is it a linkset?  (weak test for the word)
			$comment += "Linkset PASS\n";
			if ($result =~ /\:target/) {
				$comment += "void:target PASS\n";
				$score = 1;
			} else {
				$comment += "void:target FAIL\n";
			}
		} else {
			$comment += "Linkset FAIL - rdf:type Linkset doesn't exist\n";
		}
	} else {
		$comment += "void namespace FAIL - void namespace not defined; does not appear to be a Linkset document\n";
	}
			
	return $score, $comment;
}

1; #


