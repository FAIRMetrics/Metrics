#!/usr/bin/env ruby
# frozen_string_literal: true

require 'linkeddata'
require 'rdf/turtle'
require 'json/ld'
require 'erb'
require 'fileutils'
require 'optparse'

# Namespaces
module NS
  DCAT  = RDF::Vocabulary.new('http://www.w3.org/ns/dcat#')
  VIVO  = RDF::Vocabulary.new('http://vivoweb.org/ontology/core#')
  VCARD = RDF::Vocabulary.new('http://www.w3.org/2006/vcard/ns#')
  DCT   = RDF::Vocabulary.new('http://purl.org/dc/terms/')
  RDFS  = RDF::Vocabulary.new('http://www.w3.org/2000/01/rdf-schema#')
  FTR   = RDF::Vocabulary.new('https://w3id.org/ftr#')
  DQV   = RDF::Vocabulary.new('http://www.w3.org/ns/dqv#')
  DPV   = RDF::Vocabulary.new('https://w3id.org/dpv#')
end

class JSON::Ext::Generator::State
  # monkey patch due to incompatibilities between linkeddata gem and json-ld
  def except(*keys)
    # Convert to real Hash, drop keys, then reconstruct (safe since to_h exists)
    to_h.except(*keys)
  end
end

class TTLConverter
  def initialize(source_dir, destination_dir = nil)
    @source_dir = File.expand_path(source_dir)
    @dest_dir   = destination_dir ? File.expand_path(destination_dir) : @source_dir
    @landing_dir = File.join(@dest_dir, 'landingpages')
    @index_entries = {}
    warn "landingdir = #{@landing_dir}  "
  end

  def run
    FileUtils.rm_rf(@landing_dir)
    FileUtils.mkdir_p(@landing_dir)

    process_type('metric',    'template_metric.erb',    QUERY_METRIC)
    process_type('test',      'template_test.erb',      QUERY_TEST)
    process_type('benchmark', 'template_benchmark.erb', QUERY_BENCHMARK)

    generate_catalog_and_index
    puts "\n✅ All done! HTML landing pages are in #{@landing_dir}"
  end

  private

  def process_type(subfolder, template_name, sparql_query)
    source_path = File.join(@source_dir, subfolder)
    return unless Dir.exist?(source_path)

    template_path = File.join('templates', template_name)
    raise "Template not found: #{template_path}" unless File.exist?(template_path)

    Dir.glob(File.join(source_path, '**/*.ttl')).each do |ttl_path|
      relative = File.dirname(ttl_path).sub(@source_dir + '/', '')
      basename = File.basename(ttl_path, '.ttl')
      relative.gsub!(%r{^\w+/}, '') # Remove leading metric/, test/, benchmark/ from relative path

      # JSON-LD next to TTL
      jsonld_path = File.join(File.dirname(ttl_path), "#{basename}.jsonld")
      ttl_to_jsonld(ttl_path, jsonld_path)

      # HTML in landingpages mirror
      html_dir = File.join(@landing_dir, relative)
      FileUtils.mkdir_p(html_dir)
      html_path = File.join(html_dir, "#{basename}.html")
      warn html_path

      data = ttl_to_html(ttl_path, html_path, template_path, sparql_query)
      next unless data && html_dir != @landing_dir

      @index_entries[html_dir] ||= []
      @index_entries[html_dir] << {
        href: "#{basename}.html",
        name: (data[:metric_name] || data[:test_name] || data[:benchmark_name] || basename).to_s,
        description: plain_text_excerpt(
          (data[:metric_description] || data[:test_description] || data[:benchmark_description] || '').to_s
        )
      }
    end
  end

  def ttl_to_jsonld(ttl_path, jsonld_path)
    graph = RDF::Graph.load(ttl_path, format: :turtle)
    data = graph.dump(:jsonld, standard_prefixes: true, indent: 2)
    File.write(jsonld_path, data)
    puts "✓ JSON-LD: #{jsonld_path}"
  rescue StandardError => e
    puts "✗ JSON-LD error #{ttl_path}: #{e.message}"
  end

  def ttl_to_html(ttl_path, html_path, template_path, sparql_query)
    graph = RDF::Graph.load(ttl_path, format: :turtle)
    results = graph.query(SPARQL.parse(sparql_query))

    data = build_data(graph, results, ttl_path)

    template = File.read(template_path)
    renderer = ERB.new(template, trim_mode: '-')
    html = renderer.result_with_hash(data)

    File.write(html_path, html)
    puts "✓ HTML:   #{html_path}"
    data
  rescue StandardError => e
    puts "✗ HTML error #{ttl_path}: #{e.message}"
    nil
  end

  # Robust contactPoint extraction (handles bnodes + vivo:orcidId)
  def extract_contact_point_html(graph, subject)
    contacts = []

    graph.query([subject, NS::DCAT.contactPoint, nil]).each do |stmt|
      contact = stmt.object

      email = graph.query([contact, RDF::URI('http://www.w3.org/2006/vcard/ns#hasEmail')]).first&.object
      name  = graph.query([contact, RDF::URI('http://www.w3.org/2006/vcard/ns#fn')]).first&.object
      orcid = graph.query([contact, RDF::URI('http://vivoweb.org/ontology/core#orcidId')]).first&.object
      name_str  = name&.to_s&.strip
      email_str = email&.to_s&.strip
      orcid_str = orcid&.to_s&.strip

      html = if orcid_str && !orcid_str.empty? && name_str
               %(<a href="#{orcid_str}" target="_blank">#{name_str}</a>)
             elsif email_str && !email_str.empty? && name_str
               %(<a href="#{email_str}" target="_blank">#{name_str}</a>)
             elsif name_str && !name_str.empty?
               name_str
             else
               contact.to_s
             end

      contacts << html
    end

    contacts.empty? ? '—' : contacts.join(', ')
  end

  def build_data(graph, results, ttl_path)
    row = results.first
    subject = if row && row[:s]
                row[:s]
              else
                # Fallback: try to find any subject that is a Metric/Test/Benchmark
                graph.first_subject || RDF::URI('urn:unknown')
              end

    basename = File.basename(ttl_path, '.ttl')

    {
      # Metric fields
      metric_name: (row && (row[:title] || row[:label]) || basename).to_s,
      metric_title: (row && row[:title] || '').to_s,
      metric_identifier: subject.to_s,
      metric_description: (row && row[:description] || '').to_s.gsub("\n", '<br>'),
      metric_version: (row && row[:version] || '').to_s,
      metric_keywords: results.map { |r| r[:keywords] }.compact.map(&:to_s).uniq.join(', '),
      metric_contactPoint: extract_contact_point_html(graph, subject),
      metric_license: (row && row[:license] || '').to_s,
      metric_status: (row && row[:metric_status] || 'Active').to_s,
      metric_landing_page: (row && row[:landing_page] || '').to_s,
      # metric_turtle: "#{basename}.ttl",
      metric_turtle: "../../#{basename}.ttl", # Adjusted path for linking from landingpages}"
      metric_test: (row && row[:test] || '').to_s,
      metric_applicable_for: (row && row[:applicable_for] || '').to_s,
      metric_supported_by: (row && row[:supported_by] || '').to_s,
      metric_same_as: (row && row[:same_as] || '').to_s,
      metric_benchmarks: '',
      metric_publishers: '',
      metric_dimension: (row && row[:dimension] || '').to_s,

      # Test fields
      test_name: (row && (row[:label] || row[:title]) || basename).to_s,
      test_title: (row && row[:title] || '').to_s,
      test_identifier: subject.to_s,
      test_description: (row && row[:description] || '').to_s.gsub("\n", '<br>'),
      test_contactPoint: extract_contact_point_html(graph, subject),
      test_turtle: "#{basename}.ttl",
      test_version: (row && row[:version] || '').to_s,

      # Benchmark fields
      benchmark_name: (row && (row[:label] || row[:title]) || basename).to_s,
      benchmark_title: (row && row[:title] || '').to_s,
      benchmark_identifier: subject.to_s,
      benchmark_description: (row && row[:description] || '').to_s.gsub("\n", '<br>'),
      benchmark_contactPoint: extract_contact_point_html(graph, subject),
      benchmark_turtle: "#{basename}.ttl",

      acknowledgements_html: ACKNOWLEDGEMENTS_HTML
    }
  end

  def generate_catalog_and_index
    index_template_path = File.join('templates', 'template_index.erb')
    unless File.exist?(index_template_path)
      puts '⚠️  template_index.erb not found, skipping index generation'
      return
    end

    renderer = ERB.new(File.read(index_template_path), trim_mode: '-')
    top_level_items = []

    @index_entries.each do |dir, entries|
      subfolder_name = dir.sub("#{@landing_dir}/", '')
      items = entries.sort_by { |i| i[:href].downcase }

      html = renderer.result_with_hash(
        page_title: "#{subfolder_name.capitalize} — FAIR Metrics",
        back_link: '../index.html',
        items: items,
        acknowledgements_html: ACKNOWLEDGEMENTS_HTML
      )
      index_path = File.join(dir, 'index.html')
      File.write(index_path, html)
      puts "✓ Index:  #{index_path}"

      top_level_items << {
        href: "#{subfolder_name}/index.html",
        name: subfolder_name.capitalize,
        description: "#{items.size} item#{items.size == 1 ? '' : 's'}"
      }
    end

    top_html = renderer.result_with_hash(
      page_title: 'FAIR Metrics Catalogue',
      back_link: nil,
      items: top_level_items.sort_by { |i| i[:name].downcase },
      acknowledgements_html: ACKNOWLEDGEMENTS_HTML
    )
    top_index_path = File.join(@landing_dir, 'index.html')
    File.write(top_index_path, top_html)
    puts "✓ Index:  #{top_index_path}"
  end

  def plain_text_excerpt(html, max_length = 200)
    text = html.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip
    text.length > max_length ? "#{text[0, max_length]}…" : text
  end

  # SPARQL Queries (simplified but functional - extend as needed)
  QUERY_METRIC = <<~SPARQL
    PREFIX dcterms: <http://purl.org/dc/terms/>
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    PREFIX ftr: <https://w3id.org/ftr#>
    PREFIX vivo: <http://vivoweb.org/ontology/core#>
    PREFIX dqv:    <http://www.w3.org/ns/dqv#>
    PREFIX dpv:     <https://w3id.org/dpv#>

    SELECT ?s ?title ?label ?description ?version ?license ?keywords ?dimension ?landing_page ?metric_status
           ?applicable_for ?supported_by ?same_as ?test
    WHERE {
      ?s a ftr:Metric .
      ?s dcterms:title ?title .
      OPTIONAL { ?s rdfs:label ?label }
      ?s dcterms:description ?description .
      ?s dcat:version ?version .
      ?s dcterms:license ?license .
      ?s dcat:landingPage ?landing_page .
      OPTIONAL { ?s dqv:inDimension ?dimension }
      OPTIONAL { ?s ftr:status ?metric_status }
      OPTIONAL { ?s dcat:keyword ?keywords }
      OPTIONAL { ?s dpv:isApplicableFor ?applicable_for }
      OPTIONAL { ?s ftr:supportedBy ?supported_by }
      OPTIONAL { ?s ftr:hasTest ?test }
    }
  SPARQL

  QUERY_TEST = QUERY_METRIC.gsub('ftr:Metric', 'ftr:Test')
  QUERY_BENCHMARK = QUERY_METRIC.gsub('ftr:Metric', 'ftr:Benchmark')

  ACKNOWLEDGEMENTS_HTML = <<~HTML.freeze
    <div style="background:#1a3a6b;color:#fff;padding:28px 0;margin-top:40px;">
      <div class="container">
        <div class="row" style="display:flex;align-items:center;flex-wrap:wrap;">
          <div class="col-md-2 col-sm-3 text-center" style="margin-bottom:10px;">
            <a href="https://ostrails.eu" target="_blank">
              <img src="https://ostrails.eu/images/OSTrails-LOGO/SVG/logo%20white%202.svg"
                   alt="OSTrails" style="height:60px;max-width:100%;">
            </a>
          </div>
          <div class="col-md-8 col-sm-6" style="font-size:13px;line-height:1.7;padding:0 20px;margin-bottom:10px;">
            Developed in the context of the
            <a href="https://ostrails.eu" target="_blank" style="color:#9fcfee;font-weight:bold;">OSTrails</a>
            project. This project has received funding from the European Union&#8217;s Horizon Europe
            framework programme under grant agreement No.&nbsp;101130187. Views and opinions expressed are
            however those of the author(s) only and do not necessarily reflect those of the European Union
            or the European Research Executive Agency. Neither the European Union nor the European Research
            Executive Agency can be held responsible for them.
          </div>
          <div class="col-md-2 col-sm-3 text-center" style="margin-bottom:10px;">
            <img src="https://ostrails.eu/images/GraspOS_Branding/EN-Funded%20by%20the%20EU-WHITE.png"
                 alt="Funded by the European Union" style="height:60px;max-width:100%;">
          </div>
        </div>
      </div>
    </div>
  HTML
end

# CLI
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby convert_ttl.rb -i SOURCE [-o DEST]'
  opts.on('-i', '--input DIR', 'Source directory') { |v| options[:input] = v }
  opts.on('-o', '--output DIR', 'Destination directory') { |v| options[:output] = v }
end.parse!

abort 'Error: --input (-i) is required' if options[:input].nil?

TTLConverter.new(options[:input], options[:output]).run
