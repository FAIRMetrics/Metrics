require 'json'
require 'rdf'
require 'rdf/json'
require 'json/ld'

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
  attr_accessor :host
  attr_accessor :basePath
  attr_accessor :path
  attr_accessor :response_description
  attr_accessor :schemas
  attr_accessor :comments
  attr_accessor :fairsharing_key_location
  attr_accessor :score
  attr_accessor :testedURI
  
  def initialize (params = {})
	@debug = true
	
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
    @basePath = params.fetch(:basePath)
    @path = params.fetch(:path)
    @response_description = params.fetch(:response_description)
    @schemas = params.fetch(:schemas, [])
    @comments = params.fetch(:comments, [])
    @fairsharing_key_location = params.fetch(:fairsharing_key_location)
	@score = params.fetch(:score, 0)
	@testedURI = params.fetch(:testedURI)
	
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
  - http
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
		$stderr.puts "|#{o}| #{o.class}"
        if o.to_s =~ /^\w+:\/?\/?[^\s]+/
                o = RDF::URI.new(o.to_s)
        elsif o.to_s =~ /^\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d/
                o = RDF::Literal.new(o.to_s, :datatype => RDF::XSD.date)
        elsif o.to_s =~ /^\d\.\d/
		  $stderr.puts "\n\n\n\nFOUND FLOAT\n\n\n\n"
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
		  self.comments = self.comments.to_s + newcomment.to_s
		  return self.comments
	end

	def createEvaluationResponse
      
	  g = RDF::Graph.new
	  
      dt = Time.now.iso8601
	  uri = self.testedURI
      triplify("#{uri}/result##{dt}", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://fairmetrics.org/resources/metric_evaluation_result", g );
      triplify("#{uri}/result##{dt}", "http://semanticscience.org/resource/SIO_000300", self.score, g )
      triplify("#{uri}/result##{dt}", "http://purl.obolibrary.org/obo/date", dt, g )
      triplify(uri,"http://semanticscience.org/resource/SIO_000629", "#{uri}/result##{dt}", g)

      
	  if not self.comments.eql?("")
		triplify("#{uri}/result##{dt}", "http://schema.org/comment", self.comments, g)
	  else
		triplify("#{uri}/result##{dt}", "http://schema.org/comment", "no comments", g)
	  end
      
      #print "Content-type: application/json\n\n";
      return g.dump(:jsonld)
	end
	
    
end

