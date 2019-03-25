class SearchesController < ApiController


  skip_before_action :authenticate_request, only: %i[index execute show new]


  # GET /search
  # GET /search.json
  def index
    respond_to do |format|
        format.html { redirect_to action: new, status: 302  }
        format.json { redirect_to action: new, status: 302  }
        format.jsonld { redirect_to action: new, status: 302  }
    end
  end



  # GET /searches/new
  # GET /searches
  def new
	uuid = SecureRandom.uuid
	@new_url = searches_url + "/" + uuid   # creates http://localhost/search/123-34552-adsfrjha-234
	response.set_header("Location", @new_url)
    respond_to do |format|
        format.html { render :new, status: 201  }
        format.json { render :new,   status: 201  }
        format.jsonld { render :new, formats: :json,  status: 201  }
    end
	
  end

  # GET /searches/1
  # GET /searches/1.json
  def show
    respond_to do |format|
        format.html { render :expired, status: 410  }
        format.json { render :expired, status: 410  }
        format.jsonld { render :expired, formats: :json, status: 410  }
    end
  end
  
  # POST /searches/1
  def execute
    logger.debug "BODY: #{request.body}\n\n\n"
    keywords = search_params[:keywords]
    allkeys = keywords.split(",")
    @metrics = Array.new
    @collections = Array.new
    @URL = request.original_url
    allkeys.each do |key|
      key.strip!
      @metrics.concat(Metric.where("description LIKE ?", "%#{key}%"))
    end
    allkeys.each do |key|
      key.strip!
      @collections.concat(Collection.where("description LIKE ?", "%#{key}%"))
    end
    
    respond_to do |format|
        format.html { render :results, status: 200  }
        format.json { render :results,   status: 200  }
        format.jsonld { render :results, formats: :json,   status: 200  }
    end

  end




  

  private


    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.permit(:keywords)
      #params.permit(:search).permit(:keywords)
    end
end
