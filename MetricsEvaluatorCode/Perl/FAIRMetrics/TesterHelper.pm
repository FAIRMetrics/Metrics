#!/usr/bin/perl -w
package FAIRMetrics::TesterHelper;
use Moose;
require Exporter;
use vars ('@ISA', '@EXPORT');
@ISA = qw(Exporter);
@EXPORT = qw(ser statement);


use LWP::Simple;
use RDF::Trine;
use JSON::Parse 'parse_json';
use DateTime;

has 'title' => (isa => "Str", required => 1, is => 'rw');
has 'tests_metric' => (isa => "Str", required => 1, is => 'rw');
has 'description' => (isa => "Str", required => 1, is => 'rw');
has 'applies_to_principle' => (isa => "Str", required => 1, is => 'rw');
has 'organization' => (isa => "Str", required => 1, is => 'rw');
has 'org_url' => (isa => "Str", required => 1, is => 'rw');
has 'responsible_developer' => (isa => "Str", required => 1, is => 'rw');
has 'email' => (isa => "Str", required => 1, is => 'rw');
has 'developer_ORCiD' => (isa => "Str", required => 1, is => 'rw');
has 'host' => (isa => "Str", required => 1, is => 'rw');
has 'basePath' => (isa => "Str", required => 1, is => 'rw');
has 'path' => (isa => "Str", required => 1, is => 'rw');
has 'response_description' => (isa => "Str", required => 1, is => 'rw');
has 'schemas' => (isa => 'HashRef', required => 1, is => 'rw');
has 'comments' => (isa => 'Str', required => 1, is => 'rw', default => "");
has 'fairsharing_key_location' => (isa => 'Str', required => 0, is => 'rw', default => "./");

#  print "Content-type: application/openapi+yaml;version=3.0\n\n";


sub fairsharing_key {
      my ($self) = @_;
      open(IN, $self->fairsharing_key_location) || return '';
      my ($key) = <IN>;
      chomp $key,
      return $key 
}


sub tester_uri {
        my $cgi = CGI->new();
        my $name = $ENV{"REQUEST_SCHEME"}.'://'.$cgi->server_name.$cgi->script_name().$cgi->path_info();
        $name =~ s/\.pm$//;
        return $name
}

sub addComment {
      my ($self, $newcomment) = @_;
      my $comment = $self->comments;
      $comment .= $newcomment;
      $self->comment($comment);
      return 1
}

sub createEvaluationResponse {
      my ($self, $testedIRI, $value) = @_;      
      
      my $store = RDF::Trine::Store::Memory->new();
      my $model = RDF::Trine::Model->new($store);
      
      $value = RDF::Trine::Node::Literal->new($value);
      
      my $dt = DateTime->now(time_zone=>'local');
      my $dts = $dt->datetime();
      $dts = RDF::Trine::Node::Literal->new( $dts,"", "xsd:dateTime");
      my $time = time;
      
      my $uri = $self->tester_uri;      
      my $statement = statement("$uri/result#$time", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://fairmetrics.org/resources/metric_evaluation_result" );
      $model->add_statement($statement);
      $statement = statement("$uri/result#$time", "http://semanticscience.org/resource/SIO_000300", $value );
      $model->add_statement($statement);
      $statement = statement("$uri/result#$time", "http://purl.obolibrary.org/obo/date", $dts );
      $model->add_statement($statement);
      $statement = statement($testedIRI,"http://semanticscience.org/resource/SIO_000629", "$uri/result#$time");
      $model->add_statement($statement);

      
        if ($self->comment ne "") {
                $statement = statement("$uri/result#$time", "http://schema.org/comment", $self->comment);
                $model->add_statement($statement);
        }

      #print "Content-type: application/json\n\n";
      return ser($model);

}



sub getSwagger {
      my ($self) = @_;
      my $title = $self->title;
      my $tests_metric = $self->tests_metric;
      my $description = $self->description;
      my $applies_to_principle = $self->applies_to_principle;
      my $organization = $self->organization;
      my $org_url = $self->org_url;
      my $responsibleDeveloper = $self->responsible_developer;
      my $email = $self->email;
      my $developerORCiD = $self->developer_ORCiD;
      my $host = $self->host;
      my $basePath = $self->basePath;
      my $path = $self->path;
      my $response_description = $self->response_description;
                  
      my $message = <<"EOF_EOF";
swagger: '2.0'
info:
  version: '0.1'
  title: $title
  x-tests_metric: '$tests_metric'
  description: >-
    $description
  x-applies_to_principle: $applies_to_principle
  contact:
    x-organization: $organization
    url: '$org_url'
    name: $responsibleDeveloper
    x-role: "responsible developer"
    email: $email
    x-id: '$developerORCiD'
host: $host
basePath: $basePath
schemes:
  - http
produces:  
- application/json
consumes:
  - application/json
paths:
  $path:
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
            $response_description
definitions:
  schemas:
      required:
EOF_EOF



      foreach my $key(keys %{$self->schemas}) {
            $message .= "        - $key\n";
      }
      $message .= "      properties:\n";
      foreach my $key(keys %{$self->schemas}) {
            $message .= "        $key:\n";
            $message .= "          type: ".(${$self->schemas}{$key}[0])."\n";
            $message .= "          description: >-\n";
            $message .= "            ${$self->schemas}{$key}[1]\n";      
      }
      
      return $message
}




# ---------------------------- exported helper subs ----------------

sub ser {   # general routine, exported 
    my ($m) = @_;
    use RDF::Trine::Serializer::RDFJSON;
    my $serializer = RDF::Trine::Serializer::RDFJSON->new( );
#    print $serializer->serialize_model_to_string($m);
    
    return $serializer->serialize_model_to_string($m);
    
}



sub statement {  # general routine, exported
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
  
no Moose;
__PACKAGE__->meta->make_immutable;
