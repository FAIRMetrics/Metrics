#!/usr/bin/perl -w
use strict;
package Metrics::metric_machine_readable_metadata;

use LWP::Simple;
use RDF::Trine;
use JSON::Parse 'parse_json';
use DateTime;
require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);
  
my $metric = "metric_machine_readable_metadata";
  
sub execute_metric_test {
	my ($self, $body) = @_;

#print "Content-type: text/plain\n\n";
#print "in exercute $body\n";
#exit 1;

	my $json = parse_json($body);
	my $meta = $json->{'metadata'};
	my $format = $json->{'format'};
	my $IRI = $json->{'subject'};

        my $value = check_document($meta) && check_format($format);
        
	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);


	my $dt = DateTime->now(time_zone=>'local');
	my $dts = $dt->datetime();
#print STDERR "datetime $dts\n\n";
	$dts = RDF::Trine::Node::Literal->new( $dts,"", "xsd:dateTime");
#print STDERR "datetime $dts\n\n";
	my $time = time;


	my $statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/$metric/result#$time", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://fairmetrics.org/resources/metric_evaluation_result" );
	$model->add_statement($statement);
	$statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/$metric/result#$time", "http://semanticscience.org/resource/SIO_000300", $value );
	$model->add_statement($statement);
	$statement = statement("http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/$metric/result#$time", "http://purl.obolibrary.org/obo/date", $dts );
	$model->add_statement($statement);
	$statement = statement($IRI,"http://semanticscience.org/resource/SIO_000629", "http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/$metric/result#$time");
	$model->add_statement($statement);

	print "Content-type: application/json\n\n";
	print ser($model);
	exit 1;
}

sub check_document {
        my ($check) = @_;
        my $result = get($check);
#print STDERR "MARK:  Result is $result";
        return 1 if $result;
        return 0;

}


sub check_format {
    # this will one day lookup at fairsharing.org
    return 1;
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
  title: FAIR Metrics - Metric Machine Readable Metadata
  tests_metric: 'https://purl.org/fair-metrics/FM_F2'
  description: >-
    Metric to test if the resource has (or is) metadata in machine readable format.  This metric should be applied to the Metadata, if a data record is being tested, or 
    to the record itself if a metadata record is being tested
  applies_to_principle: F2
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
  /fair_metrics/Metrics/metric_machine_readable_metadata:
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
            The response is a binary (1/0) indicating whether the schema you
            claim to follow is registered in the FAIRsharing repository
definitions:
  schemas:
      required:
        - metadata
        - format
        - subject
      properties:
        metadata:
          type: string
          description: >-
              The URL to the metadata document being tested.  (in the case where the primary IRI being tested represents a metadata document, please use that IRI here)
        format:
          type: string
          description: >-
              The URI of a registered file format in FAIRSharing (for example, https://fairsharing.org/FAIRsharing.tn873z if your data follows the INSD Sequence XML format)
        subject:
          type: string
          description: >-
              The URL being tested against this Metric
    
EOF


  } else {
	return 1;   # THis is the end of the module returning positive!
  }
  


1; #


