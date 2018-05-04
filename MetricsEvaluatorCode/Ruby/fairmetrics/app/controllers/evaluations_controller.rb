require 'safe_yaml'
require 'open_api_parser'
require 'rdf'
require 'rdf/json'

SafeYAML::OPTIONS[:default_mode] = :safe

#class EvaluationsController < ApplicationController
class EvaluationsController < ApiController

    #before_action :set_evaluation, only: [:show, :edit, :update, :destroy, :template, :result, :redisplay_result, :execute_analysis]
  before_action :set_evaluation, only: [:show, :template, :result, :redisplay_result, :execute_analysis]
  skip_before_action :authenticate_request, only: %i[new index template show execute_analysis create result]

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



  # GET /evaluations/1/edit
  def edit
  end


  # POST /evaluations
  # POST /evaluations.json
  def create
    @evaluation = Evaluation.new(evaluation_params)
    @evaluation.collection = evaluation_params[:collection]
    resource = @evaluation.resource
    if (resource =~ /doi:/ or resource =~ /dx\.doi\.org/)
      canonicalizedDOI = resource.match(/(10.\d{4,9}\/[-\._;()\/:A-Z0-9]+$)/i)[1]
      @evaluation.resource = canonicalizedDOI
    end
    

    respond_to do |format|
      if @evaluation.save
        format.html { redirect_to @evaluation, notice: "Evaluation was successfully created." }
        format.json { render :show, status: :created, location: @evaluation }
      else
        format.html { render :new }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  # PATCH/PUT /evaluations/1
  # PATCH/PUT /evaluations/1.json
  def update
    respond_to do |format|
      if @evaluation.update(evaluation_params)
        format.html { redirect_to result_url(@evaluation), notice: "" }
        format.json { redirect_to result_url(@evaluation) }
      #else
      #  format.html { render :edit }
      #  format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  
  
  
  # DELETE /evaluations/1
  # DELETE /evaluations/1.json
  def destroy
    @evaluation.destroy
    respond_to do |format|
      format.html { redirect_to evaluations_url, notice: 'Evaluation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def error
  end
  

  def template()  # template is what raises the Web form, as a prelude to execute_evaluation, which actually does the evaluation.  You can also POST the data to 'response' for the same outcome
    
    metrics = get_metrics_for_evaluation
    @metric_interfaces = get_metrics_interfaces(metrics)
    # pass this hash to the View
    
  end



  def result
    result_json_string = @evaluation.result;  # get the result from the database
    
    @result = []
    @iri = @evaluation.resource
    
    resulthash = JSON.parse(result_json_string)

    resulthash.keys.each  do |metricuri|
      thisresulthash = resulthash[metricuri]
      #thisresulthash = JSON.parse(thisresultjson)
      reader = RDF::JSON::Reader.new(thisresulthash.to_json)    
      @outgraph = RDF::Graph.new()
      reader.each_statement do |statement|
        @outgraph << statement
      end

      metricuri =~ /.*?(\d+)$/
      metricid = $1
      metric = Metric.find(metricid)
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


  def execute_analysis


    @uriprefix = "http://linkeddata.systems:3000/metrics/"



    data_to_pass = Hash.new()  # this will contain the hash that will be used to create the JSON formatted request

    if (params[:metrics])  # this is coming from the Web interface

      
      metricshash = params[:metrics]
      subject = params[:subject]
  
  
      metricshash.each do |met, val|
        
        if !(met.match(/Metric_(\d+)_(\w+)/)) then
          $stderr.puts "#{met} didn't match regexp for metric name"
        else 
          metricid = $1
          metricparam = $2
          metricuri = "#{@uriprefix}#{metricid}"
          $stderr.puts "\n\n\nprefix is #{@uriprefix}\n\n\n"
          
#          data_to_pass[metricid.to_i] ||= {"subject" => subject}  # add the subject node; maybe duplicate calls, but just easier this way and does no harm
#          data_to_pass[metricid.to_i].merge!({metricparam.to_s => val})  # push each of the metric parameters and their values to the data
          data_to_pass[metricuri] ||= {"subject" => subject}  # add the subject node; maybe duplicate calls, but just easier this way and does no harm
          data_to_pass[metricuri].merge!({metricparam.to_s => val})  # push each of the metric parameters and their values to the data
        end
      end

    else
      begin
        data_to_pass = JSON.parse(request.body.read)  # if it isn't JSON, then this will fail
      rescue
        respond_to do |format|   # ifr it fails, just send nothing
          format.html { redirect_to evaluations_url, notice: 'Message body undeciperable.' }
          format.json { head :no_content }
          format.any { head :no_content }
        end
      end
    end
    
        
    @evaluation.body = data_to_pass.to_json   # save the json locally so it can be re-used to re-execute the metric
    unless @evaluation.save 
        $stderr.puts "wasn't able to save the record #{data_to_pass} for #{@evaluation.id}"
    end
    
    
    
    @result = Array.new()
    result_for_db = {}
    data_to_pass.keys.each  do |metricuri|
      metricuri =~ /.*?(\d+)$/
      metricid = $1
      @metric = Metric.find(metricid)
      specs = get_metrics_interfaces([@metric])  # specs is an array of specs << [metric, specification]
                                                # metric is the ActiveRecord Metric object, specification is a OpenApiParser::Specification
      (@metric, spec) = specs.first # there should only be one...

      spec.raw['paths'].keys.each do |path|
        spec.raw['paths'][path].keys.each do |method|
          
          #   FOR THE MOMENT, ASSUME ONLY POST AND ONLY ONE INTERFACE
          next unless method.downcase == "post"
          json_to_pass = "{}"  # empty json
          
          endpoint = spec.endpoint(path.to_s, method.to_s)
          endpoint.body_schema['properties'].keys.each do |param|
            next if param == "subject"
            json_to_pass = endpoint.query_json(data_to_pass[metricuri])  # this call will auto-format the JSON according to teh schema in the YAML
          end
          
          http = spec.raw['schemes'].first
          domain = spec.raw['host']
          basepath = spec.raw['basePath']
          
          
          $stderr.puts "ADDRESS " + http.to_s + "://" + domain.to_s + basepath.to_s  + path.to_s
          uri = URI.parse(http.to_s + "://" + domain.to_s + basepath.to_s + path.to_s)

          header = {'Content-Type': 'text/json'}
          
          # Create the HTTP objects
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri, header)
          request.body = json_to_pass.to_json
          response = http.request(request)
#          $stderr.puts "\n\n\nresponse body #{JSON.parse(response.body)}\n\n\n"

          body = JSON.parse(response.body)  # create a hash
          result_for_db["#{@uriprefix}" + @metric.id.to_s] = body   # this is a has of the metric id and the hash of the JSON string from the evaluation service
        end
      end
    end

    @evaluation[:result] = result_for_db.to_json   #  A HASH converted to JSON for storage in the database
    unless @evaluation.save
      $stderr.puts "couldn't save the result #{result_for_db.to_json} for evaluation #{@evaluation.id}"  
    end
    
    respond_to do |format|
        format.html { redirect_to   result_url(@evaluation), notice: "" }
        format.json { redirect_to result_url(@evaluation) }
    end

    
  end


    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation
      @evaluation = Evaluation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def evaluation_params
      params.require(:evaluation).permit(:collection, :resource, :body, :result, :executor, :title, :metrics, :subject)
    end
    
    
  def get_metrics_for_evaluation(id = params[:id])
    @evaluationid = params[:id]
    @iri = @evaluation.resource
    @iri.strip!
    
    respond_to do |format|
      #$stderr.puts "\n\nFormat#{format.class}\n\n"

      resolvediri = resolve(@iri)
      unless (@evaluate_me = fetch(resolvediri))
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the resource at #{@iri} could not be retrieved. Please chck and edit evaluation if necessary"}
          return
      end
      
      collectionid = @evaluation.collection
      @collection = Collection.find(collectionid)
      unless (@collection)
        format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "no collection found for #{collectionid}"}
        return
      end
      
      @metrics = @collection.metrics
      unless (@metrics)
        format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "no metrics found for #{collectionid}"}
        return
      end
    format.html{"all good so far!"}
      
    end
    return @metrics
  end
    


  def get_metrics_interfaces(metrics = [])
    specs = Array.new()
    
      metrics.each do |metric|
      
        smartapi = metric.smarturl
        smartapi.strip!
        unless (smartapi)
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "no smartAPI found for #{metric.to_s}"}
          return
        end
        smartapi = resolve(smartapi)

        unless (interface = fetch(smartapi))
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the SmartAPI definition at #{smartapi} could not be retrieved. Please chck and edit evaluation if necessary"}
          return
        end
        
        smartyaml = interface.body
        
        tfile = Tempfile.new('smartapi')
        tfile.write(smartyaml)
        tfile.rewind
        specification = OpenApiParser::Specification.resolve(tfile, validate_meta_schema: false)
        unless (specification)
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the SmartAPI definition in #{smartyaml} could not be retrieved. Please chck and edit evaluation if necessary"}
          return
        end
        specs << [metric, specification]
      end    
    return specs
  end


end
