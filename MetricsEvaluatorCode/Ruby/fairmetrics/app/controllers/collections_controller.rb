class CollectionsController < ApiController
#class CollectionsController < ApplicationController

#  before_action :set_collection, only: [:show, :edit, :update, :destroy]
  before_action :set_collection, only: [:show, ]

  skip_before_action :authenticate_request, only: %i[index show new collect_metrics register_metrics create]


  def collect_metrics
    @collection = Collection.find(params[:id])
    @metrics = Metric.where("name LIKE ?", "%")
  end


  def register_metrics
    @collection = Collection.find(params[:id])
    
    @collection.metrics.each do |m|
      @collection.metrics.delete(m)
      @collection.save!
    end
    @collection.metrics.each do |m|  # why do I need to do this twice?!!??   If I don't, there's one left over!
      @collection.metrics.delete(m)
      @collection.save!
    end

    metrics = params[:metrics]
    metrics.each do |m|
      metric = Metric.find(m)
      @collection.metrics << metric
    end

    respond_to do |format|
      if @collection.save
        format.html { redirect_to action: "show", id: @collection.id }   # url_for{@collection}
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end


  # GET /collections
  # GET /collections.json
  def index
    @collections = Collection.all
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections
  # POST /collections.json
  def create
    @collection = Collection.new(collection_params)
       
    respond_to do |format|
      if validate 
        if @collection.save
          format.html { redirect_to action: "collect_metrics", id: @collection.id }   # url_for{@collection}
          format.json { render :show, status: :created, location: @collection }
        else
          @collection.errors[:unknown] << "failed to save for an unknown reason"
          format.html { render :new }
          format.json { render json: @collection.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end    
    end
  end



  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        # a = "#{url_for(@collection)}"
        format.html { redirect_to @collection, notice: a + " Collection was successfully updated." }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  
  def validate
    orcid = @collection.contact
    page = fetch("http://orcid.org/#{orcid}")
    if page and !(page.body.downcase =~ /sign\sin/)
      return true
    else
      @collection.errors[:orcid] << "That was not a valid ORCiD"
      return false
    end
  end
  
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_params
      params.require(:collection).permit(:name, :contact, :organization)
    end
end
