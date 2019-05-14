type1="http://purl.org/dc/dcmitype/Dataset"
type2 = "http://schema.org/result"

# THIS JBUILDER TEMPLATE CREATES AN LDP Container
# AS JSON LD

json.set! '@id', @URL
json.set! '@context', "https://w3id.org/FAIR_Evaluator/schema#"


json.set! '@type' do
	json.array! [type1, type2]
end

json.set! 'title', "Search Results"
json.set! 'description', "Your search results, separated into matching 'metrics','collections', 'evaluations_by_id' (matched by tested URI), and 'evaluations' (matched by keyword search against Title)"

json.set! 'metrics' do
	json.array! @metrics, partial: 'metrics/metric', as:  :metric
end

json.set! 'collections' do
	json.array! @collections, partial: 'collections/collection', as: :collection
end

json.set! 'evaluations' do
	json.array! @evaluations, partial: 'evaluations/evaluation', as:  :evaluation
end


json.set! 'evaluations_by_id' do
	json.array! @evals_by_id, partial: 'evaluations/evaluation', as:  :evaluation
end
