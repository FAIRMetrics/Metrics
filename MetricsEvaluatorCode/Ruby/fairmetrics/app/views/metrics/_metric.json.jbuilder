doi_url = "https://dx.doi.org/"
metrics_url = "https://purl.org/fair-ontology/"
type1= "http://purl.org/dc/dcmitype/Dataset"
type2 =    metrics_url + "FAIR-Metrics-Compliance-Test"

# THIS JBUILDER TEMPLATE CREATES AN LDP Container
# AS JSON LD

json.set! '@context', "https://w3id.org/FAIR_Evaluator/schema.json"

json.set! '@id', metric_url(metric)

json.set! '@type' do
	json.array! [type1, type2] 
end


metrics_url = "https://purl.org/fair-metrics/"

json.id metric_url(metric, format: :json)
json.extract! metric, :name, :creator, :email, :smarturl, :created_at, :updated_at

json.principle metrics_url + metric.principle.to_s
