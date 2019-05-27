#!ruby

require 'rdf'

template = <<END
@prefix : <https://w3id.org/fair/maturity_indicator/np/Gen2/@IDENTIFIER@/> .  # canonical URIs for the nanopublications
@prefix fairmi: <https://w3id.org/fair/maturity_indicator/terms/Gen2/> .  # canonical URIs for the indicators
@prefix dct: <http://purl.org/dc/terms/> .
@prefix dce: <http://purl.org/dc/elements/1.1/> .
@prefix np: <http://www.nanopub.org/nschema#> .
@prefix pav: <http://purl.org/pav/> .
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix fair: <https://w3id.org/fair/principles/terms/> . 
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix dcat: <http://www.w3.org/ns/dcat#> .
@prefix orcid: <https://orcid.org/> .
@prefix void: <http://rdfs.org/ns/void#> .

:Head {
  : np:hasAssertion :assertion ;
       np:hasProvenance :provenance ;
       np:hasPublicationInfo :pubinfo ;
       a np:Nanopublication .
 }
 
:assertion {
  fairmi:@IDENTIFIER@ a fairmi:FAIR-Maturity-Indicator ;
    rdfs:label "@TITLE@"^^xsd:string ;
    foaf:primaryTopic fair:@PRINCIPLE@ ;
    fairmi:measuring """@MEASURING@""" ;
    fairmi:rationale """@RATIONALE@""" ;
    fairmi:requirements """@REQUIREMENTS@""" ;
    fairmi:procedure """@PROCEDURE@""" ;
    fairmi:validation """@VALIDATION@""" ;
    fairmi:relevance """@RELEVANCE@""" ;
    fairmi:examples """@EXAMPLES@""" ;
    fairmi:comments """@COMMENTS@""" .
}
 
:provenance {
  :assertion pav:authoredBy @AUTHORS@ ;
    dcat:distribution _:dist1 .

  _:dist1 dce:format "text/markdown" ;
    a void:Dataset ;
    a dcat:Distribution ;
    dcat:downloadURL <https://w3id.org/fair/maturity_indicator/terms/Gen2/@IDENTIFIER@.md> .
}

 
:pubinfo {
  : dct:created "@DATE@"^^xsd:dateTime ;
    dct:rights <https://creativecommons.org/publicdomain/zero/1.0/> ;
    dct:rightsHolder <http://fairmetrics.org> ;
    pav:authoredBy orcid:0000-0001-6960-357X ;
    pav:createdBy orcid:0000-0002-1267-0234 .
  orcid:0000-0001-6960-357X foaf:name "Mark Wilkinson" .
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
		if a =~ /^\s?+([^\,]+)\, ORCID:([0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9X]{4})/
			authors << 'orcid:' + $2
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

def measuring(c)
	c =~ /### What is being measured\?([^#]+)/mi
	return $1.strip
end

def rationale(c)
	c =~ /### Why should we measure it\?([^#]+)/mi
	return $1.strip
end

def requirements(c)
	c =~ /### What must be provided for the measurement\?([^#]+)/mi
	return $1.strip
end

def procedure(c)
	c =~ /### How is the measurement executed\?([^#]+)/mi
	return $1.strip
end

def validation(c)
	c =~ /### What is.are considered valid result.s.\?([^#]+)/mi
	return $1.strip
end

def relevance(c)
	c =~ /### For which digital resource.s. is this relevant\? .or 'all'.([^#]+)/mi
	return $1.strip
end

def examples(c)
	c =~ /### Examples of good practices .that would score well on this assessment.([^#]+)/mi
	return $1.strip
end

def comments(c)
	c =~ /### Comments([^#]+)/mi
	return $1.strip
end



ARGV.each do |file|
	File.open(file) do |content|
		c = content.read
		temp = template
		temp.gsub!(/@IDENTIFIER@/, identifier(c))
		temp.gsub!(/@PRINCIPLE@/, principle(c))
		temp.gsub!(/@AUTHORS@/, authors(c))
		temp.gsub!(/@TITLE@/, title(c))
		temp.gsub!(/@DATE@/, date(c))
		temp.gsub!(/@MEASURING@/, measuring(c))
		temp.gsub!(/@RATIONALE@/, rationale(c))
		temp.gsub!(/@REQUIREMENTS@/, requirements(c))
		temp.gsub!(/@PROCEDURE@/, procedure(c))
		temp.gsub!(/@VALIDATION@/, validation(c))
		temp.gsub!(/@RELEVANCE@/, relevance(c))
		temp.gsub!(/@EXAMPLES@/, examples(c))
		temp.gsub!(/@COMMENTS@/, comments(c))
		puts temp
		f = File.open(identifier(c), "w")
		f.write temp
		f.close
	end

end
