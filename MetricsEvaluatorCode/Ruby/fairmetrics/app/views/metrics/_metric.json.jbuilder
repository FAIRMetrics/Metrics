doi_url = "https://doi.org/"
fairont = "https://purl.org/fair-ontology/"
metrics_url = "https://purl.org/fair-metrics/"
principle_url = "https://w3id.org/fair/principles/terms/"

type1= "http://purl.org/dc/dcmitype/Dataset"
type2 =    fairont + "FAIR-Metrics-Compliance-Test"


json.set! '@context', "https://w3id.org/FAIR_Evaluator/schema"

json.set! '@id', metric_url(metric)

json.set! '@type' do
	json.array! [type1, type2] 
end


metrics_url = "https://purl.org/fair-metrics/"

json.extract! metric, :name, :orcid, :creator, :description, :email, :test_of_metric, :smarturl, :created_at, :updated_at, :deprecated

json.principle principle_url + metric.principle.to_s
