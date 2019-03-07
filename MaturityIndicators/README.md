
# FAIR Maturity Indicators
Tools to assess the FAIRness of a digital resource.

## Gen1 and Gen2
The Gen1 and Gen2 folders in this directory contain textual descriptions of a variety of FAIRness Maturity Indicators (MI).  Gen1 were used for the initial [survey-based FAIRness evaluations](https://doi.org/10.1101/225490), and can only be evaluated manually.  Taking the outcomes of the surveys as a broad view of community approaches to FAIRness, we then generated Gen2 MIs, which can be fully automated.  Gen2 MIs are used in the current iteration of the [FAIR Evaluator](https://w3id.org/FAIR_Evaluator)

## Related Initiatives

* [FAIR Metrics Group](http://www.fairmetrics.org/)
* [NIH Working Group on FAIR Metrics](https://bd2kccc.org/working-groups/?v=commons&h=front) - [minutes](https://docs.google.com/document/d/1Z67UntK73zE8egLpKmIHfpexyuPWWV1gjcjfNeybK9o/edit?usp=sharing)
* [FAIR-TLC](https://zenodo.org/record/203295#.WVs8m4jfoUE)
* [RDA Working Group on Data Usability](https://www.rd-alliance.org/data-publishing-data-usability-certification-services-rda-8th-plenary-bof-meeting)
* [Horizon 2020 Commission expert group on Turning FAIR data into reality](http://ec.europa.eu/transparency/regexpert/index.cfm?do=groupDetail.groupDetail&groupID=3464)

## Publications

* [Preprint describing the metrics in this Git](https://doi.org/10.1101/225490)

# HOW TO CREATE A NEW MATURITY INDICATOR

MIs are created, initially, as a narrative document, <a href='http://fairmetrics.org/fairmetricform.html'>following a template<a> extablished by the oroginal Authoring Group. A [MarkDown version of this template](https://github.com/FAIRMetrics/Metrics/blob/master/MetricTemplate.md) is available above, and should be used for MI submissions by the public.  Guidance for how to complete this document is found in the <a href='http://fairmetrics.org/framework.html'>authoring framework overview</a>.
  
Once a MI has been designed, the document should be submitted via 'pull request' to this repository, at which time it becomes available for community discussion.  The author of the MI should publicize it as widely as possible, to encourage maximal community input.  

At this time, there is no formal process for adoption of MIs (incuding those that the original Authoring Group designed themselves!), as there is no official body that can recognize or "stamp" an MI as being "valid".  Nevertheless, authors should consider the comments and criticisms they receive, and modify the MI accordingly if the criticisms are justified.

# HOW TO CREATE A NEW MI TEST

With the goal of providing an objective, automated way of testing (meta)data resources against the MIs, the Authorship Group have created the FAIR Evaluator, which is running as a demonstration service at http://w3id.org/FAIR_Evaluator.  The Evaluator provides a registry and execution functions for:

* MI Tests
* Community-defined Collections of MI Tests
* Quantitative FAIRness evaluations of a Resource based on these Collections.

A MI Test is a Web API that has the following features:

1)  It is described in YAML using a [smartAPI](http://smart-api.info/) interface annotation (smartAPI is an extension of openAPI/Swagger, which allows semantic annotation of various metadata elements and interface input/output fields.  [An editor for smartAPI](http://smart-api.info/editor/) is available.
2)  HTTP GET on the endpoint of the MI Test URL returns that smartAPI document in YAML (for example: http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_unique_identifier)
3)  HTTP POST of the **metadata GUID** to that same endpoint, in a simple JSON document {"subject": "GUID"}, triggers the execution of the test.  
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


The "score" of the MI Test is the value of the "SIO:000300" (has_value) predicate, and must be a floating-point value between 0 and 1.  The precise meaning of that value should be explained in the Comments (schema:comment) section, along wth, for example, explanations for failure.  Other metadata is provided, as shown (all shown fields are required!).

**NOTE** No other information may be provided to the MI Test beyond the **metadata** GUID.  The purpose of FAIR MI Tests is to determine if machines can find, access, and "interpret" (meta)data, thus it is a firm requirement that only the metadata GUID may be given to the test.  The aspect of FAIRness being evaluated **must** be automatically discernable using that metadata.

This MI Test is registered by either HTTP POST of properly formatted JSON to the Evaluator registry (see API here:https://github.com/FAIRMetrics/Metrics/tree/master/MetricsEvaluatorCode/Ruby/fairmetrics), or by visiting the [manual submission page](https://w3id.org/FAIR_Evaluator/metrics/new], where the form field on that page asks for the URL of the MI Test's YAML document.

Once registered, a MI Test can be included in new MI Collections, and used by the Evaluator software for automated testing of data resources.

# Resources available to help in MI Testing

The [FAIRSharing Registry](https://fairsharing.org) is a repository for a wide variety of standards, including file formats, ontologies, identifier types, etc.  They provide a JSON API that can be used within MI Tests to look-up "standards" a test encounters in its exploration of (meta)data to determine if that standard is registered.  Standards that are not registered with FAIRSharing should be encouraged to do so by contacting the appropriate standards-body, or by contacting the FAIRSharing team with a request to include the standard in their registry.

# PHILOSOPHY OF FAIR TESTING (under development!  Comments welcome!)

Evaluating FAIRness is a controversial issue!  We (the Metrics Authoring Group) feel that these concerns can be eased through bringing more clarity regarding the "philosophy" behind FAIRness testing.

First, there is no such thing as "FAIR", and neither is there "unFAIR"!  As described in [this manuscript](https://content.iospress.com/articles/information-services-and-use/isu824), we view FAIR as a continuum of 'behaviors' exhibited by a data resource that increasingly enable machine discoverability and (re)use.  Moreover, the final FAIR Principle speaks directly to the fact that "FAIR" will have different requirements for different communities (FAIR Principle R1.3)!  Thus, a given MI (and its associated MI Test) may not be applicable to certain types of resources from a given community; or, alternatively, there may exist in that community some standard that is widely accepted within that community to enable machine-actionability of a data resource, but that would not be recognized by a "generic" computational agent.  This is all completely acceptable, and is the reason that the MI and the MI Testing framework have been established as a community-driven initiative, rather than top-down. 

For example:  In the bioinformatics community, a widely used format for Sequence Features is [GFF3](https://www.ensembl.org/info/website/upload/gff3.html) - a tab-delimited format with specific constraints on the content of each field.  From the perspective of a "generic" computational agent, it would be ~impossible to interpret or reuse that data; however, there are constraints on that format that speak directly to the interoperability objectives of FAIR - for example, that the "type" field must consist of a term from the Sequence Ontology.  Thus, it would be reasonable for the Bioinformatics community to create a FAIR MI, and its associated MI Test, that evaluated if a GFF3 file fulfilled those requirements.  Thus, a community could create a MI Collection that eschewed the "generic" test for machine-readability of the data, and instead, utilized their own MI Test that validated the content of that GFF3 file.

In light of this, we insist that FAIR evaluations are not intended to be used as "judgement", but rather as a means to objectively (AND TRANSPARENTLY!) test if a resource has successfully fulfilled the FAIRness requirements that **that community** has established.  In this light, FAIR Evaluation is a way for individual providers, or repository owners, to test their own compliance, and to take remedial action if their resources are not passing the tests.  Confirmation and/or guidance, rather than judgement.

Certainly, we believe that some FAIR MIs (for example, that the entity has a globally unique identifier, and that all data should have a license and citation information) are universal, and a prerequisite for FAIRness; however, many of the FAIR Principles must be interpreted by the individual communities, keeping as close to the "spirit" of FAIR as possible.

