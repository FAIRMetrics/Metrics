#!/usr/bin/perl -w
use strict;
package Metrics::metric_unique_identifier;

use LWP::Simple;
use RDF::Trine;
use JSON::Parse 'parse_json';
use DateTime;
require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);
  
my $metric = "metric_unique_identifier";
  
sub execute_metric_test {
	my ($self, $body) = @_;

#print "Content-type: text/plain\n\n";
#print "in exercute $body\n";
#exit 1;

	my $json = parse_json($body);
	my $check = $json->{'spec'};
	my $IRI = $json->{'subject'};

        my $valid = get_valid_schemas();
print STDERR "valid @$valid\n\n";
	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);

	my $value;
	if( grep { $check eq $_ }  @$valid) {
    		$value = RDF::Trine::Node::Literal->new("1");
	} else {
	    	$value = RDF::Trine::Node::Literal->new("0");    
	}

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


sub get_valid_schemas {
    # this will one day lookup at fairsharing.org
# curl -X GET --header 'Accept: application/json' --header 'Api-Key: cb892c4261a01b6842c4787ae6cba21a826b0bce' 
#'https://fairsharing.org/api/standard/summary/?type=identifier%20schema'    

	use LWP::UserAgent;
	my $browser = LWP::UserAgent->new;
	my $url = 'https://fairsharing.org/api/standard/summary/?type=identifier%20schema';	
	my @ns_headers = (
  		'User-Agent' => 'Mozilla/4.76 [en] (Win98; U)', 
  		'Accept' => 'application/json',
  		'Api-Key' => 'cb892c4261a01b6842c4787ae6cba21a826b0bce');
	my $res = $browser->get($url, @ns_headers);

	unless ($res->is_success) {
		return [];
	} else {
		my @response;
		my $resp = $res->decoded_content;
		my $hash = parse_json ($resp);

		foreach my $result(@{$hash->{results}}) {
			 push @response, 'https://fairsharing.org/' . $result->{bsg_id};
			 push @response, $result->{doi};
		}
		# need to deal with "next page" one day!
		return \@response;
	}
# return [
#"https://sourceforge.net/p/identifiers-org",
#"http://www.obofoundry.org",
#"http://bioportal.bioontology.org",
#"http://lov.okfn.org",
#"https://github.com/geneontology/go-site",
#"http://prefix.cc",
#"https://scicrunch.org/resources",
#"http://datahub.io",
#"https://www.biosharing.org/",
#"http://tinyurl.com/lsregistry",
#"http://eelst.cs.unibo.it/apps/LODE/source?url=http://purl.org/spar/datacite",
#"http://biocol.org",
#"http://dx.doi.org",
#"http://doi.org",
#"http://handle.org",
#"http://www.ebi.ac.uk/miriam",
#"https://tools.ietf.org/html/rfc1738",
#];
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
	my $schemas = {'schema' => ['spec', "The unique ID of the identifier schema definition in FAIRSharing (i.e. its FAIR Sharing URL or DOI - see 'https://fairsharing.org/standards/?q=&selected_facets=type_exact:identifier%20schema')"],
		       'subject' => ['string', "the GUID being tested"]};
	
	
	my $yaml = Metric::smartAPI->new(
					 title => "FAIR Metrics - Metric Unique Identifier",
					 description => "Metric to test if the resource uses a registered identifier scheme that guarantees global uniqueness.  The metric uses the FAIRSharing registry to check the response, so the schema used must be included in the registry.",
					 tests_metric => 'https://purl.org/fair-metrics/FM_A1.1',
					 applies_to_principle => "F1",
					 organization => 'CBGP UPM/INIA',
					 org_url => 'http://fairdata.systems',
					 responsible_developer => "Mark D Wilkinson",
					 email => 'markw@illuminae.com',
					 developerORCiD => '0000-0001-6960-357X',
					 host => 'linkeddata.systems',
					 basePath => '/cgi-bin',
					 path => '/fair_metrics/Metrics/metric_unique_identifier',
					 response_description => 'The response is a binary (1/0), success or failure',
					 schema => $schemas
					);
				 
				 
	print "Content-type: application/openapi+yaml;version=3.0\n\n";

	print $yaml->getSwagger();


  } else {
	return 1;   # THis is the end of the module returning positive!
  }
  


1; #


