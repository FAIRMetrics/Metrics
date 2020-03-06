# FAIR Maturity Indicators and Tools
Resources and guidelines to assess the FAIRness of a digital resource.

The folder ['MaturityIndicators'](https://github.com/FAIRMetrics/Metrics/tree/master/MaturityIndicators) contains the text (as MarkDown) for the:
* Generation-1 (Gen1) questionnaire-style Maturity Indicator tests
* Generation-2 (Gen2) automatable Maturity Indicator tests.

Only Gen2 tests function with the current version of the [Evaluator software](https://w3id.org/FAIR_Evaluator).

## Directly Related Work
* [FAIR Metrics Group](http://www.fairmetrics.org/)
* [Collection of FAIR Maturity Indicator on FAIRsharing](https://fairsharing.org/standards/?q=&selected_facets=type_exact:metric)

## Directly Related Publications
* [Paper describing the metrics in this Git](https://doi.org/10.1038/sdata.2018.118)
* A manuscript describing the Gen2 Maturity Indicators, and the Evaluator, is currently in preparation

## Other Initiatives
* [NIH Working Group on FAIR Metrics](https://bd2kccc.org/working-groups/?v=commons&h=front) - [minutes](https://docs.google.com/document/d/1Z67UntK73zE8egLpKmIHfpexyuPWWV1gjcjfNeybK9o/edit?usp=sharing)
* [FAIR-TLC](https://zenodo.org/record/203295#.WVs8m4jfoUE)
* [RDA Working Group on Data Usability](https://www.rd-alliance.org/data-publishing-data-usability-certification-services-rda-8th-plenary-bof-meeting)
* [RDA Working Group on Data Maturity Model](https://www.rd-alliance.org/groups/fair-data-maturity-model-wg)
* [Horizon 2020 Commission expert group on Turning FAIR data into reality](http://ec.europa.eu/transparency/regexpert/index.cfm?do=groupDetail.groupDetail&groupID=3464


# HOW TO CREATE AND REGISTER A NEW MATURITY INDICATOR

FAIR Maturity Indicators are created, initially, as a narrative document, <a href='http://fairmetrics.org/fairmetricform.html'>following a template<a> extablished by the FAIR Metrics Authoring Group. A [MarkDown version of this template](https://github.com/FAIRMetrics/Metrics/blob/master/MaturityIndicators/MaturityIndicatorTemplate.md) is available above, and should be used for Maturity Indicator submissions by the public.  Guidance for how to complete this document is found in the <a href='http://fairmetrics.org/framework.html'>authoring framework overview</a>.
  
A Template Markdown file is provided for you in the [MaturityIndicator folder](https://github.com/FAIRMetrics/Metrics/tree/master/MaturityIndicators).  Once a Maturity Indicator has been designed, the document should be submitted via 'pull request' to this repository, at which time it becomes available for community discussion.  

The author of the Maturity Indicator should publicize their submission as widely as possible, to encourage maximal community input. This can be achieved by registering the Maturity Indicator to <b>FAIRsharing</b>, via the <a href='https://fairsharing.org/new'>submission form </a>, or by contacting the FAIRsharing curators <a href='mailto:contact@fairsharing.org'> by email </a> they will harvest the information from the GitHub and help with the registration process. The new Maturity Indicator will be added to the existent <a href='https://fairsharing.org/standards/?q=&selected_facets=type_exact:metric'>list of Maturity Indicator </a> with the "in development" tag. 

At this time, there is no formal process for adoption of Maturity Indicators (incuding those that the Authoring Group have designed themselves!), as there is no official body that can recognize or "stamp" a Maturity Indicator as being "valid".  Nevertheless, authors should consider the comments and criticisms they receive, and modify the submission accordingly if the criticisms are justified. When the Maturity Indicator is considered ready for use, the FAIRsharing curators will replace the "in development" with a "ready" tag to indicate readiness.


# HOW TO CREATE A NEW MATURITY INDICATOR TEST

With the goal of providing an objective, automated way of testing (meta)data resources against the Maturity Indicators, the Authorship Group have created the FAIR Evaluator, which is running as a demonstration service at [https://w3id.org/FAIR_Evaluator](https://w3id.org/FAIR_Evaluator).  The Evaluator provides a registry and execution functions for:

* Maturity Indicator Tests
* Community-defined Collections of Maturity Indicator Tests
* Quantitative FAIRness evaluations of a Resource based on these Collections.

A Maturity Indicator Test is a Web API that has the following features:

1)  It is described in YAML using a [smartAPI](http://smart-api.info/) interface annotation (smartAPI is an extension of openAPI/Swagger, which allows semantic annotation of various metadata elements and interface input/output fields.  [An editor for smartAPI](http://smart-api.info/editor/) is available.
2)  HTTP GET on the endpoint of the Maturity Indicator Test URL returns that smartAPI document in YAML (for example: http://linkeddata.systems/cgi-bin/FAIR_Tests/gen2_unique_identifier)
3)  HTTP POST of the **metadata GUID** to that same endpoint, in a simple JSON document {"subject": "GUID"}, triggers the execution of the test.  
4)  The Test returns a block of JSON-LD containing information about the test, including date/time, comments, and score

(we are working on JSON Schema for these documents now, but following the example below will get you started)

For example

    curl -L -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"subject": "10.5281/zenodo.1147435"}' https://w3id.org/FAIR_Tests/tests/gen2_unique_identifier

Might return the following result:


      [
        {
          "@id": "http://w3id.org/FAIR_Tests/tests/gen2_unique_identifier#10.5281/zenodo.1147435/result-2018-12-31T13:32:43+00:00",
          "@type": [
            "http://fairmetrics.org/resources/metric_evaluation_result"
          ],
          "http://purl.obolibrary.org/obo/date": [
            {
              "@value": "2018-12-31T13:32:43+00:00",
              "@type": "http://www.w3.org/2001/XMLSchema#date"
            }
          ],
          "http://schema.org/softwareVersion": [
           {
             "@value": "Hvst-1.0.1:Tst-0.2.2",
             "@type": "http://www.w3.org/2001/XMLSchema#float"
           }
          ],
          "http://schema.org/comment": [
            {
              "@value": "Found a DOI - pass",
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


The "score" of the Maturity Indicator Test is the value of the "SIO:000300" (has_value) predicate, and must be binary 0 or 1.  The precise meaning of that value should be explained in the Comments (schema:comment) section, along wth, for example, explanations for failure.  Other metadata is provided, as shown (all shown fields are required!).

**NOTE** No other information may be provided to the Maturity Indicator Test beyond the **metadata** GUID.  The purpose of FAIR Maturity Indicator Tests is to determine if machines can find, access, and "interpret" (meta)data, thus it is a firm requirement that only the metadata GUID may be given to the test.  The aspect of FAIRness being evaluated **must** be automatically discernable using that metadata.

This Maturity Indicator Test is registered by either HTTP POST of properly formatted JSON to the Evaluator registry (see API here:https://github.com/FAIRMetrics/Metrics/tree/master/MetricsEvaluatorCode/Ruby/fairmetrics), or by visiting the [manual submission page](https://www.w3id.org/FAIR_Evaluator/metrics/new), where the form field on that page asks for the URL of the Maturity Indicator Test's YAML document.

Once registered, a Maturity Indicator Test can be included in new Maturity Indicator Collections, and used by the Evaluator software for automated testing of data resources.

# FAIRsharing contents to help in Maturity Indicator Testing

[FAIRsharing](https://fairsharing.org) is a FAIR-enabling resource and a registry for a wide variety of community data and metadata standards, including file formats, ontologies, identifier schemas, as well as for <a href='https://fairsharing.org/standards/?q=&selected_facets=type_exact:metric'> Maturity Indicators </a>.  In addition, FAIRsharing provides a JSON API that can be used within Maturity Indicator Tests to look-up "standards" a test encounters in its exploration of (meta)data to determine if that standard is registered.  

Standards that are not registered with FAIRsharing are encouraged to do so by contacting the appropriate standards-body, or by submitting the missing standards via the <a href='https://fairsharing.org/new'>submission form </a>, or by contacting the FAIRsharing curators <a href='mailto:contact@fairsharing.org'> by email </a> to include the standard in their registry. 

# PHILOSOPHY OF FAIR TESTING (under development - Comments welcome!)

Evaluating FAIRness is a controversial issue!  We (the Maturity Indicator Authoring Group) feel that these concerns can be eased through bringing more clarity regarding the "philosophy" behind FAIRness testing.

First, there is no such thing as "FAIR", and neither is there "unFAIR"!  As described in [this manuscript](https://content.iospress.com/articles/information-services-and-use/isu824), we view FAIR as a continuum of 'behaviors' exhibited by a data resource that increasingly enable machine discoverability and (re)use.  Moreover, the final FAIR Principle speaks directly to the fact that "FAIR" will have different requirements for different communities!  Thus, a given Maturity Indicator (and its associated Maturity Indicator Test) may not be applicable to certain types of resources from a given community; or, alternatively, there may exist in that community some standard that is widely accepted within that community to enable machine-actionability of a data resource, but that would not be recognized by a "generic" computational agent.  This is all completely acceptable, and is the reason that the Maturity Indicators and the Maturity Indicator Testing framework have been established as a community-driven initiative, rather than top-down. 

For example:  In the bioinformatics community, a widely used format for Sequence Features is [GFF3](https://www.ensembl.org/info/website/upload/gff3.html) - a tab-delimited format with specific constraints on the content of each field.  From the perspective of a "generic" computational agent, it would be ~impossible to interpret or reuse that data; however, there are constraints on that format that speak directly to the interoperability objectives of FAIR - for example, that the "type" field must consist of a term from the Sequence Ontology.  Thus, it would be reasonable for the Bioinformatics community to create a FAIR Maturity Indicator, and its associated Maturity Indicator Test, that evaluated if a GFF3 file fulfilled those requirements.  Thus, a community could create a Maturity Indicator Collection that eschewed the "generic" test for machine-readability of the data, and instead, utilized their own Maturity Indicator Test that validated the content of that GFF3 file.

In light of this, we insist that FAIR evaluations are not intended to be used as "judgement", but rather as a means to objectively (AND TRANSPARENTLY!) test if a resource has successfully fulfilled the FAIRness requirements that **that community** has established.  In this light, FAIR Evaluation is a way for individual providers, or repository owners, to test their own compliance, and to take remedial action if their resources are not passing the tests.  Confirmation and/or guidance, rather than judgement.

Certainly, we believe that some FAIR Maturity Indicator (for example, that the entity has a globally unique identifier, and that all data should have a license and citation information) are universal, and a prerequisite for FAIRness; however, many of the FAIR Principles must be interpreted by the individual communities, keeping as close to the "spirit" of FAIR as possible.

**LINKS TO 'Generation 1' questionnaire-style Maturity Indicators**

TO DOWNLOAD THE ZENODO RELEASE OF THE GENERATION 1 METRICS, GO HERE:  https://doi.org/10.5281/zenodo.1065973

TO DOWNLOAD ALL OF THE METRICS IN ONE PDF:  https://github.com/FAIRMetrics/Metrics/blob/master/MaturityIndicators/Gen1/ALL.pdf

