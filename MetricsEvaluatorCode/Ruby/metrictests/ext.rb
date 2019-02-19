require 'json'
require './fair_metrics_utilities.rb'

m = Utils::MetadataObject.new
guid = "https://www.go-fair.org/fair-principles/"
	
metadata = Utils::resolveit(guid)  # this is where the magic happens!

g = metadata.graph
query = SPARQL.parse("select ?o where {?s ?p ?o  FILTER(CONTAINS(lcase(str(?p)), 'title'))}")
results = query.execute(g)
puts
puts

