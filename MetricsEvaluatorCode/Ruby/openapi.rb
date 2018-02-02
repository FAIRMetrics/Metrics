require 'openapi'
require 'openapi/client'
require 'net/http'
require 'open_api_parser'

json = Net::HTTP.get('petstore.swagger.io', '/v2/swagger.json')

File.open('openapi', 'w') do |afile|
  afile.puts json 
end

specification = OpenApiParser::Specification.resolve("openapi")  # will also validate document to some extent before I do my parsing

json = specification.to_json
p = JSON.parse(json)

paths = p["paths"].keys   # ["/pet", "/pet/findByStatus", "/pet/findByTags",...]

paths.each do |path|
  methods = p["paths"][path].keys
  methods.each do |method|
    puts "PATH: #{path}   METHOD:  #{method}"
    endpoint = specification.endpoint(path, method)
    next unless endpoint
    begin
      puts endpoint.path_schema
    rescue
      puts endpoint.query_schema
    end
    puts; puts
  end
  
end



a = OpenAPI::Client.new(:site => "http://petstore.swagger.io/v2/", :request_timeout => 60 )
puts a.api_methods
x = a.do_request('get', 'pet/1', params: {}, body: nil, headers: {}, options: {:skip_auth => true})

puts x
