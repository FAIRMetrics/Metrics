#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'uri'
require 'fileutils'

# === CONFIG ===
PREFIXES = <<~TTL
  @prefix vcard:   <http://www.w3.org/2006/vcard/ns#> .
  @prefix ftr:     <https://w3id.org/ftr#> .
  @prefix dcterms: <http://purl.org/dc/terms/> .
  @prefix xsd:     <http://www.w3.org/2001/XMLSchema#> .
  @prefix foaf:    <http://xmlns.com/foaf/0.1/> .
  @prefix dcat:    <http://www.w3.org/ns/dcat#> .
  @prefix dpv:     <https://w3id.org/dpv#> .
  @prefix schema:  <https://schema.org/> .
  @prefix vivo:    <http://vivoweb.org/ontology/core#> .
  @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .

TTL

VERSION = 'Champion1.0'
LICENSE = '<https://creativecommons.org/licenses/by/4.0/>'
SUPPORTED_BY = '<https://w3id.org/FAIR-Champion>'
APP_AREA = '<http://www.fairsharing.org/ontology/subject/SRAO_0000401>'
APPLICABLE_FOR = 'schema:CreativeWork'

# Output directory
OUTPUT_DIR = 'turtle_metrics'
FileUtils.mkdir_p(OUTPUT_DIR)

# === HELPERS ===

def clean_text(text)
  text.strip.gsub(/\s+/, ' ')
end

def escape_turtle_string(str)
  str.gsub('"', '\\"').gsub("\n", '\\n').gsub("\r", '')
end

def make_html_paragraphs(paragraphs)
  paragraphs.map { |p| "<p>#{p.strip}</p>" }.join("\n\n")
end

def hyperlink_urls(text)
  text.gsub(URI::DEFAULT_PARSER.make_regexp(%w[http https])) do |url|
    "<a href=\"#{url}\">#{url}</a>"
  end
end

def extract_orcids(authors_block)
  return [] if authors_block.nil? || authors_block.strip.empty?

  warn "Authors block: #{authors_block.inspect}" # keep for debugging

  creators = []

  # Split on newlines and process each author line
  authors_block.each_line do |line|
    line = line.strip
    next if line.empty?

    # Match: Name (anything until comma or ORCID), then optional ", ORCID:xxxx"
    match = line.match(/^(.*?),?\s*ORCID:?\s*([\d-]+)?/i)
    next unless match

    name  = clean_text(match[1])
    orcid = match[2]&.strip

    next if name.empty?

    creator = { name: name }
    creator[:orcid] = orcid if orcid && orcid =~ /^\d{4}-\d{4}-\d{4}-\d{3}[0-9X]$/

    creators << creator
  end

  creators
end

def extract_emails(contact_block)
  return [] if contact_block.nil? || contact_block.strip.empty?

  # Much more robust: handle markdown links [text](mailto:email) AND plain emails
  # Also strips trailing junk like )), >, etc.
  emails = contact_block.scan(
    /(?:mailto:)?([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/i
  ).map(&:first)

  # Final cleanup
  emails.map! { |e| e.gsub(/[)\]>]+$/, '').strip }
  emails.uniq
end

def parse_date(date_str)
  Date.parse(date_str).iso8601
rescue StandardError
  nil
end

def is_valid_url?(str)
  uri = begin
    URI.parse(str)
  rescue StandardError
    nil
  end
  uri && %w[http https].include?(uri.scheme)
end

# === MAIN PARSER ===

def parse_metric_block(block)
  metric = {}

  # Title & identifier
  if block =~ /\*\*TITLE: (.*?)\*\*/
    warn "adding title #{Regexp.last_match(1).strip}"
    metric[:title] = Regexp.last_match(1).strip
    if metric[:title] =~ /FAIR Metric – (.*?) – (.*)/
      metric[:principle] = Regexp.last_match(1).strip
      metric[:subtitle] = Regexp.last_match(2).strip
    else
      abort "title line didn't match title"
    end
  else
    abort "entire block didn't match title"
  end

  # Metric Identifier
  metric[:identifier] = Regexp.last_match(1).strip if block =~ /### \*\*Metric Identifier: ?(FM_[^\s<]+)/

  # Authors
  authors_section = block.match(/## \*\*Authors:\*\*(.+?)(?=####|\z)/m)
  if authors_section
    metric[:authors] = extract_orcids(authors_section[1])
  else
    creators = []
    creator = { name: 'Allyson L. Lister' }
    creator[:orcid] = '0000-0002-7702-4495'
    creators << creator
    metric[:authors] = creators
  end

  # Publication / Last Edit dates
  metric[:issued] = parse_date(Regexp.last_match(1)) if block =~ /#### \*\*Publication Date: ?(\d{4}-\d{2}-\d{2})/
  metric[:modified] = parse_date(Regexp.last_match(1)) if block =~ /#### \*\*Last Edit: ?(\d{4}-\d{2}-\d{2})/

  # Contact point / emails
  contact_section = block.match(/Contact point .*?:(.+?)(?=Maintains|\z)/m)
  metric[:emails] = extract_emails(contact_section[1]) if contact_section

  # Description parts
  what = block.match(/### \*\*What is being measured\?\*\*(.+?)(?=### \*\*Why|\z)/m)
  why  = block.match(/### \*\*Why should we measure it\?\*\*(.+?)(?=### \*\*Illustrative|\z)/m)
  comments = block.match(/### \*\*Comments\*\*(.+?)(?=\z)/m)

  desc_parts = []
  desc_parts << what[1].strip if what
  desc_parts << why[1].strip if why
  desc_parts << comments[1].strip if comments

  metric[:description_raw] = desc_parts.join("\n\n")
  metric[:description] = make_html_paragraphs(
    desc_parts.map { |p| hyperlink_urls(p.gsub(/\n+/, ' ').strip) }
  )

  # Illustrative Examples → positives & negatives
  positives = []
  negatives = []

  if block =~ /### \*\*Illustrative Examples\*\*(.+?)(?=### \*\*Comments|\z)/m
    table = Regexp.last_match(1)
    table.scan(/Expected to (pass|fail)\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)(?=\||\z)/) do |outcome, example, _note|
      url = clean_text(example).gsub(/\[|\]/, '').strip
      next unless is_valid_url?(url)

      if outcome == 'pass'
        positives << url
      elsif outcome == 'fail'
        negatives << url
      end
    end
  end

  metric[:positives] = positives.uniq
  metric[:negatives] = negatives.uniq

  # ───────────────────────────────────────────────
  # Try to find w3id URL first
  # ───────────────────────────────────────────────
  w3id_match = block.match(
    %r{https://w3id\.org/fair-metrics/general/FM_[A-Za-z0-9_-]+}i
  )

  short_name = nil

  if w3id_match
    w3id_url = w3id_match[0].strip
    short_name = w3id_url.split('/').last&.strip
    puts "Found w3id URL: #{w3id_url} → short: #{short_name.inspect}"
  else
    # Find any line containing "Metric Identifier"
    # === SUPER LOOSE FALLBACK — NO MORE CLEVERNESS ===
    id_line = block.lines.find { |line| line =~ /Metric Identifier/i }

    if id_line
      raw_value = id_line.sub(/.*Metric Identifier:?\**?/i, '').strip

      warn "Raw after label: #{raw_value.inspect}"

      # Look for the letters "FM" (the \ after it is irrelevant)
      fm_start = raw_value.index(/FM/i)

      if fm_start
        candidate = raw_value[fm_start..-1].strip

        warn "Candidate before clean: #{candidate.inspect}"

        # THIS IS THE LINE THAT WAS MISSING
        candidate.gsub!(/\\+/, '') # kill every backslash

        candidate.gsub!(/[\s)\]*]+$/, '') # kill trailing junk

        short_name = candidate.strip

        puts "Loose fallback captured: #{raw_value.inspect} → cleaned: #{short_name.inspect}"

        if short_name.start_with?('FM_') && short_name.length >= 10
          cleaned_short = short_name

          metric[:identifier]   = cleaned_short
          metric[:uri]          = "https://w3id.org/fair-metrics/general/#{cleaned_short}"
          metric[:landing]      = metric[:uri]
          metric[:ftr_id_value] = metric[:uri]
          metric[:defined_by]   = "https://fairmetrics.github.io/Metrics/metric/general/#{cleaned_short}.ttl"

          puts "SUCCESS - Used identifier: #{cleaned_short}"
        else
          warn "After cleaning still bad: #{short_name.inspect}"
        end
      else
        warn 'No FM anywhere'
      end
    else
      warn 'No Metric Identifier line'
    end
  end

  # ───────────────────────────────────────────────
  # If we have a plausible short name, build everything
  # ───────────────────────────────────────────────
  if short_name && short_name =~ /^FM_[^\s]+$/i && short_name.length > 8
    cleaned_short = short_name.gsub(/[^A-Za-z0-9_-]/, '') # final safety strip

    metric[:identifier]   = cleaned_short
    metric[:uri]          = "https://w3id.org/fair-metrics/general/#{cleaned_short}"
    metric[:landing]      = metric[:uri]
    metric[:ftr_id_value] = metric[:uri]
    metric[:defined_by]   = "https://fairmetrics.github.io/Metrics/metric/general/#{cleaned_short}.ttl"

    puts "Final identifier: #{cleaned_short} | URI: #{metric[:uri]}"
  else
    warn "No usable identifier could be extracted (neither w3id URL nor Metric Identifier line) from #{short_name}"
    # Optionally: return nil or set placeholder
    return nil
  end
  warn "RETURNING METRIC #{metric[:identifier]}\n\n"
  metric
end

def render_turtle(metric)
  uri = metric[:uri] # the w3id one

  turtle = PREFIXES.dup

  turtle << "<#{uri}>\n"
  turtle << "    a                          ftr:Metric, dcat:Dataset ;\n"
  turtle << "    rdfs:definedBy            <#{metric[:defined_by]}> ;\n\n" # now correctly github.io + .ttl

  turtle << "    ftr:identifier            \"#{uri}\"^^xsd:anyURI ;\n"
  turtle << "    dcterms:title             \"#{escape_turtle_string(metric[:title])}\" ;\n"
  turtle << "    vivo:abbreviation         \"#{metric[:identifier]}\" ;\n" # short FM_... name

  # description, keywords etc.

  turtle << "    dcat:landingPage          <#{metric[:landing]}> ;\n\n"     # w3id URL again
  turtle << "    dcterms:description       \"\"\"#{metric[:description]}\"\"\" ;\n"
  turtle << "    dcat:keyword              \"FAIR\", \"#{metric[:principle] || 'F1'}\", \"identifier\", \"metadata\" ;\n\n"

  turtle << "    dcat:landingPage          <#{metric[:landing]}> ;\n\n"     # w3id URL again
  # Creators
  metric[:authors]&.each do |author|
    turtle << "    dcterms:creator           [\n"
    turtle << "        a                     vcard:Individual ;\n"
    turtle << "        vcard:fn              \"#{escape_turtle_string(author[:name])}\" ;\n"
    turtle << "        vivo:orcidId          <http://orcid.org/#{author[:orcid]}> ;\n" if author[:orcid]
    # Use first email if available (simplistic)
    turtle << "        vcard:hasEmail             <mailto:#{metric[:emails].first}> ;\n" if metric[:emails]&.any?
    turtle << "    ] ;\n"
  end

  turtle << "\n" if metric[:issued] || metric[:modified]
  turtle << "    dcterms:issued            \"#{metric[:issued]}\"^^xsd:date ;\n" if metric[:issued]
  turtle << "    dcterms:modified          \"#{metric[:modified]}\"^^xsd:date ;\n" if metric[:modified]

  turtle << "\n    dcat:version              \"#{VERSION}\" ;\n\n"

  turtle << "    ftr:applicationArea       #{APP_AREA} ;\n"
  turtle << "    dcterms:license           #{LICENSE} ;\n\n"

  metric[:positives]&.each do |ex|
    turtle << "    ftr:hasPositiveValidation <#{ex}> ;\n"
  end
  metric[:negatives]&.each do |ex|
    turtle << "    ftr:hasNegativeValidation <#{ex}> ;\n"
  end

  turtle << "\n    ftr:supportedBy           #{SUPPORTED_BY} ;\n"
  turtle << "    dpv:isApplicableFor       #{APPLICABLE_FOR} .\n\n"

  turtle
end

# === RUN ===

if ARGV.empty?
  puts 'Usage: ruby md_to_dcat.rb file1.md [file2.md ...]'
  puts '   or: cat metrics.md | ruby md_to_dcat.rb'
  exit 1
end

ARGV.each do |file|
  content = File.exist?(file) ? File.read(file) : file

  # Split into individual metric blocks
  blocks = content.split(/(?=\*\*TITLE:)/m).reject(&:empty?)
  warn blocks.count, 'blocks'
  blocks.each_with_index do |block, i|
    if block !~ /\*\*TITLE:/ # skip anything without a TITLE heading
      warn "lacked a title #{block.inspect}\n\n\n\n\n"
      next
    end

    # or: next if i.zero? && block !~ /Metric Identifier|Landing page/   # more conservative

    metric = parse_metric_block(block)
    unless metric && metric[:title] && metric[:uri]
      warn "title: #{metric[:title]}"
      warn "uri: #{metric[:uri]}"
      abort
    end

    puts "Processing metric: #{metric[:title]} (#{metric[:identifier]})"
    turtle_str = render_turtle(metric)

    filename = "#{metric[:identifier]}.ttl"
    path = File.join(OUTPUT_DIR, filename)

    File.write(path, turtle_str)
    puts "Wrote: #{path}"
    puts "=======================================NEXT BLOCK\n\n\n"
  end
end

puts "Done! Check #{OUTPUT_DIR}/ for Turtle files."
