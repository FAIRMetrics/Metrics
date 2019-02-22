# TITLE:  FAIR Metric Gen2-FM-F3

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2019


### Maturity Assessment Identifier: Gen2_FM-F3 [https://purl.org/fair-metrics/Gen2_FM_F3](https://purl.org/fair-metrics/Gen2_FM_F3)

### Maturity Assessment Name:   Use of GUIDs in metadata

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
The GUID.


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

Graph data is tested for the properties:
 * schema:codeRepository
 * schema:mainEntity
 * foaf:primaryTopic
 * IAO:0000136 (information artifact ontology 'is about')
 * SIO:000332 (SemanticScience Integrated Ontology 'is about')
 * schema:distribution
 * DCAT:distribution (Data Catalogue vocabulary)

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
A future iteration of this metric will require the use of specific predicates such as schema:identifier to
point to the GUID of the Metadata document itself.