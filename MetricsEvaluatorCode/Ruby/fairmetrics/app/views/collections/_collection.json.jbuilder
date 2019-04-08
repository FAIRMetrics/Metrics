orcid_url = "https://orcid.org/"
fairont = "https://purl.org/fair-ontology/"
metrics_url = "https://purl.org/fair-metrics/"
type1="http://purl.org/dc/dcmitype/Dataset"
type2 =    "http://www.w3.org/ns/ldp#BasicContainer"
type3 =     "http://www.w3.org/ns/prov#Collection"
type4 = fairont + "FAIR-Metrics-Collection"

# THIS JBUILDER TEMPLATE CREATES AN LDP Container
# AS JSON LD

json.set! '@id', collection_url(collection)
json.set! '@context', "https://w3id.org/FAIR_Evaluator/schema"


json.set! '@type' do
	json.array! [type1, type2, type3, type4]
end


json.set! 'http://purl.org/dc/elements/1.1/authoredBy', orcid_url + collection.contact.to_s


json.set! 'http://purl.org/dc/elements/1.1/license', 'https://creativecommons.org/licenses/by/4.0'

json.set! 'http://purl.org/dc/elements/1.1/title', collection.name

json.set! 'http://purl.org/dc/elements/1.1/creator', collection.organization

json.set! 'http://purl.org/pav/version', collection.updated_at

json.set! 'http://rdfs.org/ns/void#description', 'FAIR Metrics Evaluation Collection '  + collection.name + ' authored by ' + orcid_url + collection.contact.to_s + ".  " + collection.description

json.set! 'http://www.w3.org/ns/dcat#entities', collection.metrics.count

json.set! 'http://www.w3.org/ns/dcat#contactPoint' , orcid_url + collection.contact.to_s

json.set! 'http://www.w3.org/ns/dcat#identifier', collection_url(collection)

json.set! 'http://www.w3.org/ns/dcat#publisher', "http://fairmetrics.org"

json.set! 'http://purl.obolibrary.org/obo/IAO_0000114', collection.deprecated

json.set! 'http://www.w3.org/ns/ldp#contains' do
	json.array! collection.metrics.map {|m| metric_url(m)}
end
	


	