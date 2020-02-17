require 'safe_yaml'
require 'open_api_parser'
require 'rdf'
require 'rdf/json'
require 'json/ld'
require 'json'

SafeYAML::OPTIONS[:default_mode] = :safe
  

#class EvaluationsController < ApplicationController
class EvaluationsController < ApiController

    #before_action :set_evaluation, only: [:show, :edit, :update, :destroy, :template, :result, :redisplay_result, :execute_analysis :execute_analysis_json]
  before_action :set_evaluation, only: [:show, :result, :redisplay_result, :deprecate]
  skip_before_action :authenticate_request, only: %i[new index template show deprecate execute_analysis create result]

  include SharedFunctions


 
  # GET /evaluations
  # GET /evaluations.json
  def index
    @evaluations = Evaluation.all
  end


  # GET /evaluations/1
  # GET /evaluations/1.json
  def show
    @collection = Collection.find(@evaluation.collection)
  end



  # GET /evaluations/new
  def new
    @evaluation = Evaluation.new
    @collections = Collection.where("name LIKE ?", "%")
  end




  def result
    #@evaluation = Evaluation.find(params[:id])
    result_json_string = @evaluation.result;  # get the result from the database
    #$stderr.puts "#{result_json_string} FROM DATABASE\n\n"
    
    @result = []
    @iri = @evaluation.resource
    #$stderr.puts "#{@iri} FROM DATABASE\n\n"
    
    resulthash = JSON.parse(result_json_string)

    resulthash.keys.each  do |metricurl|
      thisresulthash = resulthash[metricurl][0]
      @outgraph = RDF::Graph.new << JSON::LD::API.toRdf(thisresulthash)

    $stderr.puts "SEARCHING DB FOR Metric #{metricurl}"
    #metric = Metric.find_by(smarturl: metricsmarturl)
    metricid = metricurl =~ /.*\/(\d+)$/ && $1  # capture final digit and return
    metric = Metric.find(metricid)
    $stderr.puts "FOUND #{metric}"
      @result << [metric, @outgraph]      
    end

#    respond_to do |format|
#      if @result
#        format.html { }
#        format.json { render :show, status: :ok }
#      else
#        format.html { render :show }
#        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
#      end
#    end



  end

  def execute_analysis  #   post 'collections/:id/evaluate, to: 'evaluations#execute_analysis'  # collections/7/evaluate/10.1098/abd.123

    # TODO:   The data model for evaluations is incorrect.
    # There should be a join between evaluation and the collection it is using.
    # Right now it is just the id
    # This is WRONG!  But the evaluation->show routine now assumes this is true
    # so if you fix the data model, you have to fix lots of other things (obviously LOL!)

    #  THIS IS BAD!!!!!!!!!!!!!!!!!  VERY VERY BAD!!!
    #  collection_uri_prefix = "http://linkeddata.systems:3000/collections/"  #  THIS IS BAD!!!!!!!!!!!!!!!!!  VERY VERY BAD!!!
    #  THIS IS BAD!!!!!!!!!!!!!!!!!  VERY VERY BAD!!!
    #  THIS IS BAD!!!!!!!!!!!!!!!!!  VERY VERY BAD!!!
    
    httpheader = Hash.new()
    @subject = ""

    collectionid = params[:id]
    @collection  = Collection.find(collectionid)

    @metrics = @collection.metrics
    data_to_pass = Hash.new
    
#Evaluation MODEL(id: integer,
#           collection: string,
#           body: string,
#           result: string,
#           resource: string,   ***
#           executor: string,   ***
#           title: string,      ***
#           created_at: datetime,
#           updated_at: datetime,
#           deprecated: boolean)

    @resource = params[:resource]
    
    @executor = params[:executor]
    @title = params[:title]

    @evaluation = Evaluation.new(resource: @resource, executor: @executor, title: @title, collection: collectionid)
    
#    {"resource": "10.5281/zenodo.1147435",
#     "executor":  "0000-0001-6960-357X",
#      "title": "an exemplar evaluation of a zenodo record using two identifier metrics"}
    bodyjson = '{"resource": "' + @resource + '", "executor": "' + @executor + '", "title": "' + @title + '"}'    
    @evaluation[:body] =  bodyjson   # the raw JSON of the incoming request

    result_for_db = {}
    
    @metrics.each do |m|
      metricsmarturl = m.smarturl
      data_to_pass[metricsmarturl] ||= {"subject" =>  @resource}

      @result = Array.new()

      $stderr.puts "\n\nmetricsmarturl #{metricsmarturl}"
      
      specs = get_metrics_interfaces([m])  # specs is an array of specs << [metric, specification]
                                                # metric is the ActiveRecord Metric object, specification is a OpenApiParser::Specification
      (metric, spec) = specs.first # there should only be one...
      #$stderr.puts spec.to_s
      spec.raw['paths'].keys.each do |path|
        spec.raw['paths'][path].keys.each do |method|
          
          #   FOR THE MOMENT, ASSUME ONLY POST AND ONLY ONE INTERFACE
          next unless method.downcase == "post"
          json_to_pass = "{}"  # empty json
          
          endpoint = spec.endpoint(path.to_s, method.to_s)
          endpoint.body_schema['properties'].keys.each do |param|
            #$stderr.puts "found property #{param}"
            #next if param == "subject"
            json_to_pass = endpoint.query_json(data_to_pass[metricsmarturl])  # this call will auto-format the JSON according to teh schema in the YAML
          end
          
          http = spec.raw['schemes'].first
          domain = spec.raw['host']
          basepath = spec.raw['basePath']
          
          
          #$stderr.puts "ADDRESS " + http.to_s + "://" + domain.to_s + basepath.to_s  + path.to_s
          uri = http.to_s + "://" + domain.to_s + basepath.to_s + path.to_s
          

          bailout = false
          final_response = ""
          begin
            success = false
            until success do
              RestClient::Request.execute(method: :post, url: uri, payload: json_to_pass.to_json, 
                                timeout: 600, headers: {"content-type": "application/json", "accept": "application/json"}) do |response, request, result|
                  if [301, 302, 307].include? response.code
                    uri = response.headers[:location]
                    $stderr.puts "redirecting to #{uri}"
                  else
                    final_response = response
                    success = true
                  end
              end
            end

          rescue RestClient::ExceptionWithResponse => e
              @evaluation.errors[:not_json] << " - Response #{e.response} from #{uri} with payload #{json_to_pass.to_json} .  Aborting this test  "
              $stderr.puts " - Response #{e.response} from #{uri} with payload #{json_to_pass.to_json} .  Aborting this test  "
              bailout=true
          end

          unless bailout
            $stderr.puts final_response.inspect
              if final_response.headers[:content_type] =~ /json/i          
                body = JSON.parse(final_response.body)  # create a hash
                metricurl = metric_url(metric)
                result_for_db[metricurl] = body   # this is a has of the metric id and the hash of the JSON string from the evaluation service
              else
                @evaluation.errors[:not_json] << " - Response message from FAIR Metrics Test service #{uri} was not JSON. Cannot continue. "
              end
          else
            @evaluation.errors[:not_success_code] << " - FAIR Testing service at #{uri} returned a failure code.  "
          end
        end
      end
    end

    @evaluation[:result] = result_for_db.to_json
    
    #$stderr.puts result_for_db.to_s
    #$stderr.puts "\n\n\nFINAL:  " + @evaluation.inspect
    
  
    respond_to do |format|
      if !@evaluation.errors.any? && @evaluation.save
        format.html { redirect_to result_url(@evaluation), notice: "" }
        format.json { render :show, status: :ok }
      else
        @evaluation.errors[:general_failure] << " - Failed to save new evaluation."
        errors = @evaluation.errors.full_messages
        errorheader = ""
        errors.each {|e| errorheader += e.to_s + "||||" }
        format.html { redirect_to evaluationtemplate_url(:id => @collection.id, :errors => errorheader)  }
        format.json { render :json => {status: :bad_request, errors: @evaluation.errors}, status: 400 }
      end
    end


  end
  

  # Use callbacks to share common setup or constraints between actions.
  def set_evaluation
    @evaluation = Evaluation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def evaluation_params
#    params.require(:evaluation).permit(:collection, :resource, :body, :result, :executor, :title, :metrics, :subject)
    params.require(:resource)
    params.require(:executor)
    params.require(:title)
    params.allow(:guid)
  end
    


  def template()  # template is what raises the Web form, as a prelude to execute_evaluation, which actually does the evaluation.  You can also POST the data to 'response' for the same outcome
    @collection = Collection.find(params[:id])
    #metrics = get_metrics_for_evaluation
    #@metric_interfaces = get_metrics_interfaces(metrics)
    # pass this hash to the View
    
  end
    
  def get_metrics_for_evaluation(id = params[:id])
    @evaluationid = params[:id]
    @iri = @evaluation.resource
    @iri.strip!
    
    collectionid = @evaluation.collection
    @collection = Collection.find(collectionid)
    unless (@collection)
      @evaluation.errors[:no_collection] << "no collection found"
      return []
    end
    
    @metrics = @collection.metrics
    unless (@metrics and @metrics.count > 0)
      @evaluation.errors[:no_metrics] << "no tests found"
      return []
    end
    $stderr.puts "\n\nMETRICS: #{@metrics}\n\n"
    return @metrics
  end
    

  def get_metrics_interfaces(metrics = [])
    specs = Array.new()
    
    metrics.each do |metric|
    
      smartapi = metric.smarturl
      smartapi.strip!
      $stderr.puts "FOUND smartapi #{smartapi}"
      unless (smartapi)
#        format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "no smartAPI found for #{metric.to_s}"}
#        return
      end
      #smartapi = resolve(smartapi)
      interface = fetch(smartapi)
      unless (interface)
#        format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the SmartAPI definition at #{smartapi} could not be retrieved. Please chck and edit evaluation if necessary"}
#        return
      end
      
      smartyaml = interface.body
      
      tfile = Tempfile.new('smartapi')
      tfile.write(smartyaml)
      tfile.rewind
      specification = OpenApiParser::Specification.resolve(tfile, validate_meta_schema: false)
      
      unless (specification)
#        format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the SmartAPI definition in #{smartyaml} could not be retrieved. Please chck and edit evaluation if necessary"}
#        return
      end
      $stderr.puts "\n\n#{metric} with #{specification.raw}\n\n"
      specs << [metric, specification]
    end    
    return specs
  end




  # GET /evaluations/1/edit
  def edit
  end


  # POST /evaluations
  # POST /evaluations.json
  def create
    #@evaluation = Evaluation.new(evaluation_params)
    #if Evaluation.where('title=?', @evaluation.title).first
    #  @evaluation.errors[:nameexists] << "An evaluation by that title already exists"
    #end
    #
    #resource = @evaluation.resource
    #if (resource =~ /doi:/ or resource =~ /(dx\.)?doi\.org/)
    #  canonicalizedDOI = resource.match(/(10.\d{4,9}\/[-\._;()\/:A-Z0-9]+$)/i)[1]
    #  @evaluation.resource = canonicalizedDOI
    #end
    #
    #unless validate_orcid(@evaluation.executor)  # sets an error if there was a problem
    #  @evaluation.errors[:orcid_invalid] << "ORCiD #{@evaluation.executor} failed lookup"
    #end
    #
    #respond_to do |format|
    #  if !@evaluation.errors.any? && @evaluation.save
    #    format.html { redirect_to @evaluation, notice: "Evaluation was successfully created." }
    #    format.json { render :show, status: :created, location: @evaluation }
    #  else
    #    @collections = Collection.all
    #    format.html { render :new }
    #    format.json { render json: @evaluation.errors, status: :unprocessable_entity }
    #  end
    #end
  end
  
  
  # PATCH/PUT /evaluations/1
  # PATCH/PUT /evaluations/1.json
  def update
#    respond_to do |format|
#      if @evaluation.update(evaluation_params)
#        format.html { redirect_to result_url(@evaluation), notice: "" }
#        format.json { redirect_to result_url(@evaluation) }
      #else
      #  format.html { render :edit }
      #  format.json { render json: @evaluation.errors, status: :unprocessable_entity }
 #     end
 #   end
  end


  def deprecate
    #@evaluation.deprecated = true
    #@evaluation.save
    #respond_to do |format|
    #    format.html { redirect_to evaluations_url, notice: "Evaluation deprecated" }
    #    format.json { head :no_content }
    #end

  end
  
  def deprecate_and_return
    #@evaluation.deprecated = true
    #@evaluation.save
  end
  
  
  # DELETE /evaluations/1
  # DELETE /evaluations/1.json
  def destroy
    #@evaluation.destroy
    #respond_to do |format|
    #  format.html { redirect_to evaluations_url, notice: 'Evaluation was successfully destroyed.' }
    #  format.json { head :no_content }
    #endy
  end

  def error
  end
  

  def execute_analysis_DEPRECATED

    ##  THIS IS BAD!!!!!!!!!!!!!!!!!  VERY VERY BAD!!!
    #@uriprefix = "http://linkeddata.systems:3000/metrics/"  #  THIS IS BAD!!!!!!!!!!!!!!!!!  VERY VERY BAD!!!
    ##  THIS IS BAD!!!!!!!!!!!!!!!!!  VERY VERY BAD!!!
    ##  THIS IS BAD!!!!!!!!!!!!!!!!!  VERY VERY BAD!!!
    #
    #
    #errors = Hash.new([])
    #httpheader = Hash.new()
    #@subject = ""
    ##deprecate_and_return()  # deprecate the old
    ##@evaluation  = Evaluation.new(collection: @evaluation.collection, resource: @evaluation.resource, title: @evaluation.title, executor: @evaluation.executor )  # create the new
    #
    #data_to_pass = Hash.new()  # this will contain the hash that will be used to create the JSON formatted request
    #
    #if (params[:MetricIDs])  # this is coming from the Web interface
    #  httpheader["Accept"] = "text/html"
    #  metricids = params[:MetricIDs]
    #
    #  metricids.each do |metricid|
    #    metricid = metricid.to_s
    #    metricuri = @uriprefix + metricid
    #    
    #    metricshash = params[:metrics].select {|m| m.match(/Metric_#{metricid}/)}  # select only the parameters for this metric ID
    #    @subject = params[:subject]  # this should now be redundant, but we will do it anyway LOL!
    #    if (params[:executor])
    #      @evaluation.executor = params[:executor]
    #    end
    #
    #    metricshash.each do |met, val|
    #      
    #      if !(met.match(/Metric_(\d+)_(\w+)/)) then
    #        $stderr.puts "#{met} didn't match regexp for metric name"
    #      else 
    #        metricid = $1
    #        metricparam = $2
    #        data_to_pass[metricuri] ||= {"subject" => @subject}  # add the subject node; maybe duplicate calls, but just easier this way and does no harm
    #        data_to_pass[metricuri].merge!({metricparam.to_s => val})  # push each of the metric parameters and their values to the data
    #      end
    #    end
    #  end
    #
    #else   #  WE SHOULD CAREFULLY TEST THE INCOMING JSON....  ONE DAY!!!
    #  json = request.body.read
    #  $stderr.puts "\n\n\n\n\n\nGOIN ITO JSON\n\n#{json}\n\n\n\n\n"
    #  #httpheader["Accept"] = "application/json"
    #  begin
    #    
    #    incoming_hash = JSON.parse(json)  # if it isn't JSON, then this will fail
    #  rescue
    #    $stderr.puts "\n\n\n\n\n\nUNDECIPHAERABLE JSON\n\n#{request.body.read}\n\n\n\n\n"
    #    errors[:json_undecipherable] << "The JSON passed to the Evaluator was not readable"
    #  end
    #  
    #  $stderr.puts "\n\nDATA PASSED IN: " + incoming_hash.to_s
    #  collection = incoming_hash.keys.first
    #  @subject = incoming_hash[collection]
    #
    #  matches = collection.match(/(\d+)\/?$/)
    #  collection_id = matches[1]
    #  metrics = Collection.find(collection_id).metrics
    #  metrics.each do |m|
    #    metricid = m.id.to_s
    #    metricuri = @uriprefix + metricid
    #    data_to_pass[metricuri] ||= {"subject" =>  @subject}
    #  end
    #
    #end
    #
    #    
    #@evaluation.body = data_to_pass.to_json   # save the json locally so it can be re-used to re-execute the metric
    #unless @evaluation.save 
    #    $stderr.puts "wasn't able to save the record #{data_to_pass} for #{@evaluation.id}"
    #end
    #
    #  
    #@result = Array.new()
    #result_for_db = {}
    #data_to_pass.keys.each  do |metricuri|
    #  $stderr.puts "\n\nmetricuri #{metricuri}"
    #  
    #  metricuri =~ /.*?(\d+)$/
    #  metricid = $1
    #  metric = Metric.find(metricid)
    #  specs = get_metrics_interfaces([metric])  # specs is an array of specs << [metric, specification]
    #                                            # metric is the ActiveRecord Metric object, specification is a OpenApiParser::Specification
    #  (metric, spec) = specs.first # there should only be one...
    #  #$stderr.puts spec.to_s
    #  spec.raw['paths'].keys.each do |path|
    #    spec.raw['paths'][path].keys.each do |method|
    #      
    #      #   FOR THE MOMENT, ASSUME ONLY POST AND ONLY ONE INTERFACE
    #      next unless method.downcase == "post"
    #      json_to_pass = "{}"  # empty json
    #      
    #      endpoint = spec.endpoint(path.to_s, method.to_s)
    #      endpoint.body_schema['properties'].keys.each do |param|
    #        $stderr.puts "found property #{param}"
    #        #next if param == "subject"
    #        json_to_pass = endpoint.query_json(data_to_pass[metricuri])  # this call will auto-format the JSON according to teh schema in the YAML
    #      end
    #      
    #      http = spec.raw['schemes'].first
    #      domain = spec.raw['host']
    #      basepath = spec.raw['basePath']
    #      
    #      
    #      $stderr.puts "ADDRESS " + http.to_s + "://" + domain.to_s + basepath.to_s  + path.to_s
    #      uri = URI.parse(http.to_s + "://" + domain.to_s + basepath.to_s + path.to_s)
    #
    #      httpheader["Content-Type"] = 'application/json'
    #      
    #      # Create the HTTP objects  -execute the test!!!!!!!!
    #      http = Net::HTTP.new(uri.host, uri.port)
    #      request = Net::HTTP::Post.new(uri.request_uri, httpheader)
    #      request.body = json_to_pass.to_json
    #      $stderr.puts json_to_pass.to_json
    #      response = http.request(request)
    #      body = JSON.parse(response.body)  # create a hash
    #      result_for_db["#{@uriprefix}" + metric.id.to_s] = body   # this is a has of the metric id and the hash of the JSON string from the evaluation service
    #    end
    #  end
    #end
    #
    #@evaluation[:result] = result_for_db.to_json   #  A HASH converted to JSON for storage in the database
    #unless @evaluation.save
    #  $stderr.puts "couldn't save the result #{result_for_db.to_json} for evaluation #{@evaluation.id}"  
    #end
    #
    #respond_to do |format|
    #    format.html { redirect_to result_url(@evaluation), notice: "" }
    #    format.json { render :show }
    #end
    #
    
  end

  def deprecate
    
  end
  



end
