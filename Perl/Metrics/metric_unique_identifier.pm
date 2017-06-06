package Metrics::metric_unique_identifier;

use RDF::Trine;
use JSON::Parse 'parse_json';
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(execute_metric_test);
  
  
sub execute_metric_test {
	my ($body) = @_;
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
    use RDF::Trine::Serializer::Turtle;
    my $serializer = RDF::Trine::Serializer::Turtle->new( );
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

1;


