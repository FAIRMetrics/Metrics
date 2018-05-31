#!/usr/bin/perl -w
package Metrics::metric_machine_readable_metadata;

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


my %schemas = ('metadata'  => ['string', "The URL to the metadata document being tested.  (in the case where the primary IRI being tested represents a metadata document, please use that IRI here)"],
	       'format'  => ['string', "The URI of a registered file format in FAIRSharing (for example, https://fairsharing.org/FAIRsharing.tn873z if your data follows the INSD Sequence XML format)"],
	       'subject' => ['string', "the GUID being tested"]);

my $helper = FAIRMetrics::TesterHelper->new(
				 title => "FAIR Metrics - Metric Machine Readable Metadata",
				 description => "Metric to test if the resource has (or is) metadata in machine readable format.  This metric should be applied to the Metadata, if a data record is being tested, or to the record itself if a metadata record is being tested.",
				 tests_metric => 'https://purl.org/fair-metrics/FM_F2',
				 applies_to_principle => "F2",
				 organization => 'FAIR Metrics Authoring Group',
				 org_url => 'http://fairmetrics.org',
				 responsible_developer => "Mark D Wilkinson",
				 email => 'markw@illuminae.com',
				 developer_ORCiD => '0000-0001-6960-357X',
				 host => 'linkeddata.systems',
				 basePath => '/cgi-bin',
				 path => '/fair_metrics/Metrics/metric_machine_readable_metadata',
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
	my $meta = $json->{'metadata'};
	my $format = $json->{'format'};
	my $IRI = $json->{'subject'};

        my $valid = check_document($meta) && check_format($format);

	my $value;
	
        if($valid) {
                $value = "1";
                $helper->addComment("All OK!");
        } else {
                $value = "0";
                $helper->addComment("Document not found, or was not considered to be machine-readable");
        }

	my $response = $helper->createEvaluationResponse($IRI, $value);

	print "Content-type: application/json\n\n";
	print $response;
	exit 1;
}

sub check_document {
        my ($check) = @_;
        my $result = get($check);
        return 1 if $result;
        return 0;

}


sub check_format {
    # this will one day lookup at fairsharing.org
    return 1;
}



1; #


