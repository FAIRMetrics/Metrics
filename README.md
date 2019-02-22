**The Metrics are currently being extensively revised.  Any references you have should be considered deprecated until further notice**


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

With the goal of providing an objective, automated way of testing (meta)data resources against the Metrics, the Metrics Authorship Group have created the FAIR Evaluator, which is running as a demonstration service at **CURRENTLY OFFLINE FOR REDESIGN**.  The Evaluator provides a registry and execution functions for:

* Metric Tests
* Community-defined Collections of Metric Tests
* Quantitative FAIRness evaluations of a Resource based on these Collections.

A Metric Test is a Web API that has the following features:

1)  It is described in YAML using a [smartAPI](http://smart-api.info/) interface annotation (smartAPI is an extension of openAPI/Swagger, which allows semantic annotation of various metadata elements and interface input/output fields.  [An editor for smartAPI](http://smart-api.info/editor/) is available.
2)  HTTP GET on the endpoint of the Metric Test URL returns that smartAPI document in YAML (for example: http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_unique_identifier)
3)  HTTP POST of the **metadata GUID** to that same endpoint, in a simple JSON document {subject => GUID}, triggers the execution of the test.  
4)  The Test returns a block of JSON-LD containing information about the test, including date/time, comments, and score

(we are working on JSON Schema for these documents now, but following the example below will get you started)

For example

    curl -X POST -D -L -H "Content-Type: application/json" -H "Accept: application/json" -d '{"subject": "10.5281/zenodo.1147435"}' http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_unique_identifier

Might return the following result:


      [
        {
          "@id": "http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_unique_identifier#10.5281/zenodo.1147435/result-2018-12-31T13:32:43+00:00",
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
              "@value": "Found a Crossref DOI - pass",
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


The "score" of the Metric Test is the value of the "SIO:000300" (has_value) predicate, and must be a floating-point value between 0 and 1.  The precise meaning of that value should be explained in the Comments (schema:comment) section, along wth, for example, explanations for failure.  Other metadata is provided, as shown (all shown fields are required!).

**NOTE** No other information may be provided to the Metric Test beyond the **metadata** GUID.  The purpose of FAIR Metric Tests is to determine if machines can find, access, and "interpret" (meta)data, thus it is a firm requirement that only the metadata GUID may be given to the test.  The aspect of FAIRness being evaluated **must** be automatically discernable using that metadata.

This Metric Test is registered by either HTTP POST of properly formatted JSON to the Evaluator registry (see API here:https://github.com/FAIRMetrics/Metrics/tree/master/MetricsEvaluatorCode/Ruby/fairmetrics), or by visiting the manual submission page at:  **CURRENTLY OFFLINE FOR A REDESIGN**, where the form field on that page asks for the URL of the Metric Test's YAML document.

Once registered, a Metric Test can be included in new Metric Collections, and used by the Evaluator software for automated testing of data resources.

# Resources available to help in Metric Testing

The [FAIRSharing Registry](https://fairsharing.org) is a repository for a wide variety of standards, including file formats, ontologies, identifier types, etc.  They provide a JSON API that can be used within Metrics Tests to look-up "standards" a test encounters in its exploration of (meta)data to determine if that standard is registered.  Standards that are not registered with FAIRSharing should be encouraged to do so by contacting the appropriate standards-body, or by contacting the FAIRSharing team with a request to include the standard in their registry.

# PHILOSOPHY OF FAIR TESTING (under development!  Comments welcome!)

Evaluating FAIRness is a controversial issue!  We (the Metrics Authoring Group) feel that these concerns can be eased through bringing more clarity regarding the "philosophy" behind FAIRness testing.

First, there is no such thing as "FAIR", and neither is there "unFAIR"!  As described in [this manuscript](https://content.iospress.com/articles/information-services-and-use/isu824), we view FAIR as a continuum of 'behaviors' exhibited by a data resource that increasingly enable machine discoverability and (re)use.  Moreover, the final FAIR Principle speaks directly to the fact that "FAIR" will have different requirements for different communities!  Thus, a given Metric (and its associated Metric Test) may not be applicable to certain types of resources from a given community; or, alternatively, there may exist in that community some standard that is widely accepted within that community to enable machine-actionability of a data resource, but that would not be recognized by a "generic" computational agent.  This is all completely acceptable, and is the reason that the Metrics and the Metric Testing framework have been established as a community-driven initiative, rather than top-down. 

For example:  In the bioinformatics community, a widely used format for Sequence Features is [GFF3](https://www.ensembl.org/info/website/upload/gff3.html) - a tab-delimited format with specific constraints on the content of each field.  From the perspective of a "generic" computational agent, it would be ~impossible to interpret or reuse that data; however, there are constraints on that format that speak directly to the interoperability objectives of FAIR - for example, that the "type" field must consist of a term from the Sequence Ontology.  Thus, it would be reasonable for the Bioinformatics community to create a FAIR Metric, and its associated Metric Test, that evaluated if a GFF3 file fulfilled those requirements.  Thus, a community could create a Metric Collection that eschewed the "generic" test for machine-readability of the data, and instead, utilized their own Metric Test that validated the content of that GFF3 file.

In light of this, we insist that FAIR evaluations are not intended to be used as "judgement", but rather as a means to objectively (AND TRANSPARENTLY!) test if a resource has successfully fulfilled the FAIRness requirements that **that community** has established.  In this light, FAIR Evaluation is a way for individual providers, or repository owners, to test their own compliance, and to take remedial action if their resources are not passing the tests.  Confirmation and/or guidance, rather than judgement.

Certainly, we believe that some FAIR Metrics (for example, that the entity has a globally unique identifier, and that all data should have a license and citation information) are universal, and a prerequisite for FAIRness; however, many of the FAIR Principles must be interpreted by the individual communities, keeping as close to the "spirit" of FAIR as possible.

**DEPRECATED LINKS**

TO DOWNLOAD THE CURRENT ZENODO RELEASE OF THE METRICS, GO HERE:  https://doi.org/10.5281/zenodo.1065973**

FOR PDF's OF THE INDIVIDUAL METRICS SEE HERE:  https://github.com/FAIRMetrics/Metrics/tree/master/Distributions**

FOR LaTex OF THE INDIVIDUAL METRICS SEE HERE:  https://github.com/FAIRMetrics/Metrics/tree/master/Distributions**

TO DOWNLOAD ALL OF THE METRICS IN ONE PDF:  https://github.com/FAIRMetrics/Metrics/raw/master/ALL.pdf**

TO VIEW THE METRICS IN YOUR BROWSER:  http://htmlpreview.github.com/?https://github.com/FAIRMetrics/Metrics/blob/master/ALL.html
