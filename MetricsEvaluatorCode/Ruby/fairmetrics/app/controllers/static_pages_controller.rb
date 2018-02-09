class StaticPagesController < ApplicationController
  def home
  end

  def show 
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
  
    render template: "static_pages/about"
  end


  def help
  end

  def about
  end
end
