# The FAIR Evaluator

The FAIR Evaluator is a Ruby on Rails application that is used to:
* register FAIR Metric Tests
* register Collections of FAIR Metric Tests
* initiate evaluations of Web resources
* explore the outcomes of evaluations

API

(the demonstration Evaluator is running at http://linkeddata.systems:3000  All paths below are relative to this root.

## /

The root URL provides a (human-readable only) list of the entry-points for human exploration.

## /metrics  or /metrics.json

Provides a human-readable, or JSON serialized list of known metrics, including their 'deprecated?' status.  These URLs respond to content-negotiation (text/html or application/json only)

sample JSON output

    curl -X GET -D -L -H "Content-Type: application/json" -H "Accept: application/json" http://linkeddata.systems:3000/metrics

results in:

    [{
    "id": "http://linkeddata.systems:3000/metrics/9.json",
    "name": "FAIR Metrics Gen2- Unique Identifier",
    "creator": "Mark D Wilkinson",
    "email": "markw@illuminae.com",
    "smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_unique_identifier",
    "created_at": "2018-12-12T02:43:20.569Z",
    "updated_at": "2018-12-12T02:43:20.569Z",
    "principle": "https://purl.org/fair-metrics/F1"
    }, {
    "id": "http://linkeddata.systems:3000/metrics/10.json",
    "name": "FAIR Metrics Gen2- Metadata Identifier Explicitly In Metadata",
    "creator": "Mark D Wilkinson",
    "email": "markw@illuminae.com",
    "smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_identifier_in_metadata",
    "created_at": "2018-12-24T09:54:16.712Z",
    "updated_at": "2018-12-31T08:22:15.219Z",
    "principle": "https://purl.org/fair-metrics/F3"
    }, {
    "id": "http://linkeddata.systems:3000/metrics/11.json",
    "name": "FAIR Metrics Gen2- Metadata Identifier Explicitly In Metadata",
    "creator": "Mark D Wilkinson",
    "email": "markw@illuminae.com",
    "smarturl": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_metadata_identifier_in_metadata",
    "created_at": "2018-12-31T08:04:59.636Z",
    "updated_at": "2018-12-31T08:04:59.636Z",
    "principle": "https://purl.org/fair-metrics/F3"
    }]


## /collections  or /collections.json

Provides a human-readable, or JSON serialized list of known metric collections, including their 'deprecated?' status.  These URLs respond to content-negotiation (text/html or application/json only).  The output is in JSON-LD, and follows the schema for a [Linked Data Platform Container](https://www.w3.org/2012/ldp/wiki/Containers)

sample JSON output

    curl -X GET -D -L -H "Content-Type: application/json" -H "Accept: application/json" http://linkeddata.systems:3000/collections

results in:

    [{
      "@id": "http://linkeddata.systems:3000/collections/1.json",
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
        "@id": "http://linkeddata.systems:3000/collections/1.json"
      },
      "http://www.w3.org/ns/dcat#publisher": {
        "@id": "http://fairmetrics.org"
      },
      "http://www.w3.org/ns/ldp#contains": [{
          "@id": "http://linkeddata.systems:3000/metrics/9"
        }, {
          "@id": "http://linkeddata.systems:3000/metrics/10"
        }, {
          "@id": "http://linkeddata.systems:3000/metrics/11"
        }]
    }]


## evaluations  or  /evaluations.json

Provides a human-readable, or JSON serialized list of known evaluations.  These URLs respond to content-negotiation (text/html or application/json only).

sample JSON output

    curl -X GET -D -L -H "Content-Type: application/json" -H "Accept: application/json" http://linkeddata.systems:3000/evaluations

results in:

    [{
        "id": 12,
        "collection": "1",
        "resource": "https://www.uniprot.org/uniprot/P05067",
        "body": "{\"http://linkeddata.systems:3000/metrics/1\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"spec\":\"https://fairsharing.org/bsg-s001182\"},\"http://linkeddata.systems:3000/metrics/2\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"persistence_doc\":\"https://fairsharing.org/bsg-s001182\"},\"http://linkeddata.systems:3000/metrics/3\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"metadata\":\"https://www.uniprot.org/uniprot/P05067\",\"format\":\"https://fairsharing.org/FAIRsharing.p77ph9\"},\"http://linkeddata.systems:3000/metrics/4\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"metadata\":\"https://www.uniprot.org/uniprot/P05067\",\"identifier\":\"https://www.uniprot.org/uniprot/P05067\"},\"http://linkeddata.systems:3000/metrics/5\":{\"subject\":\"https://www.uniprot.org/uniprot/P05067\",\"search_uri\":\"https://www.uniprot.org/uniprot/?query=A4_HUMAN\"}}",
        "result": "{\"http://linkeddata.systems:3000/metrics/1\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_unique_identifier/result#1544432741\":{\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:05:41\",\"type\":\"literal\",\"datatype\":\"xsd:dateTime\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_unique_identifier/result#1544432741\",\"type\":\"uri\"}]}},\"http://linkeddata.systems:3000/metrics/2\":{\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_persistence/result#1544432753\",\"type\":\"uri\"}]},\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_persistence/result#1544432753\":{\"http://purl.obolibrary.org/obo/date\":[{\"type\":\"literal\",\"datatype\":\"xsd:dateTime\",\"value\":\"2018-12-10T09:05:53\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}]}},\"http://linkeddata.systems:3000/metrics/3\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_machine_readable_metadata/result#1544432765\":{\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"1\",\"type\":\"literal\"}],\"http://schema.org/comment\":[{\"value\":\"All OK!\",\"type\":\"literal\"}],\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:06:05\",\"datatype\":\"xsd:dateTime\",\"type\":\"literal\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_machine_readable_metadata/result#1544432765\"}]}},\"http://linkeddata.systems:3000/metrics/4\":{\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#1544432779\":{\"http://schema.org/comment\":[{\"value\":\"There was no identifier https://www.uniprot.org/uniprot/P05067 in document at https://www.uniprot.org/uniprot/P05067\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"0\",\"type\":\"literal\"}],\"http://purl.obolibrary.org/obo/date\":[{\"datatype\":\"xsd:dateTime\",\"type\":\"literal\",\"value\":\"2018-12-10T09:06:19\"}]},\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_identifier_in_metadata/result#1544432779\"}]}},\"http://linkeddata.systems:3000/metrics/5\":{\"https://www.uniprot.org/uniprot/P05067\":{\"http://semanticscience.org/resource/SIO_000629\":[{\"type\":\"uri\",\"value\":\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_searchable_index/result#1544432795\"}]},\"http://linkeddata.systems/cgi-bin/fair_metrics/Metrics/metric_searchable_index/result#1544432795\":{\"http://purl.obolibrary.org/obo/date\":[{\"value\":\"2018-12-10T09:06:35\",\"datatype\":\"xsd:dateTime\",\"type\":\"literal\"}],\"http://www.w3.org/1999/02/22-rdf-syntax-ns#type\":[{\"value\":\"http://fairmetrics.org/resources/metric_evaluation_result\",\"type\":\"uri\"}],\"http://schema.org/comment\":[{\"type\":\"literal\",\"value\":\"Failed to find the UUID in the output from  'https://www.uniprot.org/uniprot/?query=A4_HUMAN'\"}],\"http://semanticscience.org/resource/SIO_000300\":[{\"value\":\"0\",\"type\":\"literal\"}]}}}",
        "executor": "0000-0001-6960-357X",
        "title": "UniProt A4_HUMAN",
        "created_at": "2018-12-10T09:05:28.883Z",
        "updated_at": "2018-12-10T09:23:41.245Z"
      }]
