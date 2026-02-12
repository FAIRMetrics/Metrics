#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

# Output directory for generated .ttl files
OUTPUT_DIR = './generated_fair_metrics'
FileUtils.mkdir_p(OUTPUT_DIR)

# List of Gen2 Maturity Indicators (base names without extension)
# Sourced from FAIRsharing, publications (Wilkinson et al. 2019), and repo inspection
metrics = [
  { id: 'Gen2_MI_A1.1', title: 'Open protocol for (meta)data retrieval', principle: 'A1.1',
    keywords: %w[FAIR accessibility protocol open standard A1.1] },
  { id: 'Gen2_MI_A1.2', title: 'Protocol supports authentication and authorisation where applicable', principle: 'A1',
    keywords: %w[FAIR accessibility authentication authorization A1] },
  { id: 'Gen2_MI_A2', title: 'Metadata is long-lived and independently accessible', principle: 'A2',
    keywords: %w[FAIR accessibility metadata persistence A2] },
  { id: 'Gen2_MI_F1', title: 'Identifier is globally unique and persistent', principle: 'F1',
    keywords: %w[FAIR findability persistent identifier GUID F1] },
  { id: 'Gen2_MI_F2', title: 'Structured metadata', principle: 'F2',
    keywords: %w[FAIR findability structured metadata F2] },
  { id: 'Gen2_MI_F3', title: 'Metadata identifier explicitly in metadata', principle: 'F3',
    keywords: %w[FAIR findability metadata identifier F3] },
  { id: 'Gen2_MI_F4', title: 'Metadata is indexed in a searchable resource', principle: 'F4',
    keywords: %w[FAIR findability search indexed F4] },
  { id: 'Gen2_MI_I1', title: 'Metadata uses a formal, accessible, shared, broadly applicable language',
    principle: 'I1', keywords: %w[FAIR interoperability knowledge-representation FAIR-vocabulary I1] },
  { id: 'Gen2_MI_I2', title: '(Meta)data uses FAIR vocabularies', principle: 'I2',
    keywords: %w[FAIR interoperability vocabulary FAIR I2] },
  { id: 'Gen2_MI_I3', title: '(Meta)data includes qualified references to other (meta)data', principle: 'I3',
    keywords: %w[FAIR interoperability qualified-references linked-data I3] },
  { id: 'Gen2_MI_R1', title: 'Metadata contains a clear and accessible data usage license', principle: 'R1',
    keywords: %w[FAIR reusability license R1] },
  { id: 'Gen2_MI_R1.1', title: 'Metadata license is a standard license', principle: 'R1.1',
    keywords: %w[FAIR reusability standard-license machine-readable R1.1] },
  { id: 'Gen2_MI_R1.2', title: 'Metadata license is machine-understandable', principle: 'R1.2',
    keywords: %w[FAIR reusability license machine-readable R1.2] },
  { id: 'Gen2_MI_R1.3', title: 'Metadata contains provenance information', principle: 'R1.3',
    keywords: %w[FAIR reusability provenance R1.3] }
  # Add more if discovered, e.g. Gen2_MI_F1B variants if separate files exist
]

# Fixed parts
PREFIXES = <<~PREFIXES
  @prefix ftr:     <https://w3id.org/ftr#> .
  @prefix dcterms: <http://purl.org/dc/terms/> .
  @prefix xsd:     <http://www.w3.org/2001/XMLSchema#> .
  @prefix foaf:    <http://xmlns.com/foaf/0.1/> .
  @prefix dcat:    <http://www.w3.org/ns/dcat#> .
  @prefix dpv:     <https://w3id.org/dpv#> .
  @prefix schema:  <https://schema.org/> .
  @prefix vivo:    <http://vivoweb.org/ontology/core#> .
PREFIXES

CREATOR = <<~CREATOR
  ftr:creator               [
      a                     foaf:Person ;
      foaf:name             "Mark D. Wilkinson" ;
      foaf:mbox             <mailto:markw@illuminae.com>
  ] ;
CREATOR

COMMON = <<~COMMON
  dcterms:version           "Gen2" ;

  ftr:applicationArea       <http://www.fairsharing.org/ontology/subject/SRAO_0000401> ;

  dcterms:license           <https://creativecommons.org/licenses/by/4.0/> ;

  dpv:isApplicableFor       schema:CreativeWork .
COMMON

metrics.each do |m|
  slug = m[:id].downcase.gsub('_', '-')
  uri = "https://w3id.org/fair-metrics/general/#{slug}.ttl"
  identifier = "https://w3id.org/fair-metrics/general/#{slug}"
  md_url = "https://github.com/FAIRMetrics/Metrics/blob/master/MaturityIndicators/Gen2/#{m[:id]}.md"

  ttl_content = <<~TTL
    #{PREFIXES}

    <#{uri}>
        a                          ftr:Metric, dcat:Dataset ;
    #{'    '}
        ftr:identifier            "#{identifier}"^^xsd:anyURI ;
        dcterms:title             "#{m[:title]}" ;
        vivo:abbreviation         "#{slug}" ;
        dcterms:description       """Metric #{m[:id]} #{m[:title].downcase}. This metric aligns with FAIR Principle #{m[:principle]}.""" ;
        dcat:keyword              #{m[:keywords].map { |k| "\"#{k}\"" }.join(', ')} ;
    #{'    '}
        dcat:landingPage          <#{md_url}> ;
    #{'    '}
    #{CREATOR}
    #{COMMON}


  TTL

  filename = "#{OUTPUT_DIR}/#{slug}.ttl"
  File.write(filename, ttl_content)
  puts "Generated: #{filename}"
end

puts "All done! #{metrics.size} files created in #{OUTPUT_DIR}"
