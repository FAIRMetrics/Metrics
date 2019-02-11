module SharedFunctions
  extend ActiveSupport::Concern

  included do
    helper_method :fetch, :resolve, :validate_orcid
  end

require 'uri'
require 'net/http'
require 'openssl'

  def validate_orcid(orcid)
    return false unless orcid
    orcid.gsub!(/\s/, "+")
    page = fetch("http://orcid.org/#{orcid}")
    #logger.debug("\n\n\n\n\n\n\nPAGE: #{page.class}\n\n\n\n\n\n\n") 
    if page and !(page.body.downcase =~ /sign\sin/)
      return true
    else
      #logger.debug("\n\n\n\n\n\n\nADDING ERROR\n\n\n\n\n\n\n") 
      return false
    end
  end



  def fetch(uri_str)  # we create a \"fetch\" routine that does some basic error-handling.  \n",
   str = URI::encode(uri_str)
   str = resolve(str)
   address = URI(uri_str)  # create a \"URI\" object (Uniform Resource Identifier: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)\n",
   response = Net::HTTP.get_response(address)  # use the Net::HTTP object \"get_response\" method\n",
											     # to call that address\n,
  
    case response   # the \"case\" block allows you to test various conditions... it is like an \"if\", but cleaner!\n,
	  when Net::HTTPSuccess then  # when response Object is of type Net::HTTPSuccess\n",
	    # successful retrieval of web page\n",
	    return response  # return that response object to the main code\n",
	  else
	    #raise Exception, "Something went wrong... the call to #{uri_str} failed; type #{response.class}"
	    # note - if you want to learn more about Exceptions, and error-handling\n",
	    # read this page:  http://rubylearning.com/satishtalim/ruby_exceptions.html  \n",
	    # you can capture the Exception and do something useful with it!\n",
	    response = false
	    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    end
  end


   # this returns the URI that results from all redirects, etc.
  def resolve(uri_str, agent = 'curl/7.43.0', max_attempts = 10, timeout = 10)
    attempts = 0
    max_attempts = 5
    cookie = nil

    # is it a DOI?
    if (uri_str.match(/^(10.\d{4,9}\/[-\._;()\/:A-Z0-9]+$)/i))
      uri_str = "http://dx.doi.org/#{uri_str}"  # convert to resolvable DOI URL
    end


    until attempts >= max_attempts
      attempts += 1

      url = URI.parse(uri_str)
      http = Net::HTTP.new(url.host, url.port)
      http.open_timeout = timeout
      http.read_timeout = timeout
      path = url.path
      path = '/' if path == ''
      path += '?' + url.query unless url.query.nil?

      params = { 'User-Agent' => agent, 'Accept' => '*/*' }
      params['Cookie'] = cookie unless cookie.nil?
      request = Net::HTTP::Get.new(path, params)

      if url.instance_of?(URI::HTTPS)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = http.request(request)

      case response
        when Net::HTTPSuccess then
          break
        when Net::HTTPRedirection then
          location = response['Location']
          cookie = response['Set-Cookie']
          new_uri = URI.parse(location)
          uri_str = if new_uri.relative?
                      url + location
                    else
                      new_uri.to_s
                    end
        else
          logger.debug "\n\nUnexpected response from #{url.inspect}: " + response.inspect + "\n\n"
      end
    end
    logger.debug "\n\nToo many http redirects from  #{url.inspect}:\n\n" if attempts == max_attempts

    uri_str
    # response.body
  end
  
  
end
