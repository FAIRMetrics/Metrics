#!/usr/local/bin/perl -w
use strict;
package Metrics::metric_unique_identifier;

use RDF::Trine;
use JSON::Parse 'parse_json';
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
	my $check = $json->{'spec'};

        my $valid = get_valid_schemas();
        
	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);

	my $value;
	if( grep { $check eq $_ }  @$valid) {
    		$value = RDF::Trine::Node::Literal->new("1");
	} else {
	    	$value = RDF::Trine::Node::Literal->new("0");    
	}

	my $time = time;
	my $statement = statement("http://fairdata.metrics/result#$time", "http://fairdata.metrics/result#result", $value );
	$model->add_statement($statement);

	print "Content-type: text/turtle\n\n";
	print ser($model);
	exit 1;
}

sub get_valid_schemas {
    # this will one day lookup at fairsharing.org
    
 return [
"https://sourceforge.net/p/identifiers-org",
"http://www.obofoundry.org",
"http://bioportal.bioontology.org",
"http://lov.okfn.org",
"https://github.com/geneontology/go-site",
"http://prefix.cc",
"https://scicrunch.org/resources",
"http://datahub.io",
"https://www.biosharing.org/",
"http://tinyurl.com/lsregistry",
"http://eelst.cs.unibo.it/apps/LODE/source?url=http://purl.org/spar/datacite",
"http://biocol.org",
"http://dx.doi.org",
"http://doi.org",
"http://handle.org",
"http://www.ebi.ac.uk/miriam",
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

  print "Content-type: application/json\n\n";


  print <<'EOF'
swagger: '2.0'
info:
  version: '0.1'
  title: FAIR Metrics -Identifier Uniqueness
  description: >-
    Metric to test if the resource uses a recognized identifier scheme (e.g.
    doi, identifiers.org, etc.).  It consumes a URI as the value of the "spec"
    parameter.  This URI should be a registered identifier schema at
    fairsharing.org.
  contact:
    responsibleOrganization: CBGP UPM/INIA
    url: 'http://faidata.systems'
    responsibleDeveloper: Mark D Wilkinson
    email: markw@illuminae.com
host: fairdata.systems
basePath: /cgi-bin
schemes:
  - http
produces:
  - application/json
consumes:
  - application/json
paths:
  /fair_metrics/Metrics/metric_unique_identifier:
    post:
      parameters:
        - name: spec
          in: body
          description: >-
            The identifier schema specification you claim to follow, referenced
            by its URI (must be registered in FAIRsharing)
          required: true
          parameterType: InputParameter
          schema:
            $ref: '#/definitions/Spec'
      responses:
        '200':
          description: >-
            The response is a binary (1/0) indicating whether the schema you
            claim to follow is registered in the FAIRsharing repository
definitions:
  Spec:
    properties:
      spec:
        type: string
    type: object
  
  
EOF


  } else {
	return 1;   # THis is the end of the module returning positive!
  }
  


1; #


