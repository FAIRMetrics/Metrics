**TO DOWNLOAD ALL OF THE METRICS IN ONE PDF:  https://github.com/FAIRMetrics/Metrics/raw/master/ALL.pdf**
**TO VIEW THE METRICS IN YOUR BROWSER:  http://htmlpreview.github.com/?https://github.com/FAIRMetrics/Metrics/blob/master/ALL.html**

---------------


**TO DOWNLOAD THE CURRENT ZENODO RELEASE OF THE METRICS, GO HERE:  https://doi.org/10.5281/zenodo.1065973**

**FOR PDF's OF THE INDIVIDUAL METRICS SEE HERE:  https://github.com/FAIRMetrics/Metrics/tree/master/Distributions**

**FOR LaTex OF THE INDIVIDUAL METRICS SEE HERE:  https://github.com/FAIRMetrics/Metrics/tree/master/Distributions**



# FAIR Metrics
Efforts to define metrics to assess the FAIRness of a digital resource.

Note that the top-level folder (the one you are in now) contains the NanoPublications for each of the Metrics - the machine-readable format of the Metrics publication.  The other formats are in the Distributions folder, in both LaTex and PDF.  

Initiatives

* [FAIR Metrics Group](http://www.fairmetrics.org/)
* [NIH Working Group on FAIR Metrics](https://bd2kccc.org/working-groups/?v=commons&h=front) - [minutes](https://docs.google.com/document/d/1Z67UntK73zE8egLpKmIHfpexyuPWWV1gjcjfNeybK9o/edit?usp=sharing)
* [FAIR-TLC](https://zenodo.org/record/203295#.WVs8m4jfoUE)
* [RDA Working Group on Data Usability](https://www.rd-alliance.org/data-publishing-data-usability-certification-services-rda-8th-plenary-bof-meeting)
* [Horizon 2020 Commission expert group on Turning FAIR data into reality](http://ec.europa.eu/transparency/regexpert/index.cfm?do=groupDetail.groupDetail&groupID=3464)

Publications

* [Preprint describing the metrics in this Git](https://doi.org/10.1101/225490)

# HOW TO CREATE A NEW METRIC

Metrics are created, initially, as a narrative document, <a href='http://fairmetrics.org/fairmetricform.html'>following a template<a> extablished by the FAIR Metrics Authoring Group. Guidance for how to complete this document is found in the <a href='http://fairmetrics.org/framework.html'>authoring framework overview</a>.
  
Once a Metric has been designed, the document should be submitted via 'pull request' to this repository, at which time it becomes available for community discussion.  The author of the Metric should publicize their Metric as widely as possible, to encourage maximal community input.  

At this time, there is no formal process for adoption of Metrics (incuding those that the Metrics Authoring Group have designed themselves!), as there is no official body that can recognize or "stamp" a Metric as being "valid".  Nevertheless, authors should consider the comments and criticisms they receive, and modify the Metric accordingly if the criticisms are justified.

# HOW TO CREATE A NEW METRIC TEST

With the goal of providing an objective, automated way of testing (meta)data resources against the Metrics, the Metrics Authorship Group have created the FAIR Evaluator, which is running as a demonstration service at http://linkeddata.systems:3000.  The Evaluator is a registry of:

* Metric Tests
* Community-defined Collections of Metric Tests
* Quantitative FAIRness evaluations of a Resource based on these Collections.

A Metric Test is a Web API that has the following features:

1)  It is described in YAML using a (http://smart-api.info/)[smartAPI] interface annotation (smartAPI is an extension of openAPI/Swagger, which allows semantic annotation of various metadata elements and interface input/output fields.  An editor for smartAPI (http://smart-api.info/editor/)[is available].
2)  HTTP GET on the endpoint of the Metric Test URL returns that smartAPI document in YAML
3)  HTTP POST of a simple JSON document triggers the execution of the test.  The document structure is:

     {'subject': 'your.GUID.here'}

4)  The Test returns a block of JSON-LD with a structure as follows:

      [
        {
          "@id": "http://linkeddata.systems//cgi-bin/FAIR_Tests/gen2_unique_identifier#10.5281/zenodo.1147435/result-2018-12-31T13:32:43+00:00",
          "@type": [
            "http://fairmetrics.org/resources/metric_evaluation_result"
          ],
          "http://purl.obolibrary.org/obo/date": [
            {
              "@value": "2018-12-31T13:32:43+00:00",
              "@type": "http://www.w3.org/2001/XMLSchema#date"
            }
          ],
          "http://schema.org/comment": [
            {
              "@value": "[]Found a Crossref DOI - pass",
              "@language": "en"
            }
          ],
          "http://semanticscience.org/resource/SIO_000332": [
            {
              "@value": "10.5281/zenodo.1147435",
              "@language": "en"
            }
          ],
          "http://semanticscience.org/resource/SIO_000300": [
            {
              "@value": "1.0",
              "@type": "http://www.w3.org/2001/XMLSchema#float"
            }
          ]
        }
      ]

The "score" of the Metric Test is the value of the "SIO:000300" (has_value) predicate.  Comments from the evaluation, for example, explanations for failure, are in the schema:comment.  Other metadata is provided.

This Metric Test is registered by either HTTP POST of properly formatted JSON to the Evaluator registry (see API here:https://github.com/FAIRMetrics/Metrics/tree/master/MetricsEvaluatorCode/Ruby/fairmetrics), or by visiting the manual submission page at:  http://linkeddata.systems:3000/metrics/new, where the form field on that page asks for the URL of the Metric Test's YAML document.

Once registered, a Metric Test can be included in new Metric Collections, and used by the Evaluator software for automated testing of data resources.
