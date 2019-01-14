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

class Utils
    Utils::TEXT_FORMATS = {
        'text' => ['text/plain',],
    }

    Utils::AcceptHeader = {'Accept' => 'text/turtle, application/n3, application/rdf+n3, application/turtle, application/x-turtle,text/n3,text/turtle,                   text/rdf+n3, text/rdf+turtle,application/json+ld, text/xhtml+xml,application/rdf+xml,application/n-triples' }


    Utils::RDF_FORMATS = {
      'jsonld'  => ['application/json+ld'],
      'turtle'  => ['text/turtle','application/n3','application/rdf+n3',
                   'application/turtle', 'application/x-turtle','text/n3','text/turtle',
                   'text/rdf+n3', 'text/rdf+turtle'],
      'rdfa'    => ['text/xhtml+xml'],
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
        'http://semanticscience.org/resource/SIO_000332', # is about
        'http://purl.obolibrary.org/obo/IAO_0000136', # is about
        ]
        
                       
                       
                              
    #  MARK!  MONDAY!!!              
    #need to create a resolution function here that deals with whatever kind of identifier comes in and passes
    #back the body content.  Don't want to dplucate code resolving GUIDs in each test!
    # ##########################
    
    def Utils::resolveit(guid)
      inchi = Regexp.new(/^\w{14}\-\w{10}\-\w$/)
      doi = Regexp.new(/^10.\d{4,9}\/[-._;()\/:A-Z0-9]+$/i)
      handle = Regexp.new(/^[2-9]0.\d{4,9}\/[-._;()\/:A-Z0-9]+$/i)
      uri = Regexp.new(/^\w+:\/?\/?[^\s]+$/)

      case 
        when guid.match(inchi)
          (parser, data, comments) = Utils::resolve_inchi(guid)
          return "inchi",parser, data, comments
        when guid.match(doi)
          parser, data, comments = Utils::resolve_doi(guid)
          return "doi", parser, data, comments
        when guid.match(handle)
           parser, data, comments = Utils::resolve_handle(guid)
           return "handle", parser, data, comments
        when guid.match(uri)
          parser, data, comments = Utils::resolve_uri(guid)
          return "uri", parser, data, comments
      end

      return nil, nil, nil, ["the guid did not correspond to any known GUID"]
    end
    
    
    
    def Utils::resolve_inchi(guid)
      comments = Array.new()
      g = RDF::Graph.new
      
      comments << "Found an InChI Key GUID.  "
      step1 = self.fetch("https://pubchem.ncbi.nlm.nih.gov/rest/rdf/inchikey/#{guid}")
      # this is a Net::HTTP response
      #$stderr.puts step1.body
      
      (parser, type) = Utils::figure_out_type(step1)
      
      return g, comments unless parser

      # this next operation is safe because we know that pubchem does in fact return Turtle
      return g,comments unless parser.eql?"turtle"  # simply fail if they asked for HTML or something else
      reader = RDF::Reader.for(:turtle).new(step1.body) 
      g << reader
        
      query = SPARQL.parse("select ?o where {?s <http://semanticscience.org/resource/is-attribute-of> ?o}")
      results = query.execute(g)
      unless results.any?
        comments << "could not find the sio:is_attribute_of predicate in the first layer of metadata.  Aborting with failure.  "
        return g, comments
      end
      
      cpd = results.first[:o]
      cpd = cpd.to_s
      cpd = cpd.gsub(/\/$/, "")
      step2 = fetch(cpd)
      (parser, type) = Utils::figure_out_type(step2)
      return g, comments unless parser

      # this next operation is safe because we know that pubchem does in fact return Turtle
      return g,comments unless parser.eql?"turtle"  # simply fail if they asked for HTML or something else
      reader = RDF::Reader.for(:turtle).new(step2.body) 
      g << reader
      
      return parser, g, comments
    end
    
    def Utils::resolve_doi(guid, type = "text/turtle")
    end
    
    def Utils::resolvehandle(guid, type = "text/turtle")
    end
    
    def Utils::resolve_uri(guid, type = "text/turtle" )
    end
    

  def Utils::figure_out_type(message)
    type = message.header['content-type']
    Utils::RDF_FORMATS.each do |parser, types|
      if types.include?type
        return parser, type
      end
    end
    Utils::JSON_FORMATS.each do |parser, types|
      if types.include?type
        return parser, type
      end
    end
    Utils::TEXT_FORMATS.each do |parser, types|
      if types.include?type
        return parser, type
      end
    end
    Utils::XML_FORMATS.each do |parser, types|
      if types.include?type
        return parser, type
      end
    end
    Utils::HTML_FORMATS.each do |parser, types|
      if types.include?type
        return parser, type
      end
    end
    return nil, nil
  end
    
    
  # general Web utilities... follow redirects, for example
  def Utils::fetch(uri_str)  #we will try to retrieve turtle whenever possible
    address = URI::encode(uri_str)
    address = resolve(address)  # this runs through any redirects until there is a URL that will return data
    addressURI = URI(address)
    http = Net::HTTP.new(addressURI.host, addressURI.port)
    if address.match(/^https:/i)
      http.use_ssl = true                            # if using SSL
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE   # for example, when using self-signed certs
    end
    
    response = http.request_get(address, Utils::AcceptHeader)  

    case response   # the \"case\" block allows you to test various conditions... it is like an \"if\", but cleaner!\n,
	  when Net::HTTPSuccess then  # when response Object is of type Net::HTTPSuccess\n",
	    # successful retrieval of web page\n",
	    return response  # return that response object to the main code\n",
	  else
	    #raise Exception, "Something went wrong... the call to #{uri_str} failed; type #{response.class}"
	    # note - if you want to learn more about Exceptions, and error-handling\n",
	    # read this page:  http://rubylearning.com/satishtalim/ruby_exceptions.html  \n",
	    # you can capture the Exception and do something useful with it!\n",
	    response = false
	    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    end
  end

  def Utils::head(uri)
    uri = Utils::resolve(uri)
    response=nil
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.match(/^https:/i)
      http.use_ssl = true                            # if using SSL
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE   # for example, when using self-signed certs
    end
    
    response = http.head(path)
    return response 
    # response.each { |key, value| puts key.ljust(40) + " : " + value }
    
  end


   # this returns the URI that results from all redirects, etc.
  def Utils::resolve(uri_str, agent = 'curl/7.43.0', max_attempts = 10, timeout = 10)
    attempts = 0
    max_attempts = 5
    cookie = nil

    # is it a DOI?
    if (uri_str.match(/^(10.\d{4,9}\/[-\._;()\/:A-Z0-9]+$)/i))
      uri_str = "http://dx.doi.org/#{uri_str}"  # convert to resolvable DOI URL
    end


    until attempts >= max_attempts
      attempts += 1

      url = URI.parse(uri_str)
      http = Net::HTTP.new(url.host, url.port)
      http.open_timeout = timeout
      http.read_timeout = timeout
      path = url.path
      path = '/' if path == ''
      path += '?' + url.query unless url.query.nil?

      params = { 'User-Agent' => agent, 'Accept' => '*/*' }
      params['Cookie'] = cookie unless cookie.nil?
      request = Net::HTTP::Get.new(path, params)

      if url.instance_of?(URI::HTTPS)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = http.request(request)

      case response
        when Net::HTTPSuccess then
          break
        when Net::HTTPRedirection then
          location = response['Location']
          cookie = response['Set-Cookie']
          new_uri = URI.parse(location)
          uri_str = if new_uri.relative?
                      url + location
                    else
                      new_uri.to_s
                    end
        else
          logger.debug "\n\nUnexpected response from #{url.inspect}: " + response.inspect + "\n\n"
      end
    end
    logger.debug "\n\nToo many http redirects from  #{url.inspect}:\n\n" if attempts == max_attempts

    uri_str
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
  attr_accessor :testedURI
    
  def initialize(params = {})
	@debug = false
	
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
	@testedURI = params.fetch(:testedURI, "")
	

	
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
              s.strip!
      end
      if p.class == String
              p.strip!
      end
      if o.class == String
              o.strip!
      end
      
      unless s.respond_to?('uri')
        
        if s.to_s =~ /^\w+:\/?\/?[^\s]+/
                s = RDF::URI.new(s.to_s)
        else
          $stderr.puts "Subject #{s.to_s} must be a URI-compatible thingy"
          abort "Subject #{s.to_s} must be a URI-compatible thingy"
        end
      end
      
      unless p.respond_to?('uri')
    
        if p.to_s =~ /^\w+:\/?\/?[^\s]+/
                p = RDF::URI.new(p.to_s)
        else
          $stderr.puts "Predicate #{p.to_s} must be a URI-compatible thingy"
          abort "Predicate #{p.to_s} must be a URI-compatible thingy"
        end
      end
  
      unless o.respond_to?('uri')
        #$stderr.puts "|#{o}| #{o.class}"
        if o.to_s =~ /^\w+:\/?\/?[^\s]+/
                o = RDF::URI.new(o.to_s)
        elsif o.to_s =~ /^\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d/
                o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.date)
        elsif o.to_s =~ /^\d\.\d/
        #$stderr.puts "\n\n\n\nFOUND FLOAT\n\n\n\n"
                o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.float)
        elsif o.to_s =~ /^[0-9]+$/
                o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.int)
        else
                o = RDF::Literal.new(o.to_s, :language => :en)
        end
      end
  
      self.debug && $stderr.puts("inserting #{s.to_s} #{p.to_s} #{o.to_s}")
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
    uri = self.testedURI

    me = self.protocol + "://" + self.host + "/" + self.basePath + self.path
    
    meURI  ="#{me}##{URI.encode(uri)}/result-#{URI.encode(dt)}"

    triplify(meURI, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://fairmetrics.org/resources/metric_evaluation_result", g );
    triplify(meURI, "http://semanticscience.org/resource/SIO_000300", self.score, g )
    triplify(meURI, "http://purl.obolibrary.org/obo/date", dt, g )
    triplify(meURI,"http://semanticscience.org/resource/SIO_000332", uri, g)
    
    
    if not self.comments.eql?("")
      triplify(meURI, "http://schema.org/comment", self.comments.join("\n"), g)
    else
      triplify(meURI, "http://schema.org/comment", "no comments", g)
    end
    
    return g.dump(:jsonld)
  end
	
   
end
