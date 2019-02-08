class StaticPagesController < ApplicationController


  def home 
    @result = []
    Rails.application.routes.routes.each do |route|
      path = route.path.spec.to_s
      if (path.starts_with?("/") && !path.match("rails"))
        next if path.match("assets")
        next if path.match("cable")
        path.gsub!(/\(.*\)/, '')
        @result << path 
      end
    end
    @result.uniq!
  
    render template: "static_pages/home"
  end

  def terms 
    @result = []
    Rails.application.routes.routes.each do |route|
      path = route.path.spec.to_s
      if (path.starts_with?("/") && !path.match("rails"))
        next if path.match("assets")
        next if path.match("cable")
        path.gsub!(/\(.*\)/, '')
        @result << path 
      end
    end
    @result.uniq!
  
    render template: "static_pages/tos"
  end

  def license 
    @result = []
    Rails.application.routes.routes.each do |route|
      path = route.path.spec.to_s
      if (path.starts_with?("/") && !path.match("rails"))
        next if path.match("assets")
        next if path.match("cable")
        path.gsub!(/\(.*\)/, '')
        @result << path 
      end
    end
    @result.uniq!
  
    render template: "static_pages/license"
  end


  def interface
    @result = []
    Rails.application.routes.routes.each do |route|
      path = route.path.spec.to_s
      if (path.starts_with?("/") && !path.match("rails"))
        next if path.match("assets")
        next if path.match("cable")
        path.gsub!(/\(.*\)/, '')
        @result << path 
      end
    end
    @result.uniq!
  
    # need the formats: option to force Rails to look for the template with the .yaml extension
    render template: "static_pages/interface", content_type: "application/x-yaml", formats: ["yaml"]
  end

  def schema
    render "schema.jsonld",  formats: [:jsonld]
  
  end
  
  def help
  end

  def about
  end
end
