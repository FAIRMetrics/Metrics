# TITLE:  FAIR Maturity Indicator Gen2-MI-F3

## Authors: 
Mark D. Wilkinson, ORCID:0000-0001-6960-357X
Susanna-Assunta Sansone, ORCID:0000-0001-5306-5690
Erik Schultes, ORCID:0000-0001-8888-635X
Luiz Olavo Bonino da Silva Santos, ORCID:0000-0002-1164-1351
Michel Dumontier, ORCID:0000-0003-4727-9435

#### Publication Date: 2019-02-26
#### Last Edit: 2019-02-26
#### Accepted: pending



### Maturity Indicator Identifier: Gen2_MI_F3 [https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F3](https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F3)

### Maturity Indicator Name:   Use of GUIDs in metadata

----

### To which principle does it apply?  
F3

### What is being measured?
Whether the metadata document contains both its own GUID (which may be different from its address),
and whether it also explicitly contains the GUID for the data resource it describes.

### Why should we measure it?
The discovery of digital object should be possible from its metadata. For this to happen,
the metadata must explicitly contain the identifier for the digital resource it describes,
and this should be present in the form of a qualified reference, indicating some manner of
"about" relationship, to distinguish this identifier from the numerous others that will
be present in the metadata.

In addition, since many digital objects cannot be arbitrarily extended to
include references to their metadata, in many cases the only means to
discover the metadata related to a digital object will be to search based
on the GUID of the digital object itself.


### What must be provided for the measurement?
The Metadata GUID.


### How is the measurement executed?
Metadata is harvested by:
1) resolving the GUID (following all redirects) with a Content-Type header specifically searching for some form of structured data.  e.g.
   'Accept: text/turtle, application/n3, application/rdf+n3, application/turtle, application/x-turtle,text/n3,text/turtle, text/rdf+n3, text/rdf+turtle,application/json+ld, text/xhtml+xml,application/rdf+xml,application/n-triples'
2) resolving any Link 'meta' HTTP Headers (processed independently according to this same process, but not iteratively)
3) parsing the response body either as a hash (for non-linked data) or as a Graph for linked data, or both.
4) All other data is passed to the 'extruct' tool (https://github.com/scrapinghub/extruct) or to the Apache Tika tool (https://tika.apache.org/) for deep exploration
5) Any linked or hash-type data found by those tools are merged with the existing Hash or Graph data

To locate the data identifier, hash data is tested for the keys:
 * codeRepository
 * mainEntity
 * primaryTopic
 * IAO:0000136 (is about)
 * IAO_0000136
 * SIO:000332 (is about)
 * SIO_000332
 * distribution
 * contains

Graph data is tested for the properties:
 * schema:codeRepository
 * schema:mainEntity
 * foaf:primaryTopic
 * IAO:0000136 (information artifact ontology 'is about')
 * SIO:000332 (SemanticScience Integrated Ontology 'is about')
 * schema:distribution
 * DCAT:distribution (Data Catalogue vocabulary)
 * ldp:contains (Linked Data Platform)

To locate the Metadata's GUID:
1) The values of all Hash keys are compared to the GUID provided to the test
(this is not a rigorous test, but the key name cannot be
predicted)
2) The Graph metadata is explored for the "objects" of each triple pattern-matching or exact-matching the provided GUID.

### What is/are considered valid result(s)?
Match found

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
A future iteration of this MI will require the use of specific predicates such as schema:identifier to
point to the GUID of the Metadata document itself.
