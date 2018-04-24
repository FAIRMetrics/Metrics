require 'safe_yaml'
require 'open_api_parser'
require 'rdf'
#$LOAD_PATH.unshift "/home/markw/.rvm/gems/ruby-2.4.1/gems/rdf-json-2.2.0/lib"
require 'rdf/json'

SafeYAML::OPTIONS[:default_mode] = :safe

class EvaluationsController < ApplicationController
  
  #before_action :set_evaluation, only: [:show, :edit, :update, :destroy, :execute, :result, :redisplay_result, :execute_analysis]
  before_action :set_evaluation, only: [:show, :execute, :result, :redisplay_result, :execute_analysis]
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
        format.html { redirect_to @evaluation, notice: "Evaluation was successfully updated." }
        format.json { render :show, status: :ok, location: @evaluation }
      else
        format.html { render :edit }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
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
  

  def execute()

#    if @evaluation.body   #evaluation has been done
#      show()
#      return
#    end
    
    metrics = get_metrics_for_evaluation
    @metric_interfaces = get_metrics_interfaces(metrics)
    # pass this hash to the View    
  end



  def result
    result_json_string = @evaluation.result;
    
    @result = []
    @iri = @evaluation.resource
    
    resulthash = JSON.parse(result_json_string)

    resulthash.keys.each  do |metricid|
      thisresulthash = resulthash[metricid]
      #thisresulthash = JSON.parse(thisresultjson)
      reader = RDF::JSON::Reader.new(thisresulthash.to_json)    
      @outgraph = RDF::Graph.new()
      reader.each_statement do |statement|
        @outgraph << statement
      end
      metric = Metric.find(metricid)
      @result << [metric, @outgraph]      
    end

  end


  def execute_analysis

    metricshash = params[:metrics]
    subject = params[:subject]

    data_to_pass = Hash.new()

    metricshash.each do |met, val|
      
      if !(met.match(/Metric_(\d+)_(\w+)/)) then
        $stderr.puts "#{met} didn't match regexp for metric name"
      else 
        metricid = $1
        metricparam = $2
        
        data_to_pass[metricid.to_i] ||= {"subject" => subject}  # maybe duplicate calls, but just easier this way and does no harm
        data_to_pass[metricid.to_i].merge!({metricparam.to_s => val})
      end
    end
    
    @evaluation.body = data_to_pass.to_json   # save it as json so it can be parsed
    unless @evaluation.save 
        $stderr.puts "wasn't able to save the record #{data_to_pass} for #{@evaluation.id}"
    end
    
    
    
    @result = Array.new()
    result_for_db = {}
    data_to_pass.keys.each  do |metricid|
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
            json_to_pass = endpoint.query_json(data_to_pass[metricid])  # this call will auto-format the JSON according to teh schema in the YAML
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
          result_for_db[@metric.id] = body   # this is a has of the metric id and the hash of the JSON string from the evaluation service
        end
      end
    end

    @evaluation[:result] = result_for_db.to_json   #  A HASH converted to JSON for storage in the database
    unless @evaluation.save
      $stderr.puts "couldn't save the result #{result_for_db.to_json} for evaluation #{@evaluation.id}"  
    end
    
    respond_to do |format|
#      if @evaluation.update(evaluation_params)
        format.html { redirect_to "/evaluations/#{@evaluation.id}/result", notice: "" }
        format.json { render :show, status: :ok, location: @evaluation }
      #else
      #  format.html { render :edit }
      #  format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      #end
    end

    
  end




  private
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

      @iri = resolve(@iri)
      unless (@evaluate_me = fetch(@iri))
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
    
    respond_to do |format|
      metrics.each do |metric|
      
        smartapi = metric.smarturl
        smartapi.strip!
        unless (smartapi)
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "no smartAPI found for #{metric.to_s}"}
          return
        end
        smartapi = resolve(smartapi)
#$stderr.puts "SMARTAPI #{smartapi.to_s}"

        unless (interface = fetch(smartapi))
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the SmartAPI definition at #{smartapi} could not be retrieved. Please chck and edit evaluation if necessary"}
          return
        end
        
        smartyaml = interface.body
#$stderr.puts "\n\nInterface#{smartyaml}\n\n"
        
        tfile = Tempfile.new('smartapi')
        tfile.write(smartyaml)
        tfile.rewind
        specification = OpenApiParser::Specification.resolve(tfile, validate_meta_schema: false)
        unless (specification)
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the SmartAPI definition in #{smartyaml} could not be retrieved. Please chck and edit evaluation if necessary"}
          return
        end
        specs << [metric, specification]
        #yaml = YAML.load(smartapi)
        #unless (yaml)
        #  format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "no yaml found for #{smartapi}"}
        #  return
        #end
      end
      format.html{"all good"}
    end  # end of DO FORMAT
    
    return specs
  end


end
