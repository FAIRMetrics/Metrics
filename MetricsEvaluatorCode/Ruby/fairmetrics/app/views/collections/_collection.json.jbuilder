doi_url = "https://dx.doi.org/"
root_url = "http://linkeddata.systems:3000/metrics/"
metrics_url = "https://purl.org/fair-metrics/"
type1="http://purl.org/dc/dcmitype/Dataset"
type2 =    "http://www.w3.org/ns/ldp#BasicContainer"
type3 =     "http://www.w3.org/ns/prov#Collection"

# THIS JBUILDER TEMPLATE CREATES AN LDP Container
# AS JSON LD

json.set! '@id', collection_url(collection, format: :json)


json.set! '@type' do
	json.array! [type1, type2, type3] do |type|
		json.set! '@id', type
	end
end


json.set! 'http://purl.org/dc/elements/1.1/authoredBy' do
	json.set! '@id', doi_url + collection.contact.to_s
end


json.set! 'http://purl.org/dc/elements/1.1/license' do
	json.set! '@id', 'https://creativecommons.org/licenses/by/4.0'
end

json.set! 'http://purl.org/dc/elements/1.1/title' do
	json.set! '@value', collection.name
end

json.set! 'http://purl.org/dc/elements/1.1/creator' do
	json.set! '@value', collection.organization
end


json.set! 'http://purl.org/pav/version' do
	json.set! '@value', collection.updated_at
end


json.set! 'http://rdfs.org/ns/void#description' do
	json.set! '@value', 'FAIR Metrics Evaluation Collection '  + collection.name + ' authored by ' + doi_url + collection.contact.to_s
end


json.set! 'http://www.w3.org/ns/dcat#entities' do
	json.set! '@value', collection.metrics.count
end


json.set! 'http://www.w3.org/ns/dcat#contactPoint' do
	json.set! '@id', doi_url + collection.contact.to_s
end


json.set! 'http://www.w3.org/ns/dcat#identifier' do
	json.set! '@id', collection_url(collection, format: :json)
end

json.set! 'http://www.w3.org/ns/dcat#publisher' do
	json.set! '@id', "http://fairmetrics.org"
end


json.set! 'http://www.w3.org/ns/ldp#contains' do
	json.array! collection.metrics do |metric|
		json.set! '@id', root_url + metric.id.to_s
	end
end


	