module SharedFunctions
  extend ActiveSupport::Concern

  included do
    helper_method :fetch
  end

	def fetch(uri_str)  # we create a \"fetch\" routine that does some basic error-handling.  \n",
	 address = URI(uri_str)  # create a \"URI\" object (Uniform Resource Identifier: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)\n",
	 response = Net::HTTP.get_response(address)  # use the Net::HTTP object \"get_response\" method\n",
												   # to call that address\n,
	
	  case response   # the \"case\" block allows you to test various conditions... it is like an \"if\", but cleaner!\n,
		when Net::HTTPSuccess then  # when response Object is of type Net::HTTPSuccess\n",
		  # successful retrieval of web page\n",
		  return response  # return that response object to the main code\n",
		else
		  raise Exception, "Something went wrong... the call to #{uri_str} failed; type #{response.class}"
		  # note - if you want to learn more about Exceptions, and error-handling\n",
		  # read this page:  http://rubylearning.com/satishtalim/ruby_exceptions.html  \n",
		  # you can capture the Exception and do something useful with it!\n",
		  response = False
		  return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
	  end
	end
	
end