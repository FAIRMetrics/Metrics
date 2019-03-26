require 'json'
require 'rdf'
require 'rdf/json'
require 'json/ld'
require 'rdf/raptor'
require 'net/http'
require 'net/https' # for openssl
require 'uri'
require 'rdf/turtle'
require 'sparql'
require 'tempfile'
require 'xmlsimple'
require 'nokogiri'
require 'parseconfig'
require 'rest-client'


class Utils
    config = ParseConfig.new('config.conf')
    @extruct_command = "extruct" unless config
    @extruct_command = config['extruct']['command'] if config['extruct'] && config['extruct']['command'] && !config['extruct']['command'].empty?
    #$stderr.puts "EXTRUCT #{@extruct_command}\n\n"
    Utils::ExtructCommand = @extruct_command

    Utils::AcceptHeader = {'Accept' => 'text/turtle, application/n3, application/rdf+n3, application/turtle, application/x-turtle,text/n3,text/turtle, text/rdf+n3, text/rdf+turtle,application/json+ld, text/xhtml+xml,application/rdf+xml,application/n-triples' }

    Utils::TEXT_FORMATS = {
        'text' => ['text/plain',],
    }

    Utils::RDF_FORMATS = {
      'jsonld'  => ['application/ld+json'],
      'turtle'  => ['text/turtle','application/n3','application/rdf+n3',
                   'application/turtle', 'application/x-turtle','text/n3','text/turtle',
                   'text/rdf+n3', 'text/rdf+turtle'],
      'rdfa'    => ['text/xhtml+xml', 'application/xhtml+xml'],
      'rdfxml'  => ['application/rdf+xml'],
      'triples' => ['application/n-triples',]
    }

    Utils::XML_FORMATS = {
      'xml' => ['text/xhtml','text/xml',]
    }
    
    Utils::HTML_FORMATS = {
      'html' => ['text/html',]
    }
    
    Utils::JSON_FORMATS = {
				'json' => ['application/json',]
    }

    
    Utils::DATA_PREDICATES = [
        'http://xmlns.com/foaf/0.1/primaryTopic',
        'http://schema.org/about', # inverse 'http://schema.org/subjectOf',
        'http://schema.org/mainEntity',
        'http://schema.org/codeRepository',
        'http://www.w3.org/ns/dcat#distribution',
        'http://schema.org/distribution',
        'http://semanticscience.org/resource/SIO_000332', # is about
        'http://purl.obolibrary.org/obo/IAO_0000136', # is about
        ]
        
                       
                       
                       
    
    def Utils::resolveit(guid)
      inchi = Regexp.new(/^\w{14}\-\w{10}\-\w$/)
      doi = Regexp.new(/^10.\d{4,9}\/[-._;()\/:A-Z0-9]+$/i)
      handle = Regexp.new(/^[2-9]0.\d{4,9}\/[-._;()\/:A-Z0-9]+$/i)
      uri = Regexp.new(/^\w+:\/?\/?[^\s]+$/)

      meta = MetadataObject.new()
      case 
        when guid.match(inchi)
          metadata = Utils::resolve_inchi(guid, meta)
          return metadata
        when guid.match(doi)
          metadata = Utils::resolve_doi(guid, meta)
          return metadata
        when guid.match(handle)
           metadata = Utils::resolve_handle(guid, meta)
           return metadata
        when guid.match(uri)
          metadata = Utils::resolve_uri(guid, meta)
          return metadata
        else
          meta.comments << "the guid did not correspond to any known GUID.  Aborting.  "
          return meta
      end
    end
    
    
    
    def Utils::resolve_inchi(guid, meta)
      meta.guidtype = "inchi"
      
      meta.comments << "Found an InChI Key GUID.  "
      response1 = self.fetch("https://pubchem.ncbi.nlm.nih.gov/rest/rdf/inchikey/#{guid}", nil, meta)
      # this is a Net::HTTP response
      ##$stderr.puts step1.body
      return meta unless response1
      
      meta.full_response << response1 # set it here so it isn't empty
      
      (parser, type) = Utils::figure_out_type(response1)
      unless parser
        meta.comments << "couldn't find a parser for the data returned from https://pubchem.ncbi.nlm.nih.gov/rest/rdf/inchikey/#{guid}"
        return meta
      end

      # this next operation is safe because we know that pubchem does in fact return Turtle
      unless parser.eql?"turtle"
        meta.comments << "expected turtle format...  aborting"
        return meta   # simply fail if they asked for HTML or something else
      end
      
      Utils::parse_rdf(meta, response1) 
        
      query = SPARQL.parse("select ?o where {?s <http://semanticscience.org/resource/is-attribute-of> ?o}")
      results = query.execute(meta.graph)
      unless results.any?
        meta.comments << "could not find the sio:is_attribute_of predicate in the first layer of metadata.  Aborting with failure.  "
        return meta
      end
      
      cpd = results.first[:o]
      cpd = cpd.to_s
      cpd = cpd.gsub(/\/$/, "")
      response2 = fetch(cpd)
      return meta unless response2
      
      meta.full_response << response2  # set it here so it isn't empty
      (parser, type) = Utils::figure_out_type(response2)
      # this next operation is safe because we know that pubchem does in fact return Turtle
      unless parser.eql?"turtle"
        meta.comments << "expected turtle format... from #{cpd} aborting"
        return meta   # simply fail if they asked for HTML or something else
      end
      Utils::parse_rdf(meta, response2)
      
      return meta
    end
    
    
    
    def Utils::resolve_doi(guid, meta)
      meta.guidtype = "doi"
      meta.comments << "Found a Crossref DOI.  "

      Utils::resolve_uri("https://doi.org/#{guid}", meta, false)  # specifically metadata
      Utils::resolve_uri("https://doi.org/#{guid}", meta, false, {"Accept" => "*/*"}) # whatever is default
      
      return meta      
    end
    
    
    
    
    def Utils::resolve_handle(guid, meta)
      
      meta.guidtype = "handle"
      meta.comments << "Found a non-crossref DOI or other Handle.  "
      Utils::resolve_uri("http://hdl.handle.net/#{guid}", meta)
      return meta

    end
      
    
    
    def Utils::resolve_uri(guid, meta, nolinkheaders=false, header=Utils::AcceptHeader)
      meta.guidtype = "uri" if meta.guidtype == "unknown"  # might have been set already, e.g. to 'handle' or 'doi'
      #$stderr.puts "\n\n FETCHING #{guid} #{header}\n\n"
      response =  Utils::fetch(guid, header, meta)
      if !response
          response =  Utils::fetch(guid, {'Accept' => "*.*"}, meta)
      end
      if !response
          return meta
      end
                                       
      meta.full_response << response

      #$stderr.puts response.header

      links = Array.new
      links = Utils::parse_link_meta_headers(response) unless nolinkheaders
      links.each {|link| Utils::resolve_uri(link, meta, true)}  # this fills the metadata object with the content from Link headers, but not recursively
      
      (parser, contenttype) = Utils::figure_out_type(response)
      
      meta.comments << "Found #{parser} #{contenttype} type of file by resolving GUID.  "
      #$stderr.puts "\n\nFound #{parser} type of file by resolving GUID #{guid}.  BODY:  #{response.body}  \n\n"
        
        case
        when Utils::TEXT_FORMATS.keys.include?(parser)
          #$stderr.puts "\n\nPARSING TEXT\n\n"
          Utils::parse_text(meta, response)
        when Utils::RDF_FORMATS.keys.include?(parser)
          #$stderr.puts "\n\nPARSING RDF\n\n"
          Utils::parse_rdf(meta, response)
        when Utils::HTML_FORMATS.keys.include?(parser)
          #$stderr.puts "\n\nPARSING HTML\n\n"
          Utils::do_extruct(meta, guid)
        when Utils::XML_FORMATS.keys.include?(parser)
          #$stderr.puts "\n\nPARSING XML\n\n"
          Utils::parse_xml(meta, response)
        when Utils::JSON_FORMATS.keys.include?(parser)
          #$stderr.puts "\n\nPARSING JSON\n\n"
          Utils::parse_json(meta, response)
        else
          #$stderr.puts "\n\nPARSING UNKNOWN\n\n"
          meta.comments << "Metadata may be embedded, now searching using the Apache 'tika' tool.  "
          Utils::do_tika(meta, response)  # this expects a string, not an Net::HTTP
          meta.comments << "Metadata may be embedded, now searching using the 'Distiller' tool.  "
	  Utils::do_distiller(meta, guid)
          meta.comments << "Metadata may be embedded, now searching using the 'extruct' tool.  "
          Utils::do_extruct(meta, guid)
        end
        
        #curl -X GET http://localhost:9998/tika
        #curl -T polyA http://localhost:9998/meta --header "Accept: application/rdf+xml" --header "Content-Type: application/xhtml+xml"
  
      return meta

    end
    
    
    # ==================================================================
    # ==================================================================
    # ==================================================================
    # ==================================================================
    # ==================================================================
    
    def Utils::parse_text(meta, message)
        meta.comments << "Plain Text cannot be mapped to any parser.  No structured metadata found.  "
        meta.comments << "using Apache Tika to attempt to extract metadata. "
        
        return Utils::do_tika(meta, message)
    
        
    end
    
    def Utils::parse_json(meta,message)
      hash = JSON.parse(message.body)
      meta.hash.merge hash
      return meta.hash
    end
      
    
    def Utils::parse_html(meta, message)
       # just use extruct instead
    end
    
    
    
    def Utils::parse_rdf(meta, message, format=nil)
      #$stderr.puts "\n\nrequested format #{format}\n\n"
      contenttype = ""
      body = "" # to hold the raw rdf
      #$stderr.puts "MESSAGE CLASS #{message} #{message.class}\n\n\n"
      if message.class <= Net::HTTPResponse  # should probably do duck typing here... more Rubyish!
        if (message.header['content-type'].match(/([\w\+]+\/[\w\+]+):?/im))
          contenttype = $1
          body = message.body
          #$stderr.puts "MESSAGE BODY #{body}\n\n\n"
        else
          #$stderr.puts "Message was an http response with no type???\n\n\n"
          meta.comments << "no content-type header could be found in the message.  This is very odd!  Likely a bug in our software.  "
        end
      else # this is just an incoming string... in which case, it MUST have a format indicator (MIME type)
          #$stderr.puts "\n\nINCOMING STRING\n\n*#{message}*\n\n"
        contenttype = format
        if !contenttype
          meta.comments << "no content-type was passed with a raw RDF body.  This is very odd!  Likely a bug in our software (i.e. not your fault!)  Please tell the dev team.  "
          return meta
        end
        body = message # this is raw rdf
      end

      #$stderr.puts "\n\n\nSampling \n\n#{body}\n\n"
      unless body.match(/\w/)
          #$stderr.puts "\n\n\nSampling FOUND NOTHING!\n\n"
          meta.comments << "This #{contenttype} component appears to have no content.  "
          return meta
      end

      formattype = RDF::Format.for(content_type: contenttype)
      formattype ||= RDF::Format.for({:sample => body})
      $stderr.puts "\n\n\nTrying to create RDF reader for #{formattype}\n\n#{body}\n\n#{message}\n"

      if !formattype
        meta.comments << "We were unable to find an RDF reader type that matches the content that was returned.  Please send your GUID to the dev team so we can investigate!  "
        return meta
      end
      reader = formattype.reader.new(body)
      $stderr.puts "Reader Class #{reader.class}\n\n #{reader.inspect}"
      meta.merge_rdf(reader.to_a)
    end
    
    
    
    
    def Utils::parse_xml(meta, message)
      hash = XmlSimple.xml_in(message.body)
      meta.hash.merge hash
      return meta.hash
    end
    
    

    
    def Utils::do_tika(meta, message)
        file = Tempfile.new('foo')
        file.binmode
        file.write(message.body)
        file.rewind
        
        result = %x{curl --silent -T #{file.path} http://localhost:9998/meta --header "Accept: application/rdf+xml" 2>&1}
        file.close
        file.unlink    # deletes the temp file

        return Utils::parse_tika_output(meta, result)
    end
    
    
     def Utils::do_distiller(meta, uri)
        meta.comments << "Using 'Kellog's Distiller' to try to extract metadata from return value (message body) of #{uri}.  "
        
        result = Utils::fetch("http://rdf.greggkellogg.net/distiller?command=serialize&url=#{uri}&raw")
        $stderr.puts "\n\n\n\n\n\n\nDistiller:\n#{result.class}\n\n#{result.to_s}\n\n #{uri} 2>&1\n\n"
        # need to do some error checking here!
	if !result
          meta.comments << "The Distiller tool failed to find parseable data at #{uri}.  "
	
	else          
          Utils::parse_rdf(meta, result.body, "application/n-triples")
          meta.comments << "The Distiller found parseable data at #{uri}.  "
        end
 
    end

    def Utils::do_extruct(meta, uri)
      
        meta.comments << "Using 'extruct' to try to extract metadata from return value (message body) of #{uri}.  "
        
        result = %x{#{Utils::ExtructCommand} #{uri} 2>&1}
        $stderr.puts "\n\n\n\n\n\n\n#{result.class}\n\n#{result.to_s}\n\n#{@extruct_command} #{uri} 2>&1\n\n"
        # need to do some error checking here!
        if result.to_s.match(/^\s+?\{/) or result.to_s.match(/^\s+\[/) # this is JSON
          json = JSON.parse result
          #$stderr.puts "\n\n\n\nFOUND JSON\n\n\n"
          #$stderr.puts "\n\n\n\nFOUND JSON-LD\n#{json["json-ld"]} content\n\n\n"
          
          Utils::parse_rdf(meta, json["json-ld"].to_json, "application/ld+json") if json["json-ld"].any?  #RDF
          meta.merge_hash(json["microdata"].first) if json["microdata"].any?
          meta.merge_hash(json["microformat"].first) if json["microformat"].any?
          meta.merge_hash(json["opengraph"].first) if json["opengraph"].any?
          Utils::parse_rdf(meta, json["rdfa"].to_json, "application/ld+json") if json["rdfa"].any?  # RDF
                  
          meta.merge_hash(json.first) if json.first.is_a?Hash
        else
          meta.comments << "the extruct tool failed to find parseable data at #{uri}"
        end
 
    end
    
    def Utils::parse_tika_output(meta, output)
      #$stderr.puts "\n\n\n\n\nTIKA OUTPUT\n\nX#{output}X\n\n\n\n\n"
      # annoyingly, when you ask Tika for rdfxml, it gives it to you INSIDE an XML element
      # meaning that you cannot directly parse it as RDF.   Grrrrrrr....
      
      return unless output[0] == "<"  # check if it is XML
      xml = Nokogiri::XML(output)
      rdf = xml.xpath('//rdf:RDF', 'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')
      rdf_string = rdf.to_xml
      
      r = RDF::Format.for(content_type: "application/rdf+xml").reader.new(rdf_string)
      g = RDF::Graph.new << r
      meta.merge_rdf(g.statements)
      meta.comments << "Tika executed successfully (this doesn't necessarily mean that it discovered any metadata...)  "
    end
    

    
    def Utils::parse_link_meta_headers(message)
      # we can be sure that a Link header is a URL
      # code stolen from https://gist.github.com/thesowah/0ca5e1b4b3c61bfe8e13
      links = message.header['link']
      return [] unless links
      
      parts = links.split(',')

      links = Array.new
      # Parse each part into a named link
      parts.each do |part, index|
        section = part.split(';')
next unless section[0]
        url = section[0][/<(.*)>/,1]
next unless section[1]
        type = section[1][/rel="(.*)"/,1].to_sym
        next unless type == "meta"  # only keep meta headers
        links << url
      end
      return links
      
    end
    
    
    
    
    def Utils::deep_dive_values(myHash, value = nil, vals = Array.new)
      myHash.each_pair do |k,v|
        if v.is_a?(Hash)
          #$stderr.puts "key: #{k} recursing..."
          deep_dive_values(v, value, vals)
        else
          vals << v 
        end
      end
      return vals
    end

    def Utils::deep_dive_properties(myHash, property = nil, props = Array.new)
      return props unless myHash.is_a?(Hash)
      myHash.each_pair do |k,v|
        if property and property == k
          props << [k,v]
        else
          props << [k,v]
        end        
        if v.is_a?(Hash)
          #$stderr.puts "key: #{k} recursing..."
          deep_dive_properties(v, property, props)
        end
      end
      return props
    end

    

  def Utils::figure_out_type(message)
    type = message.header['content-type']
    type.match(/([\w\+]+\/[\w\+]+):?/im)
    type = $1
    #$stderr.puts "\n\nsearching for #{type}\n\n"
    
    Utils::RDF_FORMATS.each do |parser, types|
      return parser, type if types.include?type
    end
    Utils::JSON_FORMATS.each do |parser, types|
      return parser, type if types.include?type
    end
    Utils::TEXT_FORMATS.each do |parser, types|
      return parser, type if types.include?type
    end
    Utils::XML_FORMATS.each do |parser, types|
      return parser, type if types.include?type
    end
    Utils::HTML_FORMATS.each do |parser, types|
      return parser, type if types.include?type
    end
    return nil, nil
  end
    
    
  # general Web utilities... follow redirects, for example
  def Utils::fetch(uri_str, header=Utils::AcceptHeader, meta=nil)  #we will try to retrieve turtle whenever possible

    if Utils::isEncoded(uri_str)
        address = fullyDecodeURI(uri_str)
        address = URI::encode(uri_str)
    else
        address = uri_str
    end

    address = Utils::resolve(address, header)  # this runs through any redirects until there is a URL that will return data
    unless address
        if meta
            meta.comments << "the discovered URL does not resolve at all.  test halting.  "
        end
        return false
    end

    meta.finalURI = address if meta

      url = URI.parse(address)
      http = Net::HTTP.new(url.host, url.port)
      http.open_timeout = 120
      http.read_timeout = 120
      path = url.path
      path = '/' if path == ''
      path += '?' + url.query unless url.query.nil?

      params = { 'User-Agent' => 'curl/7.43.0' }.merge header
      request = Net::HTTP::Get.new(path, params)

      if url.instance_of?(URI::HTTPS)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      begin
          response = http.request(request)
      rescue
          return false
      end

    case response   # the \"case\" block allows you to test various conditions... it is like an \"if\", but cleaner!\n,
	  when Net::HTTPSuccess then  # when response Object is of type Net::HTTPSuccess\n",
	    # successful retrieval of web page\n",
	    return response  # return that response object to the main code\n",
	  else
	    #raise Exception, "Something went wrong... the call to #{uri_str} failed; type #{response.class}"
	    response = false
	    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    end
  end

  def Utils::head(uri)
    uri = Utils::resolve(uri)
    return false unless uri
    response=nil
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 90  # set to 90 seconds, because some servers, like the W3C, deeply object to my Accept headers!  LOL!

    if uri.match(/^https:/i)
      http.use_ssl = true                            # if using SSL
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE   # for example, when using self-signed certs
    end
    
    response = http.head(path)
    return response 
    # response.each { |key, value| puts key.ljust(40) + " : " + value }
    
  end


   # this returns the URI that results from all redirects, etc.
  def Utils::resolve(uri_str, header = Utils::AcceptHeader, timeout = 90, agent = 'curl/7.43.0', max_attempts = 10)
    begin
        resp = RestClient.head(uri_str, {"Accept" => header["Accept"], "User-Agent" => agent})
    rescue RestClient::ExceptionWithResponse => e
	$stderr.puts "Attempts to resolve the redirects for #{uri_str} failed with a #{e.response}.  Test halting  "
        return false
    end
    uri = resp.request.url
    return uri
  end
  
  def Utils::isEncoded(uri)
        uri = uri || '';
        if uri != URI.decode(uri)
           return true
        end
        return false
  end

  def Utils::fullyDecodeURI(uri)

          while (Utils::isEncoded(uri))
                uri = URI.decode(uri)
          end
        return uri;
  end
end   # END OF Utils CLASS






class Swagger   
  attr_accessor :debug
  attr_accessor :title  
  attr_accessor :tests_metric
  attr_accessor :description
  attr_accessor :applies_to_principle
  attr_accessor :organization
  attr_accessor :org_url
  attr_accessor :responsible_developer
  attr_accessor :email
  attr_accessor :developer_ORCiD
  attr_accessor :protocol
  attr_accessor :host
  attr_accessor :basePath
  attr_accessor :path
  attr_accessor :response_description
  attr_accessor :schemas
  attr_accessor :comments
  attr_accessor :fairsharing_key_location
  attr_accessor :score
  attr_accessor :testedGUID
    
  def initialize(params = {})
  	@debug = params.fetch(:debug, false)
	
    @title = params.fetch(:title, 'unnamed')
    @tests_metric = params.fetch(:tests_metric)
    @description = params.fetch(:description, 'default_description')
    @applies_to_principle = params.fetch(:applies_to_principle, 'some principle')
    @organization = params.fetch(:organization, 'Some Organization')
    @org_url = params.fetch(:org_url)
    @responsible_develper = params.fetch(:responsible_developer, 'Some Person')
    @email = params.fetch(:email)
    @developer_ORCiD = params.fetch(:developer_ORCiD)
    @host = params.fetch(:host)
    @protocol = params.fetch(:protocol, "https")
    @basePath = params.fetch(:basePath)
    @path = params.fetch(:path)
    @response_description = params.fetch(:response_description)
    @schemas = params.fetch(:schemas, [])
    @comments = params.fetch(:comments, [])
    @fairsharing_key_location = params.fetch(:fairsharing_key_location)
  	@score = params.fetch(:score, 0)
  	@testedGUID = params.fetch(:testedGUID, "")
	

	
  end
  
	

  def fairsharing_key 
      key = File.readlines(self.fairsharing_key_location)
      key.strip!
      return key 
  end
  

	
  def getSwagger 
					  
message = <<"EOF_EOF"
swagger: '2.0'
info:
 version: '0.1'
 title: "#{@title}"
 x-tests_metric: '#{@tests_metric}'
 description: >-
   #{@description}
 x-applies_to_principle: "#{@applies_to_principle}"
 contact:
  x-organization: "#{@organization}"
  url: "#{@org_url}"
  name: '#{@responsible_develper}'
  x-role: "responsible developer"
  email: #{@email}
  x-id: '#{developer_ORCiD}'
host: #{@host}
basePath: #{@basePath}
schemes:
  - #{@protocol}
paths:
 #{@path}:
  post:
   parameters:
    - name: content
      in: body
      required: true
      schema:
        $ref: '#/definitions/schemas'
   consumes:
     - application/json
   produces:  
     - application/json
   responses:
     200:
       description: >-
        #{@response_description}
definitions:
  schemas:
    required:
EOF_EOF
	

	
	self.schemas.keys.each do |key|
	  message += "     - #{key}\n"
	end
	message += "    properties:\n"
	self.schemas.keys.each do |key|
		  message += "        #{key}:\n"
		  message += "          type: #{self.schemas[key][0]}\n"
		  message += "          description: >-\n"
		  message += "            #{self.schemas[key][1]}\n"   
	end
		  
	return message
  end
  
  
    
    # A utility function that SHOULD NOT BE CALLED EXTERNALLY
    #
    # @param s - subject node
    # @param p - predicate node
    # @param o - object node
    # @param repo - an RDF::Graph object
    def triplify(s, p, o, repo)
  
      if s.class == String
              s = s.strip
      end
      if p.class == String
              p = p.strip
      end
      if o.class == String
              o = o.strip
      end
      
      unless s.respond_to?('uri')
        
        if s.to_s =~ /^\w+:\/?\/?[^\s]+/
                s = RDF::URI.new(s.to_s)
        else
          self.debug and $stderr.puts "Subject #{s.to_s} must be a URI-compatible thingy"
          abort "Subject #{s.to_s} must be a URI-compatible thingy"
        end
      end
      
      unless p.respond_to?('uri')
    
        if p.to_s =~ /^\w+:\/?\/?[^\s]+/
                p = RDF::URI.new(p.to_s)
        else
          self.debug and $stderr.puts "Predicate #{p.to_s} must be a URI-compatible thingy"
          abort "Predicate #{p.to_s} must be a URI-compatible thingy"
        end
      end
  
      unless o.respond_to?('uri')
        self.debug and $stderr.puts "|#{o}| #{o.class}"
        if o.to_s =~ /^\w+:\/?\/?[^\s]+/
                o = RDF::URI.new(o.to_s)
        elsif o.to_s =~ /^\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d/
                o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.date)
        elsif o.to_s =~ /^\d\.\d/
        self.debug and $stderr.puts "\n\n\n\nFOUND FLOAT\n\n\n\n"
                o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.float)
        elsif o.to_s =~ /^[0-9]+$/
                o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.int)
        else
                o = RDF::Literal.new(o.to_s, :language => :en)
        end
      end
  
      self.debug and $stderr.puts("\n\ninserting #{s.to_s} #{p.to_s} #{o.to_s}\n\n")
      triple = RDF::Statement(s, p, o) 
      repo.insert(triple)
  
      return true
    end
    
  
    # A utility function that SHOULD NOT BE CALLED EXTERNALLY
    #
    # @param s - subject node
    # @param p - predicate node
    # @param o - object node
    # @param repo - an RDF::Graph object
    def Swagger.triplify(s, p, o, repo)
      return triplify(s,p,o,repo)
    end
    
	def addComment(newcomment)		  
		  self.comments << newcomment.to_s
		  #return self.comments
	end

  def createEvaluationResponse
    
    g = RDF::Graph.new

    dt = Time.now.iso8601
    uri = self.testedGUID

    me = self.protocol + "://" + self.host + "/" + self.basePath + self.path
    
    meURI  ="#{me}##{URI.encode(uri)}/result-#{URI.encode(dt)}"

    triplify(meURI, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://fairmetrics.org/resources/metric_evaluation_result", g );
    triplify(meURI, "http://semanticscience.org/resource/SIO_000300", self.score, g )
    triplify(meURI, "http://purl.obolibrary.org/obo/date", dt, g )
    triplify(meURI,"http://semanticscience.org/resource/SIO_000332", uri, g)
    
    comments = "no comments received.  "
    
    comments = self.comments.join("\n") if self.comments.size > 0 
    triplify(meURI, "http://schema.org/comment", comments, g)
    
    return g.dump(:jsonld)
  end	
	
end



# =======================================================================
# =======================================================================
# =======================================================================
# =======================================================================
# =======================================================================
# =======================================================================
# =======================================================================




class MetadataObject
    
  attr_accessor :hash  # a hash of metadata
  attr_accessor :graph  # a RDF.rb graph of metadata
  attr_accessor :comments  # an array of comments
  attr_accessor :guidtype  # the type of GUID that was detected
  attr_accessor :full_response  # will be an array of Net::HTTP::Response
  attr_accessor :finalURI  
  def initialize(params = {}) # get a name from the "new" call, or set a default
      
    @hash = Hash.new
    @graph = RDF::Graph.new
    @comments = Array.new
    @guidtype = "unknown"
    @full_response = Array.new
    @finalURI = "http://example.org"
  end
  
  def merge_hash(hash)
      $stderr.puts "\n\n\nIncoming Hash #{hash.inspect}"
      self.hash = self.hash.merge(hash)
  end
  
  def merge_rdf(triples)  # incoming list of triples
    self.graph << triples
    return self.graph
  end

  def rdf
    return self.graph
  end
  
end

