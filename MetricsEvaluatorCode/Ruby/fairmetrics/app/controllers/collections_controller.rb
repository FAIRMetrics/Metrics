class CollectionsController < ApiController
#class CollectionsController < ApplicationController

#  before_action :set_collection, only: [:show, :edit, :update, :destroy]
  before_action :set_collection, only: [:show, :deprecate ]

  skip_before_action :authenticate_request, only: %i[index show new collect_metrics register_metrics create deprecate]


  # GET /collections
  # GET /collections.json
  def index
    @collections = Collection.all
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
    respond_to do |format|
        format.html { render :show }
        format.json { render :show,  location: @collection }
        format.jsonld { render :show, formats: :json,  location: @collection }
    end
  end

  # GET /collections/new
  def new
    @metrics = Metric.where(deprecated: false)
    @collection = Collection.new
    #respond_to do |format|
    #    format.html { render :show }
    #    format.json { render :show,  location: @collection }
    #    format.jsonld { render :show, formats: :json,  location: @collection }
    #end
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections
  # POST /collections/new
  # POST /collections.json
  def create
    
    @collection = Collection.new(name: params[:name],
                                 contact: params[:contact],
                                 organization: params[:organization],
                                 description: params[:description])
    if @collection.description == "" or @collection.description == nil
      @collection.errors[:description] << "Collections must have descriptions"
    end
    
    metricurls = params[:include_metrics]  # note that these might not exist in the registry!  We will check in a moment

    @metrics = Metric.where(smarturl: metricurls)
    
    if Collection.where('name=?', @collection.name).first
      @collection.errors[:description] << "A collection by that name already exists"
    end
    
    # TODO  if the validation URL is invalid, it crashes ugly.  Catch that error one day
    unless validate_orcid(@collection.contact)  # this adds an error if it fails
      @collection.errors[:description] << "The ORCiD #{@collection.contact} failed lookup"
    end

    metricurls.each do |m|
      existing = Metric.find_by({smarturl: m})
      unless existing
        @collection.errors[:description] << "metric #{m} doesn't exist in this registry"
        next
      end
      if existing.deprecated
        @collection.errors[:description] << "metric #{m} is deprecated and cannot be used"
      end
    end
 
    @metrics.each {|m| @collection.metrics << m}  # it's ok to add the metrics, even if one is invalid, because the next routine catches errors and causes failure
    
    respond_to do |format|
      if  !@collection.errors.any? && @collection.save
        format.html { redirect_to action: "show", id: @collection.id }   # url_for{@collection}
        format.json { render :show, status: :created, location: @collection }
        format.jsonld { render :show, formats: :json, status: :created, location: @collection }
      else
        @collection.errors[:description] << "failed to save new collection"
        format.html { render :new }
        format.json { render :json => {status: :bad_request, errors: @collection.errors}, status: 400}
        format.jsonld { render :json => {status: :bad_request, errors: @collection.errors}, status: 400}
      end
    end
  end



  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  # THIS IS NOT ALLOWED
  def update

  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy

  end
  
  def deprecate
    @collection.deprecated = true
    respond_to do |format|
      if @collection.errors.any? or !@collection.save
        format.html { redirect_to action: show, notice: 'Collection could not be deprecated.  Sorry, I dont know why' }
        format.json {  render :json => {status: :bad_request, errors: @collection.errors}, status: 400  }
        format.jsonld {  render :json => {status: :bad_request, errors: @collection.errors}, status: 400  }
      else
        @collection.save
        format.html { redirect_to action: show, notice: 'Collection was successfully deprecated.' }
        format.json { head :no_content }
        format.jsonld { head :no_content }
      end
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_params
      params.permit(:name, :contact, :organization, :description, :collection)
      params.permit(include_metrics: [])
    end
end
