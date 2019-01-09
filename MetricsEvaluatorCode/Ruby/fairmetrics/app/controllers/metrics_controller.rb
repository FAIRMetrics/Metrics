#class MetricsController < ApplicationController
class MetricsController < ApiController
  
  before_action :set_metric, only: [ :show, :deprecate]
  skip_before_action :authenticate_request, only: %i[index show new create deprecate], raise: false


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
    $stderr.puts metric_params['smarturl']

    errors = []
    smarturl = metric_params['smarturl'].strip
    $stderr.puts "smarturl is #{smarturl}"
    
    if known_metricuri(smarturl)
      errors << "This metric #{smarturl} already exists - creation failed"
    end

#    @metric = Metric.new(metric_params)  # this will convert API (JSON) calls into application calls v.v. params

  
    resp = fetch(smarturl)

    name = ''
    description = ''
    principle = ''
    test_of_metric = ''
    email = ''
    creator = ''
    orcid = ''
    
    if resp
      yaml = YAML.load(resp.body)
      if yaml
        name = yaml["info"]["title"]

        description = yaml["info"]["description"]

        if yaml["info"].has_key?"applies_to_principle"
                principle = yaml["info"]["applies_to_principle"]
        elsif yaml["info"].has_key?"x-applies_to_principle"
                principle = yaml["info"]["x-applies_to_principle"]
        else
                errors << "the x-applies_to_principle property was not found"
        end
        
        if yaml["info"].has_key?"x-tests_metric"
                test_of_metric = yaml["info"]["x-tests_metric"]  # TODO  undersco4e x-tests_metric
        elsif yaml["info"].has_key?"tests-metric"
                test_of_metric = yaml["info"]["tests_metric"]
        else
                errors << "the x-tests-metric property was not found"  # TODO errors could perhaps be a hash?
        end

        email = yaml["info"]["contact"]["email"]

        if yaml["info"]["contact"].has_key?"responsibleDeveloper"
                creator = yaml["info"]["contact"]["responsibleDeveloper"]
        elsif yaml["info"]["contact"].has_key?"name"
                creator = yaml["info"]["contact"]["name"]
        else
                errors << "Contact name or responsibleDeveloper is a required property in the YAML"
        end

        if yaml["info"]["contact"].has_key?"x-id"
          orcid = yaml["info"]["contact"]["x-id"]
          if validate_orcid(orcid)  # one day this should be an orcid
            $stderr.puts "Validated orcid"
          else
            errors << "'#{orcid}' is not a valid orcid."
          end
        else
          errors << "The testing endpoint did not return YAML with an info/contact/x-id, which should contain the authors ORCiD"
        end
      else
        errors << "The testing endpoint did not return YAML #{resp.body}"
      end
    else
      errors << "The testing endpoint did not respond"
    end
    
    @metric = Metric.new(metric_params)
    @metric[:smarturl] = smarturl
    @metric[:name] = name
    @metric[:description] = description
    @metric[:principle] = principle
    @metric[:test_of_metric] = test_of_metric
    @metric[:email] = email
    @metric[:creator] = creator
    @metric[:orcid] = orcid
    
    respond_to do |format|
      if errors.length == 0 and @metric.save
        format.html { redirect_to @metric, notice: 'Metric was successfully created.' }
        format.json { render :show, status: :created, location: @metric }
      else
        @metric.errors[:details].unshift *errors
        format.html { render :new }
        format.json { render :json => {status: :bad_request, errors: @metric.errors}, status: 400}
      end
    end

  end
  
  
  
  

  # PATCH/PUT /metrics/1
  # PATCH/PUT /metrics/1.json
  def update
    #respond_to do |format|
    #  if @metric.update(metric_params)
    #    format.html { redirect_to @metric, notice: 'Metric was successfully updated.' }
    #    format.json { render :show, status: :ok, location: @metric }
    #  else
    #    format.html { render :edit }
    #    format.json { render json: @metric.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # DELETE /metrics/1
  # DELETE /metrics/1.json
  def destroy
    #@metric.destroy
    #respond_to do |format|
    #  format.html { redirect_to metrics_url, notice: 'Metric was successfully destroyed.' }
    #  format.json { head :no_content }
    #end
  end

  def deprecate
    @metric.deprecated = true
    respond_to do |format|
      if @metric.errors.any? or !@metric.save
        format.html { redirect_to action: show, notice: 'Metric could not be deprecated.  Sorry, I dont know why' }
        format.json { render json: @metric.errors, status: :unprocessable_entity }
      else
        @metric.save
        format.html { redirect_to action: show, notice: 'Metric was successfully deprecated.' }
        format.json { head :no_content }
      end
    end
  end
 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_metric
      @metric = Metric.find(params[:id])
    end



    # Never trust parameters from the scary internet, only allow the white list through.
    def metric_params
      unless params.include?(:metric)  # if not, then this is an API request.  Construct the JSON to make the rest of the code identical
            jsonhash = JSON.parse(request.body.read)
            p = {metric: jsonhash}
         #   logger.debug("\n\n\nfound #{p.class} \n #{p.inspect}\n\n\n")
            params.merge!(p)
         #   logger.debug("\n\n\nfound #{params.inspect}\n\n\n")
      end
#      params.require(:metric).permit(:name, :creator, :email, :principle, :smarturl ,:description)
      params.require(:metric).permit(:smarturl)
    end

    
    def known_metricuri(url)
      # logger.debug("looking for #{url}")
      m = Metric.where('smarturl = ?', url)
      if  m.count > 0
        #logger.debug("found #{url}")
        return true  # exists
      else
        #logger.debug("didnt find #{url}")
        return false  # OK!
      end
    end
    

end
