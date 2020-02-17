module SharedFunctions
  extend ActiveSupport::Concern

  included do
    helper_method :fetch, :resolve, :validate_orcid
  end

require 'uri'
require 'net/http'
require 'openssl'
require 'rest-client'

  def validate_orcid(orcid)
#    return false unless orcid
#    orcid.gsub!(/\s/, "+")
#    page =  RestClient::Request.execute :method => :get, :url => "https://orcid.org/#{orcid}", :ssl_version => 'SSLv23'
#    page = fetch_rdf("http://orcid.org/#{orcid}")
#    logger.debug("\n\n\n\n\n\n\nPAGE: #{page.class}\n\n\n\n\n\n\n") 
#    logger.debug("\n\n\n\n\n\n\nPAGE: #{page.body}\n\n\n\n\n\n\n") 
#    if page and page.body.downcase =~ /orcid-identifier/
      return true
#    else
#      logger.debug("\n\n\n\n\n\n\nADDING ERROR\n\n\n\n\n\n\n") 
#      return true
#    end
  end



  def fetch(url)  # we create a \"fetch\" routine that does some basic error-handling.  \n",

    if (url.match(/^(10.\d{4,9}\/[-\._;()\/:A-Z0-9]+$)/i))
      url = "https://doi.org/#{url}"  # convert to resolvable DOI URL
    end
		begin
			response = RestClient::Request.execute({
					method: :get,
					url: url.to_s,
					#user: user,
					#password: pass,
					})
			return response
		rescue RestClient::ExceptionWithResponse => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue RestClient::Exception => e
			$stderr.puts e.response
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		rescue Exception => e
			$stderr.puts e
			response = false
			return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
		end		  # you can capture the Exception and do something useful with it!\n",

  end



   # this returns the URI that results from all redirects, etc.
  #def resolve(uri_str, agent = 'curl/7.43.0', max_attempts = 10, timeout = 10)
  #  attempts = 0
  #  max_attempts = 5
  #  cookie = nil
  #
  #  # is it a DOI?
  #
  #
  #  until attempts >= max_attempts
  #    attempts += 1
  #
  #    url = URI.parse(uri_str)
  #    http = Net::HTTP.new(url.host, url.port)
  #    http.open_timeout = timeout
  #    http.read_timeout = timeout
  #    path = url.path
  #    path = '/' if path == ''
  #    path += '?' + url.query unless url.query.nil?
  #
  #    params = { 'User-Agent' => agent, 'Accept' => '*/*' }
  #    params['Cookie'] = cookie unless cookie.nil?
  #    request = Net::HTTP::Get.new(path, params)
  #
  #    if url.instance_of?(URI::HTTPS)
  #      http.use_ssl = true
  #      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #    end
  #    response = http.request(request)
  #
  #    case response
  #      when Net::HTTPSuccess then
  #        break
  #      when Net::HTTPRedirection then
  #        location = response['Location']
  #        cookie = response['Set-Cookie']
  #        new_uri = URI.parse(location)
  #        uri_str = if new_uri.relative?
  #                    url + location
  #                  else
  #                    new_uri.to_s
  #                  end
  #      else
  #        logger.debug "\n\nUnexpected response from #{url.inspect}: " + response.inspect + "\n\n"
  #    end
  #  end
  #  logger.debug "\n\nToo many http redirects from  #{url.inspect}:\n\n" if attempts == max_attempts
  #
  #  uri_str
  #  # response.body
  #endy

  
end
