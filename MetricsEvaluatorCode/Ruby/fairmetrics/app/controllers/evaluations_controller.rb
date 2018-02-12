require 'safe_yaml'
require 'open_api_parser'
SafeYAML::OPTIONS[:default_mode] = :safe

class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: [:show, :edit, :update, :destroy, :execute]
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
        format.html { redirect_to @evaluation, notice: "Evaluation was successfully created.}" }
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

    if @evaluation.body   #evaluation has been done
      show()
      return
    end
    
    
    iri = @evaluation.resource
    
    respond_to do |format|

      unless (@evaluate_me = fetch(iri))
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the resource at #{iri} could not be retrieved. Please chck and edit evaluation if necessary"}
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
      @specs = Array.new()
      @metrics.each do |metric|
        
        @smartapi = metric.smarturl
        unless (@smartapi)
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "no smartAPI found for #{metric.to_s}"}
          return
        end
        next unless @smartapi.match(/http/)
        unless (@interface = fetch(@smartapi))
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the SmartAPI definition at #{smartapi} could not be retrieved. Please chck and edit evaluation if necessary"}
          return
        end
        
        tfile = Tempfile.new('smartapi')
        tfile.write(@interface.body)
        tfile.rewind
        specification = OpenApiParser::Specification.resolve(tfile, validate_meta_schema: false)
        unless (specification)
          format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "the SmartAPI definition in #{@interface.body} could not be retrieved. Please chck and edit evaluation if necessary"}
          return
        end
        @specs << specification
        #yaml = YAML.load(smartapi)
        #unless (yaml)
        #  format.html { redirect_to "/evaluations/#{params[:id]}/error", notice: "no yaml found for #{smartapi}"}
        #  return
        #end
      end  # end of DO
      #format.html {redirect_to "/evaluations/#{params[:id]}/error", notice: "an undefined error has occurred. Bummer for you!"}
    end
  end









  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation
      @evaluation = Evaluation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def evaluation_params
      params.require(:evaluation).permit(:collection, :resource, :body, :result, :executor, :title)
    end
end
