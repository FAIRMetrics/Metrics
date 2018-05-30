#!/usr/bin/perl -w
use strict;
package Metrics::metric_fair_vocabularies;

use LWP::Simple;
use RDF::Trine;
use JSON::Parse 'parse_json';
use DateTime;
require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);
  
our $metricid = "metric_fair_vocabularies";
our $metricprinciple = "I2";
our $metricURI = 'https://purl.org/fair-metrics/FM_I2'; 


sub execute_metric_test {
	my ($self, $body) = @_;

#print "Content-type: text/plain\n\n";
#print "in exercute $body\n";
#exit 1;

	my $json = parse_json($body);
	my $check1 = $json->{'vocab1_uri'};
	my $check2 = $json->{'vocab2_uri'};
	my $check3 = $json->{'vocab3_uri'};
	my $IRI = $json->{'subject'};

        my $valid = check_metric($check1, $check2, $check3, $IRI);
        
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
	my ($check1, $check2, $check3, $subject) = @_;
	my $result1 = get($check1) if $check1;
	my $result2 = get($check2) if $check2;
	my $result3 = get($check3) if $check3;
	
	my $test = 'rdf-syntax';
	my $score = 0;
	$score += .33 if $result1 && $result1 =~ /$test/sg;
	$score += .33 if $result2 && $result2 =~ /$test/sg;
	$score += .33 if $result3 && $result3 =~ /$test/sg;
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
  title: FAIR Metrics - Use FAIR Vocabularies
  tests_metric: '$metricURI'
  description: >-
    Metric to test if the Resource uses FAIR Vocabularies
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
            The response is 0, .33, .66, .99 depending on how many vocabularies are entered that also return parsable
definitions:
  schemas:
      required:
        - vocab1_uri
        - vocab2_uri
        - vocab3_uri
        - subject
      properties:
        vocab1_uri:
          type: string
          description: >-
            The URL that points to the first FAIR Vocabulary used in the Resource (or leave blank if not applicable)
        vocab2_uri:
          type: string
          description: >-
            The URL that points to the second FAIR Vocabulary used in the Resource (or leave blank if not applicable)
        vocab3_uri:
          type: string
          description: >-
            The URL that points to the third FAIR Vocabulary used in the Resource (or leave blank if not applicable)
        subject:
          type: string
          description: >-
            The IRI that is being evaluated
    
EOF


  } else {
	return 1;   # THis is the end of the module returning positive!
  }
  


1; #


