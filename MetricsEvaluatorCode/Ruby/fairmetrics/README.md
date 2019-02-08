# The FAIR Evaluator

The FAIR Evaluator is a Ruby on Rails application that is used to:
* register FAIR Metric Tests
* register Collections of FAIR Metric Tests
* initiate evaluations of Web resources
* explore the outcomes of evaluations

# API
[HTTP GET Operations](#gets)
* Search(See Search under POST operations)
* [Get Metric Tests](#getmetrics)
* [Get Specific Metric Test](#getmetric)
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
* [Register New Metric Test](#createnewmetric)
* [Register New Collection](#createnewcollection)
* [Execute a New Evaluation](#createnewevaluation)

(the demonstration Evaluator is running at **CURRENTLY OFFLINE FOR REDESIGN** All paths below are relative to this root.

# <a name="gets"></a> HTTP GET Operations

## /

The root URL provides a (human-readable only) list of the entry-points for human exploration.


## <a name="getmetricstemplate"> /metrics/new 

Raises the Web Page for manual registration of a Metric Test

##  <a name="getmetrics"> /metrics  or /metrics.json

Provides a human-readable, or JSON serialized list of known metrics, including their 'deprecated?' status.  These URLs respond to content-negotiation (text/html or application/json only)

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

The Web Page or JSON representation of a specific Metric Test identified by its internal Evaluator registry {id}


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

Raises the Web Page for manual registration of a Metric Collection

##  <a name="getcollections"> /collections  or /collections.json

Provides a human-readable, or JSON serialized list of known metric collections, including their 'deprecated?' status.  These URLs respond to content-negotiation (text/html or application/json only).  The output is in JSON-LD, and follows the schema for a [Linked Data Platform Container](https://www.w3.org/2012/ldp/wiki/Containers)

sample JSON output

    curl -L -X GET -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/collections

results in:

    [{
      "@id": "https://w3id.org/FAIR_Evaluator/collections/1.json",
      "@type": [{
        "@id": "http://purl.org/dc/dcmitype/Dataset"
      }, {
        "@id": "http://www.w3.org/ns/ldp#BasicContainer"
      }, {
        "@id": "http://www.w3.org/ns/prov#Collection"
      }],
      "http://purl.org/dc/elements/1.1/authoredBy": {
        "@id": "https://dx.doi.org/0000-0001-6960-357X"
      },
      "http://purl.org/dc/elements/1.1/license": {
        "@id": "https://creativecommons.org/licenses/by/4.0"
      },
      "http://purl.org/dc/elements/1.1/title": {
        "@value": "MarkTest"
      },
      "http://purl.org/dc/elements/1.1/creator": {
        "@value": "BioHackathon2018"
      },
      "http://purl.org/pav/version": {
        "@value": "2018-12-24T13:14:50.060Z"
      },
      "http://rdfs.org/ns/void#description": {
        "@value": "FAIR Metrics Evaluation Collection MarkTest authored by https://dx.doi.org/0000-0001-6960-357X"
      },
      "http://www.w3.org/ns/dcat#entities": {
        "@value": 0
      },
      "http://www.w3.org/ns/dcat#contactPoint": {
        "@id": "https://dx.doi.org/0000-0001-6960-357X"
      },
      "http://www.w3.org/ns/dcat#identifier": {
        "@id": "https://w3id.org/FAIR_Evaluator/collections/1.json"
      },
      "http://www.w3.org/ns/dcat#publisher": {
        "@id": "http://fairmetrics.org"
      },
      "http://www.w3.org/ns/ldp#contains": [{
          "@id": "https://w3id.org/FAIR_Evaluator/metrics/9"
        }, {
          "@id": "https://w3id.org/FAIR_Evaluator/metrics/10"
        }, {
          "@id": "https://w3id.org/FAIR_Evaluator/metrics/11"
        }]
    }]

##  <a name="getcollection"> /collections/{id}  or  /collections/{id}.json

The Web Page or JSON representation of a specific collection identified by its internal Evaluator registry {id}

sample JSON output

    curl -L -X GET -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/collections/5

results in:

        {
            "@id": "https://w3id.org/FAIR_Evaluator/collections/5.json",
            "@type": [{
                "@id": "http://purl.org/dc/dcmitype/Dataset"
            }, {
                "@id": "http://www.w3.org/ns/ldp#BasicContainer"
            }, {
                "@id": "http://www.w3.org/ns/prov#Collection"
            }],
            "http://purl.org/dc/elements/1.1/authoredBy": {
                "@id": "https://dx.doi.org/0000-0001-6960-357X"
            },
            "http://purl.org/dc/elements/1.1/license": {
                "@id": "https://creativecommons.org/licenses/by/4.0"
            },
            "http://purl.org/dc/elements/1.1/title": {
                "@value": "JSON Test 3"
            },
            "http://purl.org/dc/elements/1.1/creator": {
                "@value": "Hackathon"
            },
            "http://purl.org/pav/version": {
                "@value": "2018-12-24T12:32:14.011Z"
            },
            "http://rdfs.org/ns/void#description": {
                "@value": "FAIR Metrics Evaluation Collection JSON Test 3 authored by https://dx.doi.org/0000-0001-6960-357X"
            },
            "http://www.w3.org/ns/dcat#entities": {
                "@value": 2
            },
            "http://www.w3.org/ns/dcat#contactPoint": {
                "@id": "https://dx.doi.org/0000-0001-6960-357X"
            },
            "http://www.w3.org/ns/dcat#identifier": {
                "@id": "http://localhost:3000/collections/5.json"
            },
            "http://www.w3.org/ns/dcat#publisher": {
                "@id": "http://fairmetrics.org"
            },
            "http://www.w3.org/ns/ldp#contains": [{
                "@id": "https://w3id.org/FAIR_Evaluator/metrics/9"
            }, {
                "@id": "https://w3id.org/FAIR_Evaluator/metrics/10"
            }]
        }


##  <a name="getevaluations"> /evaluations  or  /evaluations.json

Provides a human-readable, or JSON serialized list of known evaluations.  These URLs respond to content-negotiation (text/html or application/json only). NOTE:  'body' and 'result' contain the raw JSON that was submitted to, or returned from, a given evaluation session.  If an evaluation was created but has never been executed, these will be 'NULL'.

sample JSON output

    curl -L -X GET -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/evaluations

results in:

    [{
        "id": 12,
        "collection": "1",
        "resource": "https://www.uniprot.org/uniprot/P05067",
        "body": "{\"https://w3id.org/FAIR_Evaluator/metrics/1\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"spec\":\"https://fairsharing.org/bsg-s001182\"},\"https://w3id.org/FAIR_Evaluator/metrics/2\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"persistence_doc\":\"https://fairsharing.org/bsg-s001182\"},\"https://w3id.org/FAIR_Evaluator/metrics/3\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"metadata\":\"https://www.uniprot.org/uniprot/P05067\",\"format\":\"https://fairsharing.org/FAIRsharing.p77ph9\"},\"https://w3id.org/FAIR_Evaluator/metrics/4\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"metadata\":\"https://www.uniprot.org/uniprot/P05067\",\"identifier\":\"https://www.uniprot.org/uniprot/P05067\"},\"https://w3id.org/FAIR_Evaluator/metrics/5\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"search_uri\":\"https://www.uniprot.org/uniprot/?query=A4_HUMAN\"}}",
        "result": "{\"https://w3id.org/FAIR_Evaluator/metrics/1\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_unique_identifier/result#1544432741\":{\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:05:41\",\"type\":\"literal\",\"datatype\":\"xsd:dateTime\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_unique_identifier/result#1544432741\",\"type\":\"uri\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/2\":{\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_persistence/result#1544432753\",\"type\":\"uri\"}]},\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_persistence/result#1544432753\":{\"http://purl.obolibrary.org/obo/date\":[{\"type\":\"literal\",\"datatype\":\"xsd:dateTime\",\"value\":\"2018-12-10T09:05:53\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/3\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_machine_readable_metadata/result#1544432765\":{\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}],\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:06:05\",\"datatype\":\"xsd:dateTime\",\"type\":\"literal\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_machine_readable_metadata/result#1544432765\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/4\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#1544432779\":{\"http://schema.org/comment\":[{\"value\":\"There was no identifier https://www.uniprot.org/uniprot/P05067 in document at https://www.uniprot.org/uniprot/P05067\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"0\",\"type\":\"literal\"}],\"http://purl.obolibrary.org/obo/date\":[{\"datatype\":\"xsd:dateTime\",\"type\":\"literal\",\"value\":\"2018-12-10T09:06:19\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#1544432779\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/5\":{\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_searchable_index/result#1544432795\"}]},\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_searchable_index/result#1544432795\":{\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:06:35\",\"datatype\":\"xsd:dateTime\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://schema.org/comment\":[{\"type\":\"literal\",\"value\":\"Failed to find the UUID in the output from  'https://www.uniprot.org/uniprot/?query=A4_HUMAN'\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"0\",\"type\":\"literal\"}]}}}",
        "executor": "0000-0001-6960-357X",
        "title": "UniProt A4_HUMAN",
        "created_at": "2018-12-10T09:05:28.883Z",
        "updated_at": "2018-12-10T09:23:41.245Z"
      }]


##  <a name="getevaluation"> /evaluations/{id}  or  /evaluations/{id}.json

Provides a human-readable, or JSON serialized outcome of a single evaluation with the id {id} in the Evaluator registry.  These URLs respond to content-negotiation (text/html or application/json only). NOTE:  'body' and 'result' contain the raw JSON that was submitted to, or returned from, a given evaluation session.  If an evaluation was created but has never been executed, these will be 'NULL'.

sample JSON output

    curl -L -X GET -D -H "Content-Type: application/json" -H "Accept: application/json" https://w3id.org/FAIR_Evaluator/evaluations/11

results in:

    {
        "id": 12,
        "collection": "1",
        "resource": "https://www.uniprot.org/uniprot/P05067",
        "body": "{\"https://w3id.org/FAIR_Evaluator/metrics/1\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"spec\":\"https://fairsharing.org/bsg-s001182\"},\"https://w3id.org/FAIR_Evaluator/metrics/2\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"persistence_doc\":\"https://fairsharing.org/bsg-s001182\"},\"https://w3id.org/FAIR_Evaluator/metrics/3\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"metadata\":\"https://www.uniprot.org/uniprot/P05067\",\"format\":\"https://fairsharing.org/FAIRsharing.p77ph9\"},\"https://w3id.org/FAIR_Evaluator/metrics/4\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"metadata\":\"https://www.uniprot.org/uniprot/P05067\",\"identifier\":\"https://www.uniprot.org/uniprot/P05067\"},\"https://w3id.org/FAIR_Evaluator/metrics/5\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"search_uri\":\"https://www.uniprot.org/uniprot/?query=A4_HUMAN\"}}",
        "result": "{\"https://w3id.org/FAIR_Evaluator/metrics/1\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_unique_identifier/result#1544432741\":{\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:05:41\",\"type\":\"literal\",\"datatype\":\"xsd:dateTime\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_unique_identifier/result#1544432741\",\"type\":\"uri\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/2\":{\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_persistence/result#1544432753\",\"type\":\"uri\"}]},\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_persistence/result#1544432753\":{\"http://purl.obolibrary.org/obo/date\":[{\"type\":\"literal\",\"datatype\":\"xsd:dateTime\",\"value\":\"2018-12-10T09:05:53\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/3\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_machine_readable_metadata/result#1544432765\":{\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}],\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:06:05\",\"datatype\":\"xsd:dateTime\",\"type\":\"literal\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_machine_readable_metadata/result#1544432765\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/4\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#1544432779\":{\"http://schema.org/comment\":[{\"value\":\"There was no identifier https://www.uniprot.org/uniprot/P05067 in document at https://www.uniprot.org/uniprot/P05067\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"0\",\"type\":\"literal\"}],\"http://purl.obolibrary.org/obo/date\":[{\"datatype\":\"xsd:dateTime\",\"type\":\"literal\",\"value\":\"2018-12-10T09:06:19\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#1544432779\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/5\":{\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_searchable_index/result#1544432795\"}]},\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_searchable_index/result#1544432795\":{\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:06:35\",\"datatype\":\"xsd:dateTime\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://schema.org/comment\":[{\"type\":\"literal\",\"value\":\"Failed to find the UUID in the output from  'https://www.uniprot.org/uniprot/?query=A4_HUMAN'\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"0\",\"type\":\"literal\"}]}}}",
        "executor": "0000-0001-6960-357X",
        "title": "UniProt A4_HUMAN",
        "created_at": "2018-12-10T09:05:28.883Z",
        "updated_at": "2018-12-10T09:23:41.245Z"
      }



##  <a name="getevaluationstemplate"> /evaluations/{id}/template

A Human readable Web page describing the outcome of the evaluation


##  <a name="getevaluationresult"> /evaluations/{id}/result

A Human readable Web page describing the outcome of the evaluation  (the equivalent for Machines is /evaluations/{id}.json)


# <a name="posts"></a> HTTP POST Operations

## <a name="postsearch"> /searches/

Returns a 201 CREATED header, with a Location tag indicating the location of your search interface.  The body of the message contains a JSON Schema describing the search interface (i.e. an array of keywords)

## <a name="postsearch2"> /searches/{Location}

Searches are executed by POSTing to the URL provided to you in the "Location" tag of the response to the call above.  POST of a correctly formatted block of JSON returns a block of JSON-LD containing a list of matching Metrics (based on their 'description' property), and a list of matching Collections (based on their 'description' property).  The format of the list members is identical to the format of an individual Metric or Collection descriptor (e.g. [METRIC](#getmetric); [COLLECTION](#getcollection) )

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
		"@type": [{
			"@id": "http://purl.org/dc/dcmitype/Dataset"
		}, {
			"@id": "http://www.w3.org/ns/ldp#BasicContainer"
		}, {
			"@id": "http://www.w3.org/ns/prov#Collection"
		}],
		"http://purl.org/dc/elements/1.1/authoredBy": {
			"@id": "https://dx.doi.org/0000-0001-6960-357X"
		},
		"http://purl.org/dc/elements/1.1/license": {
			"@id": "https://creativecommons.org/licenses/by/4.0"
		},
		"http://purl.org/dc/elements/1.1/title": {
			"@value": "Gen2 Three Identifier Metrics"
		},
		"http://purl.org/dc/elements/1.1/creator": {
			"@value": "CBGP UPM-INIA"
		},
		"http://purl.org/pav/version": {
			"@value": "2019-01-25T14:39:19.975Z"
		},
		"http://rdfs.org/ns/void#description": {
			"@value": "FAIR Metrics Evaluation Collection Gen2 Three Identifier Metrics authored by https://dx.doi.org/0000-0001-6960-357X"
		},
		"http://www.w3.org/ns/dcat#entities": {
			"@value": 3
		},
		"http://www.w3.org/ns/dcat#contactPoint": {
			"@id": "https://dx.doi.org/0000-0001-6960-357X"
		},
		"http://www.w3.org/ns/dcat#identifier": {
			"@id": "https://w3id.org/FAIR_Evaluator/collections/4"
		},
		"http://www.w3.org/ns/dcat#publisher": {
			"@id": "http://fairmetrics.org"
		},
		"http://www.w3.org/ns/ldp#contains": [{
			"@id": "https://w3id.org/FAIR_Evaluator/metrics/4"
		}, {
			"@id": "https://w3id.org/FAIR_Evaluator/metrics/5"
		}, {
			"@id": "https://w3id.org/FAIR_Evaluator/metrics/6"
		}]
	}]
     }


## <a name="createnewmetric"> /metrics

POST the URL to the smartAPI interface definition (currently *must* be in YAML!) in order to register a new Metric Test

Sample JSON

    curl -L -X POST -D -H "Content-Type: application/json" -H "Accept: application/json" -d '{"smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata"}' https://w3id.org/FAIR_Evaluator/metrics

response 200 OK

    {
        "id": "https://w3id.org/FAIR_Evaluator/metrics/1.json",
        "name": "FAIR Metrics Gen2- Metadata Identifier Explicitly In Metadata",
        "creator": "Mark D Wilkinson",
        "email": "markw@illuminae.com",
        "smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata",
        "created_at": "2018-12-31T11:30:46.545Z",
        "updated_at": "2018-12-31T11:30:46.545Z",
        "principle": "https://purl.org/fair-metrics/F3"
    }


## <a name="createnewcollection"> /collections

POST the JSON describing a new Metric Collection to register that collection in the Evaluator registry.

Sample JSON

    curl -L -X POST -D -H "Content-Type: application/json" -H "Accept: application/json" -d '{"name": "JSON Test 3", "contact": "0000-0001-6960-357X", "organization": "Hackathon", "include_metrics": ["http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata"]}'  https://w3id.org/FAIR_Evaluator/collections

Response 200 OK

    {
        "@id": "https://w3id.org/FAIR_Evaluator/collections/1.json",
        "@type": [{
            "@id": "http://purl.org/dc/dcmitype/Dataset"
        }, {
            "@id": "http://www.w3.org/ns/ldp#BasicContainer"
        }, {
            "@id": "http://www.w3.org/ns/prov#Collection"
        }],
        "http://purl.org/dc/elements/1.1/authoredBy": {
            "@id": "https://dx.doi.org/0000-0001-6960-357X"
        },
        "http://purl.org/dc/elements/1.1/license": {
            "@id": "https://creativecommons.org/licenses/by/4.0"
        },
        "http://purl.org/dc/elements/1.1/title": {
            "@value": "JSON Test 3"
        },
        "http://purl.org/dc/elements/1.1/creator": {
            "@value": "Hackathon"
        },
        "http://purl.org/pav/version": {
            "@value": "2018-12-31T11:34:38.053Z"
        },
        "http://rdfs.org/ns/void#description": {
            "@value": "FAIR Metrics Evaluation Collection JSON Test 3 authored by https://dx.doi.org/0000-0001-6960-357X"
        },
        "http://www.w3.org/ns/dcat#entities": {
            "@value": 1
        },
        "http://www.w3.org/ns/dcat#contactPoint": {
            "@id": "https://dx.doi.org/0000-0001-6960-357X"
        },
        "http://www.w3.org/ns/dcat#identifier": {
            "@id": "https://w3id.org/FAIR_Evaluator/collections/1.json"
        },
        "http://www.w3.org/ns/dcat#publisher": {
            "@id": "http://fairmetrics.org"
        },
        "http://www.w3.org/ns/ldp#contains": [{
            "@id": "https://w3id.org/FAIR_Evaluator/metrics/1"
        }]
    }


## <a name="createnewevaluation"> /collections/{id}/evaluate

Send a block of JSON containing the Resource (GUID) to be evaluated, and other metadata pertaining to the identity of the individual executing the evaluation; this will initiate an evaluation of that GUID using the Metric tests described by Collection {id} in the Evaluator registry.

Sample JSON

    curl -L -X POST -D -H "Content-Type: application/json" -H "Accept: application/json" -d '{"resource": "10.5281/zenodo.1147435", "executor":  "0000-0001-6960-357X", "title": "an exemplar evaluation"}' https://w3id.org/FAIR_Evaluator/collections/1/evaluate 

Response 302 Redirect  (redirected to the URL of a newly created Evaluation http://linkeddata.systems/evaluations/{id}  with a structure similar to:

    [{
        "id": 12,
        "collection": "1",
        "resource": "https://www.uniprot.org/uniprot/P05067",
        "body": "{\"https://w3id.org/FAIR_Evaluator/metrics/1\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"spec\":\"https://fairsharing.org/bsg-s001182\"},\"https://w3id.org/FAIR_Evaluator/metrics/2\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"persistence_doc\":\"https://fairsharing.org/bsg-s001182\"},\"https://w3id.org/FAIR_Evaluator/metrics/3\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"metadata\":\"https://www.uniprot.org/uniprot/P05067\",\"format\":\"https://fairsharing.org/FAIRsharing.p77ph9\"},\"https://w3id.org/FAIR_Evaluator/metrics/4\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"metadata\":\"https://www.uniprot.org/uniprot/P05067\",\"identifier\":\"https://www.uniprot.org/uniprot/P05067\"},\"https://w3id.org/FAIR_Evaluator/metrics/5\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"search_uri\":\"https://www.uniprot.org/uniprot/?query=A4_HUMAN\"}}",
        "result": "{\"https://w3id.org/FAIR_Evaluator/metrics/1\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_unique_identifier/result#1544432741\":{\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:05:41\",\"type\":\"literal\",\"datatype\":\"xsd:dateTime\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_unique_identifier/result#1544432741\",\"type\":\"uri\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/2\":{\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_persistence/result#1544432753\",\"type\":\"uri\"}]},\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_persistence/result#1544432753\":{\"http://purl.obolibrary.org/obo/date\":[{\"type\":\"literal\",\"datatype\":\"xsd:dateTime\",\"value\":\"2018-12-10T09:05:53\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/3\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_machine_readable_metadata/result#1544432765\":{\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}],\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:06:05\",\"datatype\":\"xsd:dateTime\",\"type\":\"literal\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_machine_readable_metadata/result#1544432765\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/4\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#1544432779\":{\"http://schema.org/comment\":[{\"value\":\"There was no identifier https://www.uniprot.org/uniprot/P05067 in document at https://www.uniprot.org/uniprot/P05067\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"0\",\"type\":\"literal\"}],\"http://purl.obolibrary.org/obo/date\":[{\"datatype\":\"xsd:dateTime\",\"type\":\"literal\",\"value\":\"2018-12-10T09:06:19\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#1544432779\"}]}},\"https://w3id.org/FAIR_Evaluator/metrics/5\":{\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_searchable_index/result#1544432795\"}]},\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_searchable_index/result#1544432795\":{\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:06:35\",\"datatype\":\"xsd:dateTime\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://schema.org/comment\":[{\"type\":\"literal\",\"value\":\"Failed to find the UUID in the output from  'https://www.uniprot.org/uniprot/?query=A4_HUMAN'\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"0\",\"type\":\"literal\"}]}}}",
        "executor": "0000-0001-6960-357X",
        "title": "UniProt A4_HUMAN",
        "created_at": "2018-12-10T09:05:28.883Z",
        "updated_at": "2018-12-10T09:23:41.245Z"
      }]





