class MetricsController < ApplicationController
  before_action :set_metric, only: [ :show, :edit, :update, :destroy]

  # GET /metrics
  # GET /metrics.json
  def index
    @metrics = Metric.all
  end

  # GET /metrics/1
  # GET /metrics/1.json
  def show
  end

  # GET /metrics/new
  def new
    @metric = Metric.new
    @metric
  end

  # GET /metrics/1/edit
  def edit
  end

  # POST /metrics
  # POST /metrics.json
  def create

    @metric = Metric.new(metric_params)
    url = @metric[:smarturl]
    url.strip!
    
    resp = fetch(url)
    if resp
      yaml = YAML.load(resp.body)
      if yaml
#        flash[:success] = "Metric Created " + yaml["info"]["title"]
        @metric[:name] = yaml["info"]["title"]
        @metric[:description] = yaml["info"]["description"]
        @metric[:principle] = yaml["info"]["applies_to_principle"]
        @metric[:email] = yaml["info"]["contact"]["email"]
        @metric[:creator] = yaml["info"]["contact"]["responsibleDeveloper"] or yaml["info"]["contact"]["responsibleDeveloper"] or "Unidentified"
        @collection = Collection.where("name = ?", "__ALL__METRICS")
        collect = @collection.first
        @metric[:collection_id] = collect.id
        respond_to do |format|
          if @metric.save
            collect.metrics << @metric
            format.html { redirect_to @metric, notice: 'Metric was successfully created.' }
            format.json { render :show, status: :created, location: @metric }
          else
            format.html { render :new }
            format.json { render json: @metric.errors, status: :unprocessable_entity }
          end
        end
        return
      else
        flash[:failure] = "not yaml #{resp.body}"
        redirect_to @metric
        return
      end
    else 
      flash[:failure] = "bad response"
      redirect_to @metric
      return
    end
    
  end

  # PATCH/PUT /metrics/1
  # PATCH/PUT /metrics/1.json
  def update
    respond_to do |format|
      if @metric.update(metric_params)
        format.html { redirect_to @metric, notice: 'Metric was successfully updated.' }
        format.json { render :show, status: :ok, location: @metric }
      else
        format.html { render :edit }
        format.json { render json: @metric.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metrics/1
  # DELETE /metrics/1.json
  def destroy
    @metric.destroy
    respond_to do |format|
      format.html { redirect_to metrics_url, notice: 'Metric was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_metric
      @metric = Metric.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def metric_params
      params.require(:metric).permit(:name, :creator, :email, :principle, :smarturl ,:description)
    end



    def fetch(uri_str)  # we create a "fetch" routine that does some basic error-handling.  
    
      address = URI(uri_str)  # create a "URI" object (Uniform Resource Identifier: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
      response = Net::HTTP.get_response(address)  # use the Net::HTTP object "get_response" method
                                                   # to call that address
    
      case response   # the "case" block allows you to test various conditions... it is like an "if", but cleaner!
        when Net::HTTPSuccess then  # when response Object is of type Net::HTTPSuccess
          # successful retrieval of web page
          return response  # return that response object to the main code
        else
          raise Exception, "Something went wrong... the call to #{uri_str} failed; type #{response.class}"
          # note - if you want to learn more about Exceptions, and error-handling
          # read this page:  http://rubylearning.com/satishtalim/ruby_exceptions.html  
          # you can capture the Exception and do something useful with it!
          response = False
          return response  # now we are returning 'False', and we will check that with an "if" statement in our main code
      end 
    end

end
