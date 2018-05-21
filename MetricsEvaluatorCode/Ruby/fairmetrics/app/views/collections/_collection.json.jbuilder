doi_url = "https://dx.doi.org/"

json.extract! collection, :id, :name, :organization, :created_at, :updated_at
json.contact doi_url + collection.contact.to_s
json.url collection_url(collection, format: :json)

root_url = "http://linkeddata.systems:3000/metrics/"
metrics_url = "https://purl.org/fair-metrics/"
json.metrics collection.metrics do |metric|
	
	json.id root_url + metric.id.to_s
	json.name metric.name
	json.creator doi_url + metric.creator
	json.email metric.email
	json.principle metrics_url + metric.principle.to_s
	json.smarturl metric.smarturl
	
end
	