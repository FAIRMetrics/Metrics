# TITLE:  FAIR Metric Gen2-FM-F2A

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2019


### Maturity Assessment Identifier: Gen2_FM-F2A [https://purl.org/fair-metrics/Gen2_FM_F2A](https://purl.org/fair-metrics/Gen2_FM_F2A)

### Maturity Assessment Name:   Structured Metadata

----

### To which principle does it apply?  
F2

### What is being measured?
Whether the metadata of the record contains "structured" elements.
These may be in the form of hash-like content (micrograph, JSON),
or in one of the various forms of linked data (JSON-LD, RDFa, etc.)

### Why should we measure it?
Structured data is inherently easier for machines to accurately process and
interpret.  Even loosely structured metadata can have reliable parsers built
to consume it, including those of major search engines.  Thus, it improves
the findability of the record.

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
6) The Hash and Graph are interrogated v.v. if they contain any data

### What is/are considered valid result(s)?
Hash or Graph contains data.

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
