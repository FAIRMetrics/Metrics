#!/usr/bin/perl -w
package Metrics::metric_identifier_in_metadata;

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


my %schemas = ('metadata'  => ['string', "The URL to the metadata document being tested.  (in the case where the primary IRI being tested represents a metadata document, please use that same IRI here)"],
	       'identifier'  => ['string', "The GUID of the identifier that should explicitly appear in that metadata record."],
	       'subject' => ['string', "the GUID being tested"]);

my $helper = FAIRMetrics::TesterHelper->new(
				 title => "FAIR Metrics - Metric Identifier in Metadata",
				 description => "Metric to test if the metadata for a resource explicitly contains the identifier of the resource.  When the primary subject of this evaluation is a metadata record, please repeat its IRI here.  If the primary subject of evaluation is a data record, please enter the metadata IRI",
				 tests_metric => 'https://purl.org/fair-metrics/FM_F3',
				 applies_to_principle => "F3",
				 organization => 'FAIR Metrics Authoring Group',
				 org_url => 'http://fairmetrics.org',
				 responsible_developer => "Mark D Wilkinson",
				 email => 'markw@illuminae.com',
				 developer_ORCiD => '0000-0001-6960-357X',
				 host => 'linkeddata.systems',
				 basePath => '/cgi-bin',
				 path => '/fair_metrics/Metrics/metric_identifier_in_metadata',
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
	my $meta = $json->{'metadata'};
	my $identifier = $json->{'identifier'};
	my $IRI = $json->{'subject'};

        my $valid = check_document($meta) && check_identifier($meta, $identifier);

	my $value;
	
        if($valid) {
                $value = "1";
                $helper->addComment("All OK!");
        } else {
                $value = "0";
                $helper->addComment("There was no identifier $identifier in document at $meta");
        }

	my $response = $helper->createEvaluationResponse($IRI, $value);
	print "Content-type: application/json\n\n";
	print $response;
	exit 1;
	
}

sub check_identifier {
	my ($meta, $id) = @_;
        my $result = get($meta);

	require URI::Encode;
	my $uriencode = URI::Encode->new();
	my $encoded = $uriencode->encode($id);
	return 1 if $result =~ /$id/;
	return 1 if $result =~ /$encoded/;
	return 0;
}

sub check_document {
        my ($check) = @_;
        my $result = get($check);
        return 1 if $result;
        return 0;

}

1; #


