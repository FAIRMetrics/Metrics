#!/usr/bin/perl -w
use strict;
package Metrics::metric_has_linkset;

use LWP::Simple;
use RDF::Trine;
use JSON::Parse 'parse_json';
use DateTime;
require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);
  
our $metricid = "metric_has_linkset";
our $metricprinciple = "I3";
our $metricURI = 'https://purl.org/fair-metrics/FM_I3'; 


sub execute_metric_test {
	my ($self, $body) = @_;

#print "Content-type: text/plain\n\n";
#print "in exercute $body\n";
#exit 1;

	my $json = parse_json($body);
	my $check = $json->{'linkset_uri'};
	my $IRI = $json->{'subject'};

        my ($valid, $comment) = check_metric($check,$IRI);
        
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

	if ($comment) {
		my $statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/$metricid/result#$time", "http://www.w3.org/2000/01/rdf-schema#comment", $comment );
		$model->add_statement($statement);
	}

	print "Content-type: application/json\n\n";
	print ser($model);
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
  title: FAIR Metrics - Use Qualified References
  tests_metric: '$metricURI'
  description: >-
    Metric to test if the Resource uses qualified references
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
            The response is 0 or 1 depending on whether a Linkset is found
definitions:
  schemas:
      required:
        - linkset_uri
        - subject
      properties:
        linkset_uri:
          type: string
          description: >-
            The URL that points to the VoID Linkset describing the connectivity of the resource
        subject:
          type: string
          description: >-
            The IRI that is being evaluated
    
EOF


  } else {
	return 1;   # THis is the end of the module returning positive!
  }
  


1; #


