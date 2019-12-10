require 'json'
require 'rdf'
require 'rdf/json'
require 'json/ld'
require 'rdf/trig'
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
require 'cgi'
require 'digest'


class Utils
    config = ParseConfig.new('config.conf')
    
    @extruct_command = "extruct" unless config
    @extruct_command = config['extruct']['command'] if config['extruct'] && config['extruct']['command'] && !config['extruct']['command'].empty?
    #$stderr.puts "EXTRUCT #{@extruct_command}\n\n"
    Utils::ExtructCommand = @extruct_command

    @rdf_command = "rdf" unless config
    @rdf_command = config['rdf']['command'] if config['rdf'] && config['rdf']['command'] && !config['rdf']['command'].empty?
    Utils::RDFCommand = @rdf_command

    Utils::AcceptHeader = {'Accept' => 'text/turtle, application/ld+json, application/rdf+xml, text/xhtml+xml, application/n3, application/rdf+n3, application/turtle, application/x-turtle, text/n3, text/turtle, text/rdf+n3, text/rdf+turtle, application/n-triples' }

    Utils::TEXT_FORMATS = {
        'text' => ['text/plain',],
    }

    Utils::RDF_FORMATS = {
      'jsonld'  => ['application/ld+json'],
      'turtle'  => ['text/turtle','application/n3','application/rdf+n3',
                   'application/turtle', 'application/x-turtle','text/n3','text/turtle',
                   'text/rdf+n3', 'text/rdf+turtle'],
      #'rdfa'    => ['text/xhtml+xml', 'application/xhtml+xml'],
      'rdfxml'  => ['application/rdf+xml'],
      'triples' => ['application/n-triples','application/n-quads', 'application/trig']
    }

    Utils::XML_FORMATS = {
      'xml' => ['text/xhtml','text/xml',]
    }
    
    Utils::HTML_FORMATS = {
      'html' => ['text/html','text/xhtml+xml', 'application/xhtml+xml']
    }
    
    Utils::JSON_FORMATS = {
				'json' => ['application/json',]
    }

    
    Utils::DATA_PREDICATES = [
        'http://www.w3.org/ns/ldp#contains',
        'http://xmlns.com/foaf/0.1/primaryTopic',
        # 'http://schema.org/about', # removed for being too general
        'http://schema.org/mainEntity',
        'http://schema.org/codeRepository',
        'http://www.w3.org/ns/dcat#distribution',
        'http://schema.org/distribution',
        'http://semanticscience.org/resource/SIO_000332', # is about
        'http://semanticscience.org/resource/is-about', # is about
        'http://purl.obolibrary.org/obo/IAO_0000136', # is about
        'http://purl.obolibrary.org/obo/IAO:0000136', # is about (not the valid URL...)
        'https://www.w3.org/ns/ldp#contains',
        'https://xmlns.com/foaf/0.1/primaryTopic',
        # 'https://schema.org/about', #removed for being too general
        'https://schema.org/mainEntity',
        'https://schema.org/codeRepository',
        'https://www.w3.org/ns/dcat#distribution',
        'https://schema.org/distribution',
        'https://semanticscience.org/resource/SIO_000332', # is about
        'https://semanticscience.org/resource/is-about', # is about
        'https://purl.obolibrary.org/obo/IAO_0000136', # is about
        ]

    Utils::SELF_IDENTIFIER_PREDICATES = [
        'http://purl.org/dc/terms/identifier',
        'http://schema.org/identifier',
        ]

    Utils::GUID_TYPES = {'inchi' => Regexp.new(/^\w{14}\-\w{10}\-\w$/),
                        'doi' => Regexp.new(/^10.\d{4,9}\/[-._;()\/:A-Z0-9]+$/i),
                        'handle1' => Regexp.new(/^[^\/]+\/[^\/]+$/i),
                        'handle2' => Regexp.new(/^\d{4,5}\/[-._;()\/:A-Z0-9]+$/i), # legacy style  12345/AGB47A
                        'uri' => Regexp.new(/^\w+:\/?\/?[^\s]+$/)
    }
        
    @@distillerknown = {}  # global, hash of sha256 keys of message bodies - have they been seen before t/f








    def Utils::resolveit(guid)

      meta = MetadataObject.new()
      
      Utils::GUID_TYPES.each do |pair|
          k,regex = pair
          if k == "inchi" and regex.match(guid)
            metadata = Utils::resolve_inchi(guid, meta)
            return metadata
          elsif k == "handle1" and regex.match(guid)
            metadata = Utils::resolve_handle(guid, meta)
            return metadata
          elsif k == "handle2" and regex.match(guid)
            metadata = Utils::resolve_handle(guid, meta)
            return metadata
          elsif k == "uri" and regex.match(guid)
            metadata = Utils::resolve_uri(guid, meta)
            return metadata
          elsif k == "doi" and regex.match(guid)
            metadata = Utils::resolve_doi(guid, meta)
            return metadata
          end
      end
      meta.comments << "CRITICAL: The guid did not correspond to any known GUID. Tested #{Utils::GUID_TYPES.keys.to_s}. Halting.\n"
      return meta
      
    end
                       
                       
    
    def Utils::typeit(guid)
      Utils::GUID_TYPES.each do |pair|
          type,regex = pair
          if regex.match(guid)
            return type
          end
      end
      return false
    end
    
    
    
    def Utils::resolve_inchi(guid, meta)
      meta.guidtype = "inchi"
      
      meta.comments << "INFO: Found an InChI Key GUID.\n"
#$stderr.puts "1"
      meta.comments << "INFO: Resolving using PubChem Resolver https://pubchem.ncbi.nlm.nih.gov/rest/rdf/inchikey/#{guid} with HTTP Accept Headers #{Utils::AcceptHeader.to_s}.\n"

      head, body = self.fetch("https://pubchem.ncbi.nlm.nih.gov/rest/rdf/inchikey/#{guid}", Utils::AcceptHeader, meta)
      # this is a Net::HTTP response
#$stderr.puts "2"

      return meta unless body
#$stderr.puts "3"
      
      meta.full_response << body # set it here so it isn't empty
#$stderr.puts "4"
      
      (parser, type) = Utils::figure_out_type(head)
      unless parser
        meta.comments << "CRITICAL: Couldn't find a parser for the data returned from https://pubchem.ncbi.nlm.nih.gov/rest/rdf/inchikey/#{guid}. Halting. \n"
        return meta
      end
#$stderr.puts "5"

      # this next operation is safe because we know that pubchem does in fact return Turtle
      unless parser.eql?"turtle"
        meta.comments << "CRITICAL: expected turtle format from https://pubchem.ncbi.nlm.nih.gov/rest/rdf/inchikey/#{guid}. Halting. \n"
        return meta   
      end
#$stderr.puts "6"
      
      Utils::parse_rdf(meta, body) 
        
      query = SPARQL.parse("select ?o where {?s <http://semanticscience.org/resource/is-attribute-of> ?o}")
      results = query.execute(meta.graph)
      unless results.any?
        meta.comments << "CRITICAL: Could not find the sio:is_attribute_of predicate in the first layer of metadatafrom https://pubchem.ncbi.nlm.nih.gov/rest/rdf/inchikey/#{guid}. Halting. \n"
        return meta
      end
#$stderr.puts "7"
      
      cpd = results.first[:o]
      cpd = cpd.to_s
      cpd = cpd.gsub(/\/$/, "")  # has a rogue trailing slash
      meta.comments << "INFO: Found #{cpd} as the identifier of the second layer of metadata.\n"
      meta.comments << "INFO: Resolving #{cpd} using HTTP Accept Header #{Utils::AcceptHeader.to_s}.\n"
        
      head2, body2 = self.fetch(cpd, Utils::AcceptHeader, meta)
      unless body2
        meta.comments << "CRITICAL: Resolution of #{cpd} using HTTP Accept Header #{Utils::AcceptHeader.to_s} returned no message body. Halting. \n"
        return meta
      end
#$stderr.puts "8"
      
      meta.full_response << body2  # set it here so it isn't empty
      (parser, type) = Utils::figure_out_type(head2)
      # this next operation is safe because we know that pubchem does in fact return Turtle
      unless parser.eql?"turtle"
        meta.comments << "CRITICAL: Expected turtle format from #{cpd}.  Halting. \n"
        return meta   # simply fail if they asked for HTML or something else
      end
#$stderr.puts "9"
      Utils::parse_rdf(meta, body2)
#$stderr.puts "10"
      
      return meta
    end
    
    
    
    def Utils::resolve_doi(guid, meta)
      meta.guidtype = "doi"
      meta.comments << "INFO:  Found a DOI.\n"

      meta.comments << "INFO:  Attempting to resolve https://doi.org/#{guid} using HTTP Headers #{Utils::AcceptHeader.to_s}.\n"
      Utils::resolve_url("https://doi.org/#{guid}", meta, false)  # specifically metadata
      meta.comments << "INFO:  Attempting to resolve https://doi.org/#{guid} using HTTP Headers #{{"Accept" => "*/*"}.to_s}.\n"
      Utils::resolve_url("https://doi.org/#{guid}", meta, false, {"Accept" => "*/*"}) # whatever is default

        # CrossRef and DataCite both "intercept" the normal redirect process, when a URI has a content-type
        # Accept header that they understand.  This prevents the owner of the data from providing their own
        # metadata of that type, when using the DOI as their GUID.  Here
        # we have let the redirect process go all the way to the final URL, and we then
        # treat that as a new GUID.
      finalURI = meta.finalURI
      if finalURI =~ /\w+\:\/\//
        meta.comments << "INFO:  DOI resolution captures content-negotiation before reaching final data owner.  Now re-attempting the full suite of content negotiation on final redirect URI #{finalURI}.\n"
        Utils::resolve_uri(finalURI, meta) 
      end
      
      return meta      
    end
    
    
    
    
    def Utils::resolve_handle(guid, meta)
      
      meta.guidtype = "handle"
      meta.comments << "INFO: Found a non-DOI Handle.\n"
      meta.comments << "INFO:  Attempting to resolve http://hdl.handle.net/#{guid} using HTTP Headers #{Utils::AcceptHeader.to_s}.\n"
      Utils::resolve_uri("http://hdl.handle.net/#{guid}", meta)
#      meta.comments << "INFO:  Attempting to resolve http://hdl.handle.net/#{guid} using HTTP Headers #{{"Accept" => "*/*"}.to_s}.\n"
#      Utils::resolve_url("http://hdl.handle.net/#{guid}", meta, false, {"Accept" => "*/*"})
      return meta

    end
      
    def Utils::resolve_uri(guid, meta)
      
      meta.guidtype = "uri"
      meta.comments << "INFO: Found a URI.\n"
      meta.comments << "INFO:  Attempting to resolve #{guid} using HTTP Headers #{Utils::AcceptHeader.to_s}.\n"
      Utils::resolve_url(guid, meta, false)
      meta.comments << "INFO:  Attempting to resolve #{guid} using HTTP Headers #{Utils::XML_FORMATS['xml'].join(",")}.\n"
      Utils::resolve_url(guid, meta, false, {"Accept" => "#{Utils::XML_FORMATS['xml'].join(",")}"})
      meta.comments << "INFO:  Attempting to resolve #{guid} using HTTP Headers #{Utils::JSON_FORMATS['json'].join(",")}.\n"
      Utils::resolve_url(guid, meta, false, {"Accept" => "#{Utils::JSON_FORMATS['json'].join(",")}"})
      meta.comments << "INFO:  Attempting to resolve #{guid} using HTTP Headers 'Accept: */*'.\n"
      Utils::resolve_url(guid, meta, false, {"Accept" => "*/*"})
      return meta

    end
    
    
    def Utils::resolve_url(guid, meta, nolinkheaders=false, header=Utils::AcceptHeader)
      meta.guidtype = "uri" if meta.guidtype == "unknown"  # might have been set already, e.g. to 'handle' or 'doi'
      $stderr.puts "\n\n FETCHING #{guid} #{header}\n\n"
      head, body = Utils::fetch(guid, header, meta)
      if !head
          meta.comments << "WARN: Unable to resolve #{guid} using HTTP Accept header #{header.to_s}.\n"
          return meta
      end
      
      meta.comments << "INFO: following redirection using this header led to the following URL: #{meta.finalURI.last}.  Using the output from this URL for the next few tests..."
      meta.full_response << body

      links = Array.new
      links = Utils::parse_link_meta_headers(head) unless nolinkheaders
      links.each do |link|
          meta.comments << "INFO: a Link 'meta' header was found: #{link}, and is now being followed as an independent URI that may contain metadata.\n"
          Utils::resolve_url(link, meta, true)
      end  # this fills the metadata object with the content from Link headers, but not recursively
      
      parser, contenttype = Utils::figure_out_type(head)
      
      meta.comments << "INFO: Found #{parser} #{contenttype} type of content when resolving #{guid} using HTTP Accept header #{header.to_s}.\n"
      #$stderr.puts "\n\nFound #{parser} type of file by resolving GUID #{guid}.  BODY:  #{response.body}  \n\n"
        
        case
        when Utils::TEXT_FORMATS.keys.include?(parser)
          $stderr.puts "\n\nPARSING TEXT\n\n"
          meta.comments << "INFO: parsing as plaintext. \n"
          Utils::parse_text(meta, body)
        when Utils::RDF_FORMATS.keys.include?(parser)
          $stderr.puts "\n\nPARSING RDF\n\n"
          meta.comments << "INFO: parsing as linked data. \n"
          if contenttype == 'application/trig'
            Utils::parse_rdf(meta, body, contenttype)
          else
            Utils::parse_rdf(meta, body)
          end
        when Utils::HTML_FORMATS.keys.include?(parser)
          meta.comments << "INFO: parsing as HTML. \n"
          $stderr.puts "\n\nPARSING HTML\n\n"
          url = ""
          if meta.finalURI.last =~ /^\w+\:\/\//
              url = meta.finalURI.last
          else
              url = guid
          end
          Utils::do_extruct(meta, url ) 
    	  Utils::do_distiller(meta, body)
        when Utils::XML_FORMATS.keys.include?(parser)
          meta.comments << "INFO: parsing as XML. \n"
          $stderr.puts "\n\nPARSING XML\n\n"
          Utils::parse_xml(meta, body)
        when Utils::JSON_FORMATS.keys.include?(parser)
          meta.comments << "INFO: parsing as JSON. \n"
          $stderr.puts "\n\nPARSING JSON\n\n"
          Utils::parse_json(meta, body)
        else
          $stderr.puts "\n\nPARSING UNKNOWN\n\n"
          url = ""
          if meta.finalURI.last =~ /^\w+\:\/\//
              url = meta.finalURI.last
          else
              url = guid
          end
          meta.comments << "WARN: parser could not be found. \n"
          meta.comments << "INFO:  Metadata may be embedded, now searching using the Apache 'tika' tool.\n"
          Utils::do_tika(meta, body)  # this expects a string, not an Net::HTTP
          meta.comments << "INFO:  Metadata may be embedded, now searching using the 'Distiller' tool.\n"
    	  Utils::do_distiller(meta, body)
          meta.comments << "INFO: Metadata may be embedded, now searching using the 'extruct' tool.\n"
          Utils::do_extruct(meta, url)
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
    
    def Utils::parse_text(meta, body)
        meta.comments << "WARTN: Plain Text cannot be mapped to any parser.  No structured metadata found.\n"
        meta.comments << "INFO: Using Apache Tika to attempt to extract metadata from plaintext.\n"
        
        return Utils::do_tika(meta, body)
    
        
    end
    
    def Utils::parse_json(meta,body)
      hash = JSON.parse(body)
      meta.hash.merge hash
      return meta.hash
    end
      
    
    def Utils::parse_html(meta, body)
       # just use extruct instead
    end
    
    
    
    def Utils::parse_rdf(meta, body, format=nil)

      #$stderr.puts "\n\n\nSampling \n\n#{body[0..2000]}\n\n"
      unless body
          meta.comments << "CRITICAL: The response message body component appears to have no content.\n"
          return meta
      end
      unless body.match(/\w/)
          meta.comments << "CRITICAL: The response message body component appears to have no content.\n"
          return meta
      end
      formattype = nil
      $stderr.puts "\n\n\ndeclared format #{format}\n\n"
      if !format.nil?
          $stderr.puts "\n\n\ntesting declared format #{format}\n\n"
          formattype = RDF::Format.for(content_type: format)
          $stderr.puts "\n\n\nfound format #{formattype}\n\n"
      else
          formattype = RDF::Format.for({:sample => body[0..3000]})
          $stderr.puts "\n\n\ndetected format #{formattype}\n\n"          
      end
      $stderr.puts "\n\n\nfinal format #{formattype}\n\n"          

      if !formattype
        meta.comments << "CRITICAL: Unable to find an RDF reader type that matches the content that was returned from resolution.  Here is a sample #{body[0..100]}  Please send your GUID to the dev team so we can investigate!\n"
        return meta
      end
      meta.comments << "INFO: The response message body component appears to contain #{formattype.to_s}.\n"
      reader = formattype.reader.new(body)
      #$stderr.puts "Reader Class #{reader.class}\n\n #{reader.inspect}"
      meta.merge_rdf(reader.to_a)

    end
    
    
    
    
    def Utils::parse_xml(meta, body)
      hash = XmlSimple.xml_in(body)
      meta.comments << "INFO: The XML is being converted into a simple hash structure.\n"
      meta.hash.merge hash
      return meta.hash
    end
    
    

    
    def Utils::do_tika(meta, body)
        file = Tempfile.new('foo')
        file.binmode
        file.write(body)
        file.rewind
        meta.comments << "INFO: The message body is being examined by Apache Tika\n"
        
        result = %x{curl --silent -T #{file.path} http://localhost:9998/meta --header "Accept: application/rdf+xml" 2>&1}
        file.close
        file.unlink    # deletes the temp file
        meta.comments << "INFO: The response from Apache Tika is being parsed\n"

        return Utils::parse_tika_output(meta, result)
    end
    
    
    def Utils::do_distiller(meta, body)

        bhash = Digest::SHA256.hexdigest(body)
        if @@distillerknown[bhash]
            meta.comments << "INFO: Cached data is already parsed.  Returning\n"
            return
        end
        @@distillerknown[bhash] = true


        
        
        meta.comments << "INFO: Using 'Kellog's Distiller' to try to extract metadata from return value (message body).\n"
#         $stderr.puts "BODY: \n\n #{body}"

        file = Tempfile.new('foo', :encoding => 'UTF-8')
        body = body.force_encoding('UTF-8')
        file.write(body)
        file.rewind
        meta.comments << "INFO: The message body is being examined by Distiller\n"
        result =  %x{LANG=en_US.UTF-8 #{Utils::RDFCommand} serialize --input-format rdfa --output-format turtle #{file.path} 2>/dev/null}
        #$stderr.puts "RESULT #{result}\n\n\n"
        file.close
        file.unlink

       
        result = result.force_encoding('UTF-8')        
        #head, body = Utils::simplefetch("http://rdf.greggkellogg.net/distiller?command=serialize&format=rdfa&url=#{urlparam}&output_format=turtle", {"Accept" => "*/*"}, meta)
        # need to do some error checking here!
        if !(result =~ /\w/)  # failure returns nil
            meta.comments << "WARN: The Distiller tool failed to find parseable data in the body.\n"
        else
            meta.comments << "INFO: The Distiller found parseable data.  Parsing as RDF\n"
            Utils::parse_rdf(meta, result, "text/turtle")
        end
 
    end


    def Utils::do_extruct(meta, uri)
      
        meta.comments << "INFO:  Using 'extruct' to try to extract metadata from return value (message body) of #{uri}.\n"
        
        result = %x{#{Utils::ExtructCommand} #{uri} 2>&1}
        #$stderr.puts "\n\n\n\n\n\n\n#{result.class}\n\n#{result.to_s}\n\n#{@extruct_command} #{uri} 2>&1\n\n"
        # need to do some error checking here!
        if result.to_s.match(/(Failed\sto\sextract.*?)\n/)
            meta.comments << "WARN: extruct threw an error #{$1} when attempting to parse return value (message body) of #{uri}.\n"
            if result.to_s.match(/(ValueError\:.*?)\n/)
                meta.comments << "WARN: extruct error was #{$1}\n"
            end
        elsif result.to_s.match(/^\s+?\{/) or result.to_s.match(/^\s+\[/) # this is JSON
          json = JSON.parse result
          #$stderr.puts "\n\n\n\nFOUND JSON\n\n\n"
          #$stderr.puts "\n\n\n\nFOUND JSON-LD\n#{json["json-ld"]} content\n\n\n"
          meta.comments << "INFO: the extruct tool found parseable data at #{uri}\n"
          
          Utils::parse_rdf(meta, json["json-ld"].to_json, "application/ld+json") if json["json-ld"].any?  #RDF
          meta.merge_hash(json["microdata"].first) if json["microdata"].any?
          meta.merge_hash(json["microformat"].first) if json["microformat"].any?
          meta.merge_hash(json["opengraph"].first) if json["opengraph"].any?
          Utils::parse_rdf(meta, json["rdfa"].to_json, "application/ld+json") if json["rdfa"].any?  # RDF
                  
          meta.merge_hash(json.first) if json.first.is_a?Hash
        else
          meta.comments << "WARN: the extruct tool failed to find parseable data at #{uri}\n"
        end
 
    end
    
    def Utils::parse_tika_output(meta, output)
      #$stderr.puts "\n\n\n\n\nTIKA OUTPUT\n\nX#{output}X\n\n\n\n\n"
      # annoyingly, when you ask Tika for rdfxml, it gives it to you INSIDE an XML element
      # meaning that you cannot directly parse it as RDF.   Grrrrrrr....
      meta.comments << "INFO:  entering Tika parser - sample of input #{output[0..50]}.\n"
      
      unless output[0] == "<"  # check if it is XML
          meta.comments << "CRITICAL:  Tika parser expected XML. Aborting. \n"
          return
      end
          
      xml = Nokogiri::XML(output)
      rdf = xml.xpath('//rdf:RDF', 'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')
      rdf_string = rdf.to_xml
      
      r = RDF::Format.for(content_type: "application/rdf+xml").reader.new(rdf_string)
      g = RDF::Graph.new << r
      meta.merge_rdf(g.statements)
      meta.comments << "INFO: Tika executed successfully (this doesn't necessarily mean that it discovered any metadata...)\n"
    end
    

    
    def Utils::parse_link_meta_headers(headers)
      # we can be sure that a Link header is a URL
      # code stolen from https://gist.github.com/thesowah/0ca5e1b4b3c61bfe8e13 with a few tweaks


      links = headers[:link]
      return [] unless links
      
      parts = links.split(',')

      links = Array.new
      # Parse each part into a named link
      parts.each do |part, index|
        section = part.split(';')
        next unless section[0]
        url = section[0][/<(.*)>/,1]
        next unless section[1]
        type = section[1][/rel="?(.*)"?/,1]
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

    

  def Utils::figure_out_type(head)
    type = head[:content_type]
    if type.nil?        
        $stderr.puts "\n\nSTRANGE - headers had no content-type\n\n"
        return nil,nil
    end
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
    
    
    
    
    
    
    
    

  def Utils::fetch(url, headers = Utils::AcceptHeader, meta=nil)  #we will try to retrieve turtle whenever possible

        head = Utils::head(url, headers)
        unless head  # returns false for a 404
            if meta
                meta.comments << "WARN: The URL: #{url} doesn't exist (returns 404 or other HTTP error)"
                return false
            end
        end
        #$stderr.puts "content length " + head[:content_length].to_s
        if head[:content_length] and head[:content_length].to_f > 300000 and meta
            meta.comments << "WARN: The size of the content at #{url} reports itself to be >300kb.  This service will not download something so large.  This does not mean that the content is not FAIR, only that this service will not test it.  Sorry!\n"
            return false
        end

        head, body, finalURI = Utils::checkCache(url, headers)
        if meta and finalURI
            meta.finalURI << finalURI
        end
        if head and body
            $stderr.puts "Retrieved from cache, returning data to code"
            return [head, body]
        end

		begin
			response = RestClient::Request.execute({
					method: :get,
					url: url.to_s,
					#user: user,
					#password: pass,
					headers: headers})
            if meta
    			meta.finalURI << response.request.url
            end
			Utils::writeToCache(url, headers, response.headers, response.body, response.request.url)
			return [response.headers, response.body]
		rescue RestClient::ExceptionWithResponse => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue RestClient::Exception => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue Exception => e
			$stderr.puts e
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		end		  # you can capture the Exception and do something useful with it!\n",


  end



  def Utils::simplefetch(url, headers = Utils::AcceptHeader, meta=nil)  #we will try to retrieve turtle whenever possible

        head = Utils::head(url, headers)
        #$stderr.puts "content length " + head[:content_length].to_s
        if head[:content_length] and head[:content_length].to_f > 300000 and meta
            meta.comments << "WARN: The size of the content at #{url} reports itself to be >300kb.  This service will not download something so large.  This does not mean that the content is not FAIR, only that this service will not test it.  Sorry!\n"
            return false
        end

		begin
			response = RestClient::Request.execute({
					method: :get,
					url: url.to_s,
					#user: user,
					#password: pass,
					headers: headers})
			return [response.headers, response.body]
		rescue RestClient::ExceptionWithResponse => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue RestClient::Exception => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue Exception => e
			$stderr.puts e
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		end		  # you can capture the Exception and do something useful with it!\n",


  end



   # this returns the URI that results from all redirects, etc.
  def Utils::head(url, headers = Utils::AcceptHeader)
		
		begin
			response = RestClient::Request.execute({
					method: :head,
					url: url.to_s,
					#user: user,
					#password: pass,
					headers: headers})
			return response.headers
		rescue RestClient::ExceptionWithResponse => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue RestClient::Exception => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue Exception => e
			$stderr.puts e
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		end		  # you can capture the Exception and do something useful with it!\n",

  end


   # this returns the URI that results from all redirects, etc.
  def Utils::resolve(url, headers = Utils::AcceptHeader)
		
		begin
			response = RestClient::Request.execute({
					method: :head,
					url: url.to_s,
					#user: user,
					#password: pass,
					headers: headers})
			return response.request.url
		rescue RestClient::ExceptionWithResponse => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue RestClient::Exception => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue Exception => e
			$stderr.puts e
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		end		  # you can capture the Exception and do something useful with it!\n",

  end
  
  
    def Utils::checkCache(uri, headers)
       filename = Digest::MD5.hexdigest uri + headers.to_s
    #$stderr.puts "Checking cache for #{filename}"
       if File.exist?("/tmp/#{filename}_head") and File.exist?("/tmp/#{filename}_body")
    #$stderr.puts "FOUND"
           head = Marshal.load(File.read("/tmp/#{filename}_head"))
           body = Marshal.load(File.read("/tmp/#{filename}_body"))
           finalURI = ""
           if File.exist?("/tmp/#{filename}_uri")
               finalURI = Marshal.load(File.read("/tmp/#{filename}_uri"))
           end
           return [head, body, finalURI]
       end
       
    end

    def Utils::writeToCache(uri, headers, head, body, finalURI)
        filename = Digest::MD5.hexdigest uri + headers.to_s
    #$stderr.puts "Writing cache for #{filename}"
        headfilename = filename + "_head"
        bodyfilename = filename + "_body"
        urifilename = filename + "_uri"
        File.open("/tmp/#{headfilename}", 'wb') { |f| f.write(Marshal.dump(head)) }
        File.open("/tmp/#{bodyfilename}", 'wb') { |f| f.write(Marshal.dump(body)) }
        File.open("/tmp/#{urifilename}", 'wb') { |f| f.write(Marshal.dump(finalURI)) }
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
    @version = params.fetch(:version, "0.1")
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
 version: '#{@version}'
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
     "200":
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
        if o.to_s =~ /^\w+:\/?\/?[^\s]+/
                o = RDF::URI.new(o.to_s)
        elsif o.to_s =~ /^\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d/
                o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.date)
        elsif o.to_s =~ /^[+-]?\d+\.\d+/
                o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.float)
        elsif o.to_s =~ /^[+-]?[0-9]+$/
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
    @finalURI = Array.new
  end
  
  def merge_hash(hash)
      #$stderr.puts "\n\n\nIncoming Hash #{hash.inspect}"
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




# ======================================================================================
# ======================================================================================
# ======================================================================================
# ======================================================================================
# ======================================================================================
# ======================================================================================
# ======================================================================================

class CommonQueries
    
    def CommonQueries::GetSelfIdentifier(g, swagger)
 
 		Utils::SELF_IDENTIFIER_PREDICATES.each do |prop|
   
			if prop =~ /schema\.org\/identifier/
                # test 1 - this assumes that the identifier node attached to "root" is the one we are looking for
                # and assumes the PropertyValue schema for the value of identifier
                query = SPARQL.parse("select * where {
                                    VALUES ?predi {<http://schema.org/identifier> <https://schema.org/identifier>}
                                    VALUES ?predpv {<http://schema.org/PropertyValue> <https://schema.org/PropertyValue>}
                                    VALUES ?predval {<http://schema.org/value> <https://schema.org/value>}
                                    ?s ?predi ?i .
                                    ?i a ?predpv .
                                    ?i ?predval ?identifier .
                                    FILTER NOT EXISTS {?sub ?pred ?s} }")
                results = query.execute(g)
                if  results.any?
                        @identifier=results.first[:identifier].value
                        swagger.addComment "INFO: found identifier #{@identifier} using Schema.org identifier as PropertyValue.\n"
                        return @identifier
                end
        
                # test 2 - a simple URL or a value from schema
                query = SPARQL.parse("select ?o where {?s <#{prop}> ?o}")
                results = query.execute(g)
                if  results.any?
                        @identifier=results.first[:o].value
                        swagger.addComment "INFO: found identifier #{@identifier} using Schema.org identifier property as a simple URL or string value.\n"
                        return @identifier
                end
            else
                query = SPARQL.parse("select ?o where {?s <#{prop}> ?o}")
				results = query.execute(g)
				if results.any?
					@identifier=results.first[:o].value
					swagger.addComment "INFO: found identifier #{@identifier} using #{prop}.\n"
					return @identifier
				end
			end
        end
    end
 		
    
    def CommonQueries::GetDataIdentifier(g, swagger)  # send it the graph
        @identifier = nil

		Utils::DATA_PREDICATES.each do |prop|
			swagger.addComment("INFO: SPARQLing for #{prop}.\n")
			if prop =~ /schema\.org\/distribution/
					query = SPARQL.parse("select ?o where {
                                         VALUES ?schemaurl {<http://schema.org/contentUrl> <https://schema.org/contentUrl>}
                                         ?s <#{prop}> ?b .
										 ?b  ?schemaurl ?o}")
					results = query.execute(g)
					if  results.any?
							@identifier=results.first[:o].value
							swagger.addComment "INFO: found identifier #{@identifier} using Schema.org distribution property.\n"
							return @identifier

					end
			elsif prop =~ /dcat\#/
				query = SPARQL.parse("select ?o where {
                                     VALUES ?dcataccess {<http://www.w3.org/ns/dcat#accessURL> <http://www.w3.org/ns/dcat#accessURL>}
                                     ?s <#{prop}> ?b .
									 ?b  ?dcataccess ?o}")
				results = query.execute(g)
				if  results.any?
					@identifier=results.first[:o].value
					swagger.addComment "INFO: found identifier #{@identifier} using DCAT distribution property.\n"
					return @identifier
				end
			else 
				query = SPARQL.parse("select ?o where {?s <#{prop}> ?o}")
				results = query.execute(g)
				if results.any?
					@identifier=results.first[:o].value
					swagger.addComment "INFO: found identifier #{@identifier} using #{prop}.\n"
                    return @identifier
				end
			end

		end
        swagger.addComment "INFO: No data identifier found in this chunk of metadata.\n"
        
        return @identifier  # returns nil if we get to this line
        
    end
end

