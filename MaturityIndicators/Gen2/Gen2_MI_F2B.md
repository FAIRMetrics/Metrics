# TITLE:  FAIR Maturity Indicator Gen2-MI-F2B

## Authors: 
Mark D. Wilkinson, ORCID:0000-0001-6960-357X
Susanna-Assunta Sansone, ORCID:0000-0001-5306-5690
Erik Schultes, ORCID:0000-0001-8888-635X
Luiz Olavo Bonino da Silva Santos, ORCID:0000-0002-1164-1351
Michel Dumontier, ORCID:0000-0003-4727-9435

#### Publication Date: 2019-02-26
#### Last Edit: 2019-02-26
#### Accepted: pending


### Maturity Indicator Identifier: Gen2_MI_F2B [https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F2B](https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F2B)

### Maturity Indicator Name:   Grounded Metadata

----

### To which principle does it apply?  
F2

### What is being measured?
Whether the metadata of the record contains "structured" elements that are
"grounded" in shared vocabularies.  For example, in one of the various forms
of linked data (JSON-LD, RDFa, Turtle, etc.)

### Why should we measure it?
Structured, grounded data is inherently easier for machines to accurately process and
interpret, in particular by generic agents, who are able to precisely determine the
meaning of an element based on it being a GUID (and thus, more FAIR)

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
6) The Graph is interrogated v.v. if it contains any data

### What is/are considered valid result(s)?
Graph contains data.

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
BEWARE:  Apache Tika is capable of extracting metadata, in the form of Linked Data, from a wide range of opaue file-types such as PDFs and images.
This process will therefore return Linked Data that can only be found using a special tool.  Therefore, passing this
Maturity Indicator does not mean that the publisher has *actively* made grounded metadata available.
