# The FAIR Evaluator

The FAIR Evaluator is a Ruby on Rails application that is used to:
* register FAIR Metric Tests
* register Collections of FAIR Metric Tests
* initiate evaluations of Web resources
* explore the outcomes of evaluations

# API
[HTTP GET Operations](#gets)
* Search(See Search under POST operations)
* [Get Maturity Indicator Tests](#getmetrics)
* [Get Specific Maturity Indicator  Test](#getmetric)
* [Get Collection Creation Template](#getcollectionstemplate)
* [Get Collections](#getcollections)
* [Get Specific Collection](#getcollection)
* [Get Evaluations](#getevaluations)
* [Get Evaluation Creation Template](#getevaluationstemplate)
* [Get Evaluation Result](#getevaluationresult)

[HTTP POST Operations](#posts)
* Search
  * [Request Interface](#postsearch)
  * [Execute Search](#postsearch2)
* [Register New Maturity Indicator  Test](#createnewmetric)
* [Register New Collection](#createnewcollection)
* [Execute a New Evaluation](#createnewevaluation)


# <a name="gets"></a> HTTP GET Operations

## /

The root URL provides a (human-readable only) list of the entry-points for human exploration.


## <a name="getmetricstemplate"> /metrics/new 

Raises the Web Page for manual registration of a Metric Test

##  <a name="getmetrics"> /metrics  or /metrics.json

Provides a human-readable, or JSON serialized list of known Maturity Indicators, including their 'deprecated?' status.  These URLs respond to content-negotiation (text/html or application/json only)

sample JSON output

    curl  -L -X GET -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/metrics/

results in:

    [{
    "@context": "https://w3id.org/FAIR_Evaluator/schema",
    "@type": ["http://purl.org/dc/dcmitype/Dataset", "https://purl.org/fair-ontology/FAIR-Metrics-Compliance-Test"],
    "@id": "https://w3id.org/FAIR_Evaluator/metrics/4",
    "name": "FAIR Metrics Gen2- Unique Identifier",
    "creator": "Mark D Wilkinson",
    "email": "markw@illuminae.com",
    "smarturl": "https://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_unique_identifier",
    "created_at": "2018-12-12T02:43:20.569Z",
    "updated_at": "2018-12-12T02:43:20.569Z",
    "principle": "https://purl.org/fair-metrics/F1"
    }, {
    "@context": "https://w3id.org/FAIR_Evaluator/schema",
    "@type": ["http://purl.org/dc/dcmitype/Dataset", "https://purl.org/fair-ontology/FAIR-Metrics-Compliance-Test"],
    "@id": "https://w3id.org/FAIR_Evaluator/metrics/10.json",
    "name": "FAIR Metrics Gen2- Metadata Identifier Explicitly In Metadata",
    "creator": "Mark D Wilkinson",
    "email": "markw@illuminae.com",
    "smarturl": "https://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_identifier_in_metadata",
    "created_at": "2018-12-24T09:54:16.712Z",
    "updated_at": "2018-12-31T08:22:15.219Z",
    "principle": "https://purl.org/fair-metrics/F3"
    }, {
    "@context": "https://w3id.org/FAIR_Evaluator/schema",
    "@type": ["http://purl.org/dc/dcmitype/Dataset", "https://purl.org/fair-ontology/FAIR-Metrics-Compliance-Test"],
    "@id": "https://w3id.org/FAIR_Evaluator/metrics/11.json",
    "name": "FAIR Metrics Gen2- Metadata Identifier Explicitly In Metadata",
    "creator": "Mark D Wilkinson",
    "email": "markw@illuminae.com",
    "smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata",
    "created_at": "2018-12-31T08:04:59.636Z",
    "updated_at": "2018-12-31T08:04:59.636Z",
    "principle": "https://purl.org/fair-metrics/F3"
    }]

##  <a name="getmetric"> /metrics/{id}  or  /metrics/{id}.json

The Web Page or JSON representation of a specific Maturity Indicator Test identified by its internal Evaluator registry {id}


sample JSON output

    curl -L -X GET -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/metrics/4

results in:

    {"@context":"https://w3id.org/FAIR_Evaluator/schema",
     "@id":"https://w3id.org/FAIR_Evaluator/metrics/4",
     "@type":["http://purl.org/dc/dcmitype/Dataset","https://purl.org/fair-ontology/FAIR-Metrics-Compliance-Test"]
        "name": "FAIR Metrics Gen2- Metadata Identifier Explicitly In Metadata",
        "creator": "Mark D Wilkinson",
        "email": "markw@illuminae.com",
        "smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata",
        "created_at": "2018-12-31T08:04:59.636Z",
        "updated_at": "2018-12-31T08:04:59.636Z",
        "principle": "https://purl.org/fair-metrics/F3"
    }


##  <a name="getcollectionstemplate"> /collections/new 

Raises the Web Page for manual registration of a Maturity Indicator Collection

##  <a name="getcollections"> /collections  or /collections.json

Provides a human-readable, or JSON serialized list of known Maturity Indicator collections, including their 'deprecated?' status.  These URLs respond to content-negotiation (text/html or application/json only).  The output is in JSON-LD, and follows the schema for a [Linked Data Platform Container](https://www.w3.org/2012/ldp/wiki/Containers)

sample JSON output

    curl -L -X GET -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/collections

results in:

    [{
	"@id": "https://w3id.org/FAIR_Evaluator/collections/4",
	"@context": "https://w3id.org/FAIR_Evaluator/schema",
	"@type": ["http://purl.org/dc/dcmitype/Dataset", "http://www.w3.org/ns/ldp#BasicContainer", "http://www.w3.org/ns/prov#Collection", "https://purl.org/fair-ontology/FAIR-Metrics-Collection"],
	"http://purl.org/dc/elements/1.1/authoredBy": "https://orcid.org/0000-0001-6960-357X",
	"http://purl.org/dc/elements/1.1/license": "https://creativecommons.org/licenses/by/4.0",
	"http://purl.org/dc/elements/1.1/title": "Gen2 Three Identifier Metrics",
	"http://purl.org/dc/elements/1.1/creator": "CBGP UPM-INIA",
	"http://purl.org/pav/version": "2019-01-25T14:39:19.975Z",
	"http://rdfs.org/ns/void#description": "FAIR Metrics Evaluation Collection Gen2 Three Identifier Metrics authored by https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#entities": 3,
	"http://www.w3.org/ns/dcat#contactPoint": "https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#identifier": "https://w3id.org/FAIR_Evaluator/collections/4",
	"http://www.w3.org/ns/dcat#publisher": "http://fairmetrics.org",
	"http://www.w3.org/ns/ldp#contains": ["https://w3id.org/FAIR_Evaluator/metrics/4", "https://w3id.org/FAIR_Evaluator/metrics/5", "https://w3id.org/FAIR_Evaluator/metrics/6"]
     }]

##  <a name="getcollection"> /collections/{id}  or  /collections/{id}.json

The Web Page or JSON representation of a specific collection identified by its internal Evaluator registry {id}

sample JSON output

    curl -L -X GET -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/collections/4

results in:

    {
	"@id": "https://w3id.org/FAIR_Evaluator/collections/4",
	"@context": "https://w3id.org/FAIR_Evaluator/schema",
	"@type": ["http://purl.org/dc/dcmitype/Dataset", "http://www.w3.org/ns/ldp#BasicContainer", "http://www.w3.org/ns/prov#Collection", "https://purl.org/fair-ontology/FAIR-Metrics-Collection"],
	"http://purl.org/dc/elements/1.1/authoredBy": "https://orcid.org/0000-0001-6960-357X",
	"http://purl.org/dc/elements/1.1/license": "https://creativecommons.org/licenses/by/4.0",
	"http://purl.org/dc/elements/1.1/title": "Gen2 Three Identifier Metrics",
	"http://purl.org/dc/elements/1.1/creator": "CBGP UPM-INIA",
	"http://purl.org/pav/version": "2019-01-25T14:39:19.975Z",
	"http://rdfs.org/ns/void#description": "FAIR Metrics Evaluation Collection Gen2 Three Identifier Metrics authored by https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#entities": 3,
	"http://www.w3.org/ns/dcat#contactPoint": "https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#identifier": "https://w3id.org/FAIR_Evaluator/collections/4",
	"http://www.w3.org/ns/dcat#publisher": "http://fairmetrics.org",
	"http://www.w3.org/ns/ldp#contains": ["https://w3id.org/FAIR_Evaluator/metrics/4", "https://w3id.org/FAIR_Evaluator/metrics/5", "https://w3id.org/FAIR_Evaluator/metrics/6"]
     }


##  <a name="getevaluations"> /evaluations  or  /evaluations.json

Provides a human-readable, or JSON serialized list of known evaluations.  These URLs respond to content-negotiation (text/html or application/json only). NOTE:  'body' and 'result' are missing from this output (compared to the output of /evaluations/{id} below) so as to compress this output.

sample JSON output

    curl -L -X GET -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/evaluations

results in:

    [{
	"@id": "https://w3id.org/FAIR_Evaluator/evaluations/6",
	"@context": "https://w3id.org/FAIR_Evaluator/schema",
	"@type": ["http://purl.org/dc/dcmitype/Dataset", "https://purl.org/fair-ontology/FAIR-Evaluation-Output"],
	"collection": "https://w3id.org/FAIR_Evaluator/collections/4",
	"primaryTopic": "10.5281/zenodo.2541238",
	"title": "Test of DOI for DADA2 formatted 16S rRNA gene sequences",
	"creator": "https://orcid.org/0000-0001-6960-357X",
	"http://purl.org/pav/version": "2019-02-11T11:30:03.458Z",
	"http://rdfs.org/ns/void#description": "FAIR Metrics Evaluation: Test of DOI for DADA2 formatted 16S rRNA gene sequences; Tested identifier: evaluation.resource; generated by https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#contactPoint": "https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#identifier": "https://w3id.org/FAIR_Evaluator/evaluations/6",
	"http://www.w3.org/ns/dcat#publisher": "http://fairmetrics.org"
     }, {
	"@id": "https://w3id.org/FAIR_Evaluator/evaluations/7",
	"@context": "https://w3id.org/FAIR_Evaluator/schema",
	"@type": ["http://purl.org/dc/dcmitype/Dataset", "https://purl.org/fair-ontology/FAIR-Evaluation-Output"],
	"collection": "https://w3id.org/FAIR_Evaluator/collections/4",
	"primaryTopic": "BQJCRHHNABKAKU-KBQPJGBKSA-N",
	"title": "Test of an InchiKey",
	"creator": "https://orcid.org/0000-0001-6960-357X",
	"http://purl.org/pav/version": "2019-02-11T11:31:47.422Z",
	"http://rdfs.org/ns/void#description": "FAIR Metrics Evaluation: Test of an InchiKey; Tested identifier: evaluation.resource; generated by https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#contactPoint": "https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#identifier": "https://w3id.org/FAIR_Evaluator/evaluations/7",
	"http://www.w3.org/ns/dcat#publisher": "http://fairmetrics.org"
     }]


##  <a name="getevaluation"> /evaluations/{id}  or  /evaluations/{id}.json

Provides a human-readable, or JSON serialized outcome of a single evaluation with the id {id} in the Evaluator registry.  These URLs respond to content-negotiation (text/html or application/json only). NOTE:  'body' and 'result' contain the raw JSON that was submitted to, or returned from, a given evaluation session.  If an evaluation was created but has never been executed, these will be 'NULL'.

sample JSON output

    curl -L -X GET -D -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/evaluations/6

results in:

    {
	"@id": "https://w3id.org/FAIR_Evaluator/evaluations/6",
	"@context": "https://w3id.org/FAIR_Evaluator/schema",
	"@type": ["http://purl.org/dc/dcmitype/Dataset", "https://purl.org/fair-ontology/FAIR-Evaluation-Output"],
	"collection": "https://w3id.org/FAIR_Evaluator/collections/4",
	"primaryTopic": "10.5281/zenodo.2541238",
	"title": "Test of DOI for DADA2 formatted 16S rRNA gene sequences",
	"creator": "https://orcid.org/0000-0001-6960-357X",
	"http://purl.org/pav/version": "2019-02-11T11:30:03.458Z",
	"http://rdfs.org/ns/void#description": "FAIR Metrics Evaluation: Test of DOI for DADA2 formatted 16S rRNA gene sequences; Tested identifier: evaluation.resource; generated by https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#contactPoint": "https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#identifier": "https://w3id.org/FAIR_Evaluator/evaluations/6",
	"http://www.w3.org/ns/dcat#publisher": "http://fairmetrics.org",
	"evaluationInput": "utf8=%E2%9C%93\u0026authenticity_token=Bzl9Pz9lexbdGMdAmGmjgIhUgASiBRCGNCC9LxU4HzEHTbIJSdpx1YKaPCzj6bqg1cCC4zQ1i4Esf%2B51CE4q0w%3D%3D\u0026resource=10.5281%2Fzenodo.2541238\u0026title=Test+of+DOI+for+DADA2+formatted+16S+rRNA+gene+sequences\u0026executor=0000-0001-6960-357X\u0026commit=Execute+Metrics+Test+With+This+Collection",
	"evaluationResult": "{\"http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_unique_identifier\":[{\"@id\":\"http://linkeddata.systems//cgi-bin/FAIR_Tests/gen2_unique_identifier#10.5281/zenodo.2541238/result-2019-02-11T11:29:53+00:00\",\"@type\":[\"http://fairmetrics.org/resources/metric_evaluation_result\"],\"http://semanticscience.org/resource/SIO_000300\":[{\"@value\":\"1\",\"@type\":\"http://www.w3.org/2001/XMLSchema#int\"}],\"http://semanticscience.org/resource/SIO_000332\":[{\"@value\":\"10.5281/zenodo.2541238\",\"@language\":\"en\"}],\"http://schema.org/comment\":[{\"@value\":\"Found a Crossref DOI - pass\",\"@language\":\"en\"}],\"http://purl.obolibrary.org/obo/date\":[{\"@value\":\"2019-02-11T11:29:53+00:00\",\"@type\":\"http://www.w3.org/2001/XMLSchema#date\"}]}],\"http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_data_identifier_in_metadata\":[{\"@id\":\"http://linkeddata.systems//cgi-bin/FAIR_Tests/gen2_data_identifier_in_metadata#10.5281/zenodo.2541238/result-2019-02-11T11:29:58+00:00\",\"http://schema.org/comment\":[{\"@value\":\"Found a Crossref DOI.  \\nFound turtle text/turtle type of file by resolving GUID.  \\nWas unable to locate the data identifier in the metadata using any (common) property/predicate reserved for this purpose.  Tested SIO:is-about, SIO:0003323, schema:mainEntity, IAO:0000136, schema:codeRepository, and foaf:primaryTopic.  Sorry!\",\"@language\":\"en\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"@value\":\"0\",\"@type\":\"http://www.w3.org/2001/XMLSchema#int\"}],\"@type\":[\"http://fairmetrics.org/resources/metric_evaluation_result\"],\"http://semanticscience.org/resource/SIO_000332\":[{\"@value\":\"10.5281/zenodo.2541238\",\"@language\":\"en\"}],\"http://purl.obolibrary.org/obo/date\":[{\"@value\":\"2019-02-11T11:29:58+00:00\",\"@type\":\"http://www.w3.org/2001/XMLSchema#date\"}]}],\"http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata\":[{\"@id\":\"http://linkeddata.systems//cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata#10.5281/zenodo.2541238/result-2019-02-11T11:30:03+00:00\",\"http://purl.obolibrary.org/obo/date\":[{\"@value\":\"2019-02-11T11:30:03+00:00\",\"@type\":\"http://www.w3.org/2001/XMLSchema#date\"}],\"http://schema.org/comment\":[{\"@value\":\"Found a Crossref DOI.  \\nFound turtle text/turtle type of file by resolving GUID.  \\nFound pattern-match in metadata _:g19650800 http://schema.org/value https://doi.org/10.5281/zenodo.2541238.  This provides a partial success score.\\nFound pattern-match in metadata https://doi.org/10.5281/zenodo.2541238 http://schema.org/datePublished 2019-01-16.  This provides a partial success score.\",\"@language\":\"en\"}],\"@type\":[\"http://fairmetrics.org/resources/metric_evaluation_result\"],\"http://semanticscience.org/resource/SIO_000300\":[{\"@value\":\"0.75\",\"@type\":\"http://www.w3.org/2001/XMLSchema#float\"}],\"http://semanticscience.org/resource/SIO_000332\":[{\"@value\":\"10.5281/zenodo.2541238\",\"@language\":\"en\"}]}]}"
      }



##  <a name="getevaluationstemplate"> /collections/{id}/evaluate/template

A **Human readable Web page** (NOT FOR JSON!) providing a template to execute an evaluation using Maturity Indicator collection {id}


##  <a name="getevaluationresult"> /evaluations/{id}/result

A **Human readable Web page** (NOT FOR JSON!) describing the outcome of the evaluation  (the equivalent for Machines is /evaluations/{id}.json)


# <a name="posts"></a> HTTP POST Operations

## <a name="postsearch"> /searches/

Returns a 201 CREATED header, with a Location tag indicating the location of your search interface.  The body of the message contains a JSON Schema describing the search interface (i.e. an array of keywords)

## <a name="postsearch2"> /searches/{Location}

Searches are executed by POSTing to the URL provided to you in the "Location" tag of the response to the call above.  POST of a correctly formatted block of JSON returns a block of JSON-LD containing a list of matching Maturity Indicator (based on their 'description' property), a list of matching Collections (based on their 'description' property),  a list of matching Evaluations (based on their 'description' property), and separately, a list of Evaluations matching based on the GUID that was evaluated (these latter two are not documented in the examples below - I will fix this when I have time!  Sorry!).  The format of the list members is identical to the format of an individual Maturity Indicator or Collection descriptor (e.g. [Maturity Indicator](#getmetric); [COLLECTION](#getcollection) )

Sample JSON

     curl -L -X POST -H "Accept: application/json" -H "Content-type: application/json" -d '{"keywords": "identifier"}' https://w3id.org/FAIR_Evaluator/searches/172ad304-3a30-4c80-8265-fc47089e7f66

Response 200 OK

    {
        "@id": "https://w3id.org/FAIR_Evaluator/searches/172ad304-3a30-4c80-8265-fc47089e7f66",
	"@context": "https://w3id.org/FAIR_Evaluator/schema",
	"@type": ["http://purl.org/dc/dcmitype/Dataset", "http://schema.org/result"],
	"title": "Search Results",
	"description": "Your search results, separated into matching 'metrics' and 'collections'",
	"metrics": [{
		"id": "https://w3id.org/FAIR_Evaluator/metrics/4.json",
		"name": "FAIR Metrics Gen2- Unique Identifier",
		"creator": "Mark D Wilkinson",
		"email": "markw@illuminae.com",
		"smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_unique_identifier",
		"created_at": "2019-01-25T09:30:58.691Z",
		"updated_at": "2019-01-25T09:30:58.691Z",
		"principle": "https://purl.org/fair-metrics/F1"
	}, {
		"id": "https://w3id.org/FAIR_Evaluator/metrics/5.json",
		"name": "FAIR Metrics Gen2- Data Identifier Explicitly In Metadata",
		"creator": "Mark D Wilkinson",
		"email": "markw@illuminae.com",
		"smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_data_identifier_in_metadata",
		"created_at": "2019-01-25T09:31:17.630Z",
		"updated_at": "2019-01-25T09:31:17.630Z",
		"principle": "https://purl.org/fair-metrics/F3"
	}, {
		"id": "https://w3id.org/FAIR_Evaluator/metrics/6.json",
		"name": "FAIR Metrics Gen2- Metadata Identifier Explicitly In Metadata",
		"creator": "Mark D Wilkinson",
		"email": "markw@illuminae.com",
		"smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata",
		"created_at": "2019-01-25T09:31:32.053Z",
		"updated_at": "2019-01-25T09:31:32.053Z",
		"principle": "https://purl.org/fair-metrics/F3"
	}],
	"collections": [{
     	     "@id": "https://w3id.org/FAIR_Evaluator/collections/4",
	     "@context": "https://w3id.org/FAIR_Evaluator/schema",
	     "@type": ["http://purl.org/dc/dcmitype/Dataset", "http://www.w3.org/ns/ldp#BasicContainer", "http://www.w3.org/ns/prov#Collection", "https://purl.org/fair-ontology/FAIR-Metrics-Collection"],
	     "http://purl.org/dc/elements/1.1/authoredBy": "https://orcid.org/0000-0001-6960-357X",
	     "http://purl.org/dc/elements/1.1/license": "https://creativecommons.org/licenses/by/4.0",
	     "http://purl.org/dc/elements/1.1/title": "Gen2 Three Identifier Metrics",
	     "http://purl.org/dc/elements/1.1/creator": "CBGP UPM-INIA",
	     "http://purl.org/pav/version": "2019-01-25T14:39:19.975Z",
	     "http://rdfs.org/ns/void#description": "FAIR Metrics Evaluation Collection Gen2 Three Identifier Metrics authored by https://orcid.org/0000-0001-6960-357X",
	     "http://www.w3.org/ns/dcat#entities": 3,
	     "http://www.w3.org/ns/dcat#contactPoint": "https://orcid.org/0000-0001-6960-357X",
	     "http://www.w3.org/ns/dcat#identifier": "https://w3id.org/FAIR_Evaluator/collections/4",
	     "http://www.w3.org/ns/dcat#publisher": "http://fairmetrics.org",
	     "http://www.w3.org/ns/ldp#contains": ["https://w3id.org/FAIR_Evaluator/metrics/4", "https://w3id.org/FAIR_Evaluator/metrics/5", "https://w3id.org/FAIR_Evaluator/metrics/6"]
	}]
     }


## <a name="createnewmetric"> /metrics

POST the URL to the smartAPI interface definition (currently *must* be in YAML!) in order to register a new Maturity Indicator Test

Sample JSON

    curl -L -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata"}' https://w3id.org/FAIR_Evaluator/metrics

response 200 OK

    {
     "@context":"https://w3id.org/FAIR_Evaluator/schema",
     "@id":"https://w3id.org/FAIR_Evaluator/metrics/999",
     "@type":["http://purl.org/dc/dcmitype/Dataset","https://purl.org/fair-ontology/FAIR-Metrics-Compliance-Test"]
    "name": "FAIR Metrics Gen2- Metadata Identifier Explicitly In Metadata",
    "creator": "Mark D Wilkinson",
    "email": "markw@illuminae.com",
    "smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata",
    "created_at": "2018-12-31T08:04:59.636Z",
    "updated_at": "2018-12-31T08:04:59.636Z",
    "principle": "https://purl.org/fair-metrics/F3"
    }


## <a name="createnewcollection"> /collections

POST the JSON describing a new Maturity Indicator Collection to register that collection in the Evaluator registry.

Sample JSON

    curl -L -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"name": "JSON test Test of 2 Metrics", "contact": "0000-0001-6960-357X", "organization": "Hackathon", "description": "A collection of two identifier metrics", "include_metrics": ["http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata"]}'  https://w3id.org/FAIR_Evaluator/collections

Response 200 OK

    {
	"@id": "https://w3id.org/FAIR_Evaluator/collections/5",
	"@context": "https://w3id.org/FAIR_Evaluator/schema",
	"@type": ["http://purl.org/dc/dcmitype/Dataset", "http://www.w3.org/ns/ldp#BasicContainer", "http://www.w3.org/ns/prov#Collection", "https://purl.org/fair-ontology/FAIR-Metrics-Collection"],
	"http://purl.org/dc/elements/1.1/authoredBy": "https://orcid.org/0000-0001-6960-357X",
	"http://purl.org/dc/elements/1.1/license": "https://creativecommons.org/licenses/by/4.0",
	"http://purl.org/dc/elements/1.1/title": "JSON test Test of 2 Metrics",
	"http://purl.org/dc/elements/1.1/creator": "Hackathon",
	"http://purl.org/pav/version": "2019-02-11T13:19:49.597Z",
	"http://rdfs.org/ns/void#description": "FAIR Metrics Evaluation Collection JSON test Test of 2 Metrics authored by https://orcid.org/0000-0001-6960-357X.  A collection of two identifier metrics",
	"http://www.w3.org/ns/dcat#entities": 1,
	"http://www.w3.org/ns/dcat#contactPoint": "https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#identifier": "https://w3id.org/FAIR_Evaluator/collections/5",
	"http://www.w3.org/ns/dcat#publisher": "http://fairmetrics.org",
	"http://www.w3.org/ns/ldp#contains": ["https://w3id.org/FAIR_Evaluator/metrics/6"]
    }


## <a name="createnewevaluation"> /collections/{id}/evaluate

Send a block of JSON containing the Resource (GUID) to be evaluated, and other metadata pertaining to the identity of the individual executing the evaluation; this will initiate an evaluation of that GUID using the Maturity Indicator tests described by Collection {id} in the Evaluator registry.

Sample JSON

    curl -L -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"resource": "10.5281/zenodo.1147435", "executor":  "0000-0001-6960-357X", "title": "an exemplar evaluation of a zenodo record using two identifier metrics"}' https://w3id.org/FAIR_Evaluator/collections/5/evaluate 

Response 302 Redirect  (redirected to the URL of a newly created Evaluation http://linkeddata.systems/evaluations/{id}  with a structure similar to:

    {
	"@id": "https://w3id.org/FAIR_Evaluator/evaluations/8",
	"@context": "https://w3id.org/FAIR_Evaluator/schema",
	"@type": ["http://purl.org/dc/dcmitype/Dataset", "https://purl.org/fair-ontology/FAIR-Evaluation-Output"],
	"collection": "https://w3id.org/FAIR_Evaluator/collections/5",
	"primaryTopic": "10.5281/zenodo.1147435",
	"title": "an exemplar evaluation of a zenodo record using two identifier metrics",
	"creator": "https://orcid.org/0000-0001-6960-357X",
	"http://purl.org/pav/version": "2019-02-11T13:35:03.535Z",
	"http://rdfs.org/ns/void#description": "FAIR Metrics Evaluation: an exemplar evaluation of a zenodo record using two identifier metrics; Tested identifier: evaluation.resource; generated by https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#contactPoint": "https://orcid.org/0000-0001-6960-357X",
	"http://www.w3.org/ns/dcat#identifier": "https://w3id.org/FAIR_Evaluator/evaluations/8",
	"http://www.w3.org/ns/dcat#publisher": "http://fairmetrics.org",
	"evaluationInput": "{\"resource\": \"10.5281/zenodo.1147435\", \"executor\":  \"0000-0001-6960-357X\", \"title\": \"an exemplar evaluation of a zenodo record using two identifier metrics\"}",
	"evaluationResult": "{\"http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata\":[{\"@id\":\"http://linkeddata.systems//cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata#10.5281/zenodo.1147435/result-2019-02-11T13:35:03+00:00\",\"http://semanticscience.org/resource/SIO_000332\":[{\"@value\":\"10.5281/zenodo.1147435\",\"@language\":\"en\"}],\"http://purl.obolibrary.org/obo/date\":[{\"@value\":\"2019-02-11T13:35:03+00:00\",\"@type\":\"http://www.w3.org/2001/XMLSchema#date\"}],\"@type\":[\"http://fairmetrics.org/resources/metric_evaluation_result\"],\"http://semanticscience.org/resource/SIO_000300\":[{\"@value\":\"0.75\",\"@type\":\"http://www.w3.org/2001/XMLSchema#float\"}],\"http://schema.org/comment\":[{\"@value\":\"Found a Crossref DOI.  \\nFound turtle text/turtle type of file by resolving GUID.  \\nFound pattern-match in metadata _:g27336200 http://schema.org/value https://doi.org/10.5281/zenodo.1147435.  This provides a partial success score.\\nFound pattern-match in metadata https://doi.org/10.5281/zenodo.1147435 http://schema.org/schemaVersion http://datacite.org/schema/kernel-4.  This provides a partial success score.\",\"@language\":\"en\"}]}]}"
     }





