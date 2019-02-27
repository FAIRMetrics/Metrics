#!ruby

require 'rdf'

template = <<END
@prefix this: <https://w3id.org/fair/maturity_indicator/Gen2/AAAAA> .  # canonical URI for the metric
@prefix sub: <https://w3id.org/fair/maturity_indicator/Gen2/AAAAA#> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix dcelem: <http://purl.org/dc/elements/1.1/> .
@prefix np: <http://www.nanopub.org/nschema#> .
@prefix nx: <http://www.nextprot.org/db/search#> .
@prefix pav: <http://swan.mindinformatics.org/ontologies/1.2/pav/> .
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix prv: <http://purl.org/net/provenance/ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix ro: <http://purl.org/obo/owl/OBO_REL#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix fair: <http://purl.org/fair-ontology#> . 
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix dcat: <http://www.w3.org/ns/dcat#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

sub:Head {
  sub:nanopub np:hasAssertion sub:assertion ;
       np:hasProvenance sub:provenance ;
       np:hasPublicationInfo sub:pubinfo ;
       a np:Nanopublication .
 }
 
sub:assertion {
 this: a fair:FAIR-Metric ;
  foaf:primaryTopic fair:BBBBB .

 }
 
sub:provenance {
 sub:assertion dcterms:author  CCCCC ;
 rdfs:comment "DDDDD"^^xsd:string ;
 dcat:distribution _:dist1 ;
 prov:wasGeneratedBy "FAIR Metrics Working Group" .
 
 _:dist1 dcelem:format "application/x-texinfo" ;
	rdf:type <http://rdfs.org/ns/void#Dataset> ;
	rdf:type <http://www.w3.org/ns/dcat#Distribution> ;
	dcat:downloadURL <https://w3id.org/fair/maturity_indicator/Gen2/AAAAA.md> .

}

 
sub:pubinfo {
 this: dcterms:created "EEEEE"^^xsd:dateTime ;
 dcterms:rights <https://creativecommons.org/publicdomain/zero/1.0> ;
 dcterms:rightsHolder <http://fairmetrics.org> ;
 pav:authoredBy "Mark Wilkinson" , <https://orcid.org/0000-0001-6960-357X> ;
 pav:versionNumber "1" ;
}

END


def identifier(c)
	c =~ /Identifier:\s+?(\S+)\s+?\[/i
	return $1
end

def principle(c)
	c =~ /apply\?\s+(\S+)\s?/i
	return $1
end

def authors(c)
	authors = Array.new
	c =~ /Authors:\s+?(.*?)###/mi
	authorlines = $1
	authorlines.split("\n").each do |a|
		if a =~ /^\s?+([^\,]+)\,/
			authors << '"' + $1 + '"'
		end
	end
	return authors.join(', ')
end

def title(c)
	c =~ /Title:\s+?(\w.*)\s?/i
	return $1
end

def date(c)
	c =~ /Publication\sDate:\s+?(\S+)\s?/i
	return $1
end



ARGV.each do |file|
	File.open(file) do |content|
		c = content.read
		aaaaa = identifier(c)
		bbbbb = principle(c)
		ccccc = authors(c)
		ddddd = title(c)
		eeeee = date(c)
		puts [aaaaa, bbbbb, ccccc, ddddd, eeeee].join("\t")
		temp = template
		temp.gsub!(/AAAAA/, aaaaa)
		temp.gsub!(/BBBBB/, bbbbb)
		temp.gsub!(/CCCCC/, ccccc)
		temp.gsub!(/DDDDD/, ddddd)
		temp.gsub!(/EEEEE/, eeeee)
		puts temp
		f = File.open(aaaaa, "w")
		f.write temp
		f.close
	end

end
