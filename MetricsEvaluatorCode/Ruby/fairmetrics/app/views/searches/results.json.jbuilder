type1="http://purl.org/dc/dcmitype/Dataset"
type2 = "http://schema.org/result"

# THIS JBUILDER TEMPLATE CREATES AN LDP Container
# AS JSON LD

json.set! '@id', @URL
json.set! '@context', "https://w3id.org/FAIR_Evaluator/schema"


json.set! '@type' do
	json.array! [type1, type2]
end

json.set! 'title', "Search Results"
json.set! 'description', "Your search results, separated into matching 'metrics' and 'collections'"

json.set! 'metrics' do
	json.array! @metrics, partial: 'metrics/metric', as:  :metric
end

json.set! 'collections' do
	json.array! @collections, partial: 'collections/collection', as: :collection
end

