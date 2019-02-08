doi_url = "https://dx.doi.org/"
fairont = "https://purl.org/fair-ontology/"
metrics_url = "https://purl.org/fair-metrics/"
type1= "http://purl.org/dc/dcmitype/Dataset"
type2 =    fairont + "FAIR-Metrics-Compliance-Test"


json.set! '@context', "https://w3id.org/FAIR_Evaluator/schema"

json.set! '@id', metric_url(metric)

json.set! '@type' do
	json.array! [type1, type2] 
end


metrics_url = "https://purl.org/fair-metrics/"

json.extract! metric, :name, :orcid, :creator, :description, :email, :test_of_metric, :smarturl, :created_at, :updated_at

json.principle metrics_url + metric.principle.to_s
