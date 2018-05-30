#!/usr/bin/perl -w
use strict;
package Metrics::metric_accessible_license;

#use LWP::Simple;
use LWP::Simple qw/$ua get/;
use RDF::Trine;
use JSON::Parse 'parse_json';
use DateTime;
require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);
  
our $metricid = "metric_accessible_license";
our $metricprinciple = "R1.1";
our $metricURI = 'https://purl.org/fair-metrics/FM_R1.1'; 


sub execute_metric_test {
	my ($self, $body) = @_;

#print "Content-type: text/plain\n\n";
#print "in exercute $body\n";
#exit 1;

	my $json = parse_json($body);
print STDERR "\n\nJSON $json\n\n";
	my $check1 = $json->{'datalicense_uri'};
	my $check2 = $json->{'metadatalicense_uri'};
print STDERR "\n\nCHECK  $check1  $check2\n\n";

	my $IRI = $json->{'subject'};

        my ($valid, $comment) = check_metric($check1, $check2, $IRI);
        
	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);

	my $value = RDF::Trine::Node::Literal->new($valid);

	my $dt = DateTime->now(time_zone=>'local');
	my $dts = $dt->datetime();
#print STDERR "datetime $dts\n\n";
	$dts = RDF::Trine::Node::Literal->new( $dts,"", "xsd:dateTime");
#print STDERR "datetime $dts\n\n";
	my $time = time;


	my $statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/$metricid/result#$time", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://fairmetrics.org/resources/metric_evaluation_result" );
	$model->add_statement($statement);
	$statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/$metricid/result#$time", "http://semanticscience.org/resource/SIO_000300", $value );
	$model->add_statement($statement);
	$statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/$metricid/result#$time", "http://purl.obolibrary.org/obo/date", $dts );
	$model->add_statement($statement);
	$statement = statement($IRI,"http://semanticscience.org/resource/SIO_000629", "http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/$metricid/result#$time");
	$model->add_statement($statement);

	print "Content-type: application/json\n\n";
	print ser($model);
	exit 1;
}

sub check_metric {
	my ($check1, $check2, $subject) = @_;

	$ua->agent('Mozilla/5.0');  # needed by creative commons
	my ($result1, $result2) = ("","");
	$result1 = get($check1) if $check1;
	$result2 = get($check2) if $check2;

	
	my $score = 0;
	$score += .5 if $result1;
	$score += .5 if $result2;

	return $score;
}

sub ser {
    my ($m) = @_;
    use RDF::Trine::Serializer::RDFJSON;
    my $serializer = RDF::Trine::Serializer::RDFJSON->new( );
#    print $serializer->serialize_model_to_string($m);
    
    return $serializer->serialize_model_to_string($m);
    
}
 # to dump out the entire model as RDF



sub statement {
	my ($s, $p, $o) = @_;
#print STDERR "$s -- $p -- $o\n\n";
	unless (ref($s) =~ /Trine/){
		$s =~ s/[\<\>]//g;
		$s = RDF::Trine::Node::Resource->new($s);
	}
	unless (ref($p) =~ /Trine/){
		$p =~ s/[\<\>]//g;
		$p = RDF::Trine::Node::Resource->new($p);
	}
	unless (ref($o) =~ /Trine/){
		if (($o =~ m'^http://') || ($o =~ m'^https://')){
			$o =~ s/[\<\>]//g;
			$o = RDF::Trine::Node::Resource->new($o);
		} elsif ($o =~ /\D/) {
			$o = RDF::Trine::Node::Literal->new($o);
		} else {
			$o = RDF::Trine::Node::Literal->new($o);				
		}
	}
	my $statement = RDF::Trine::Statement->new($s, $p, $o);
	return $statement;
}

use CGI;
my $cgi = CGI->new();
if (!$cgi->request_method() || $cgi->request_method() eq "GET") {

  print "Content-type: application/openapi+yaml;version=3.0\n\n";


  print <<EOF
swagger: '2.0'
info:
  version: '0.1'
  title: FAIR Metrics - Accessible Usage License
  tests_metric: '$metricURI'
  description: >-
    Metric to test if the Resource has a usage license for its data and metadata
  applies_to_principle: $metricprinciple
  contact:
    responsibleOrganization: FAIR Data Systems
    url: 'http://fairdata.systems'
    responsibleDeveloper: Mark D Wilkinson
    email: markw\@illuminae.com
host: linkeddata.systems
basePath: /cgi-bin
schemes:
  - http
produces:  
- application/json
consumes:
  - application/json
paths:
  /fair_metrics/Metrics/$metricid:
    post:
      parameters:
        - name: content
          in: body
          required: true
          schema:
            \$ref: '#/definitions/schemas'
      responses:
        '200':
          description: >-
            The response is 0, .5, or 1 depending on zero, one, or both licenses being available
definitions:
  schemas:
      required:
        - datalicense_uri
        - metadatalicense_uri
        - subject
      properties:
        datalicense_uri:
          type: string
          description: >-
            The URL that points to the usage license pertaining to the data (or leave blank)
        metadatalicense_uri:
          type: string
          description: >-
            The URL that points to the usage license pertaining to the metadata (or leave blank)
        subject:
          type: string
          description: >-
            The IRI that is being evaluated
    
EOF


  } else {
	return 1;   # THis is the end of the module returning positive!
  }
  


1; #


