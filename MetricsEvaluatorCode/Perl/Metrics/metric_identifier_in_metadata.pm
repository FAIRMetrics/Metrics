#!/usr/bin/perl -w
use strict;
package Metrics::metric_identifier_in_metadata;

use LWP::Simple;
use RDF::Trine;
use JSON::Parse 'parse_json';
use DateTime;
require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);
  
  
sub execute_metric_test {
	my ($self, $body) = @_;

#print "Content-type: text/plain\n\n";
#print "in exercute $body\n";
#exit 1;

	my $json = parse_json($body);
	my $meta = $json->{'metadata'};
	my $identifier = $json->{'identifier'};
	my $IRI = $json->{'subject'};

#        my $value = check_document($IRI) && check_identifier($IRI, $identifier);
        my $value = check_document($meta) && check_identifier($meta, $identifier);
        
	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);


	my $dt = DateTime->now(time_zone=>'local');
	my $dts = $dt->datetime();
#print STDERR "datetime $dts\n\n";
	$dts = RDF::Trine::Node::Literal->new( $dts,"", "xsd:dateTime");
#print STDERR "datetime $dts\n\n";
	my $time = time;


	my $statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#$time", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://fairmetrics.org/resources/metric_evaluation_result" );
	$model->add_statement($statement);
	$statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#$time", "http://semanticscience.org/resource/SIO_000300", $value );
	$model->add_statement($statement);
	$statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#$time", "http://purl.obolibrary.org/obo/date", $dts );
	$model->add_statement($statement);
	$statement = statement($IRI,"http://semanticscience.org/resource/SIO_000629", "http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#$time");
	$model->add_statement($statement);

	print "Content-type: application/json\n\n";
	print ser($model);
	exit 1;
}

sub check_identifier {
	my ($meta, $id) = @_;
        my $result = get($meta);
	if( $result =~ /$id/) {
    		return RDF::Trine::Node::Literal->new("1");
	} else {
	    	return RDF::Trine::Node::Literal->new("0");    
	}
}

sub check_document {
        my ($check) = @_;
        my $result = get($check);
        return 1 if $result;
        return 0;

}


sub get_valid_schemas {
    # this will one day lookup at fairsharing.org
    
 return [
"https://www.w3.org/TR/vocab-dcat/",

];
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


  print <<'EOF'
swagger: '2.0'
info:
  version: '0.1'
  title: FAIR Metrics - Metric Identifier in Metadata
  tests_metric: 'https://purl.org/fair-metrics/FM_F3'
  description: >-
    Metric to test if the metadata for a resource explicitly contains the identifier of the resource.  
    When the primary subject of this evaluation is a metadata record, please repeat its IRI here.  If the primary subject of evaluation is a data record, please enter the metadata IRI
  applies_to_principle: F3
  contact:
    responsibleOrganization: CBGP UPM/INIA
    url: 'http://fairdata.systems'
    responsibleDeveloper: Mark D Wilkinson
    email: markw@illuminae.com
host: linkeddata.systems
basePath: /cgi-bin
schemes:
  - http
produces:  
- application/json
consumes:
  - application/json
paths:
  /fair_metrics/Metrics/metric_identifier_in_metadata:
    post:
      parameters:
        - name: content
          in: body
          required: true
          schema:
            $ref: '#/definitions/schemas'
      responses:
        '200':
          description: >-
            The response is a binary (1/0), success or failure
definitions:
  schemas:
      required:
        - metadata
        - identifier
        - subject
      properties:
        metadata:
          type: string
          description: >-
              The URL to the metadata document being tested.  (in the case where the primary IRI being tested represents a metadata document, please use that same IRI here)
        identifier:
          type: string
          description: >-
              The IRI of the identifier that should explicitly appear in that metadata record.
        subject:
          type: string
          description: >-
              The IRI being tested against this Metric
    
EOF


  } else {
	return 1;   # THis is the end of the module returning positive!
  }
  


1; #


