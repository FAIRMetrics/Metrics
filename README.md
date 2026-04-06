# FAIR Maturity Indicators and Tools

The newest metrics follow the [FAIR Test Results Vocabulary](https://w3id.org/ftr) and are located in a GitHub Pages-served folder under [./docs](./docs/)   These are separated into general metrics and project/community/digital-object specific metrics (e.g. the ESRF metrics for the ESRF Sincrotron in Grenoble)



# NOTE DEPRECATIONS

The documentation for the old "Gen1" and Gen2" Metrics are retained, but they are **DEPRECATED**.

Anything in the ['MaturityIndicators'](https://github.com/FAIRMetrics/Metrics/tree/master/MaturityIndicators) should not be used.


# OLD DOCUMENTATION


Resources and guidelines to assess the FAIRness of a digital resource.

The folder ['MaturityIndicators'](https://github.com/FAIRMetrics/Metrics/tree/master/MaturityIndicators) contains the text (as MarkDown) for the:
* Generation-1 (Gen1) questionnaire-style Maturity Indicator tests
* Generation-2 (Gen2) automatable Maturity Indicator tests.

Only Gen2 tests function with the current version of the [Evaluator software](https://w3id.org/AmIFAIR).

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
* [Horizon 2020 Commission expert group on Turning FAIR data into reality](https://op.europa.eu/en/publication-detail/-/publication/7769a148-f1f6-11e8-9982-01aa75ed71a1)


# HOW TO CREATE AND REGISTER A NEW MATURITY INDICATOR

The path to creating a new Maturity Indicator is currently being updated.  When a link is available, it will appear here.

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

