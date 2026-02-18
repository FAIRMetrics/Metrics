# TITLE:  FAIR Maturity Indicator Gen2-MI-F4

## Authors: 
Mark D. Wilkinson, ORCID:0000-0001-6960-357X
Susanna-Assunta Sansone, ORCID:0000-0001-5306-5690
Erik Schultes, ORCID:0000-0001-8888-635X
Luiz Olavo Bonino da Silva Santos, ORCID:0000-0002-1164-1351
Michel Dumontier, ORCID:0000-0003-4727-9435

#### Publication Date: 2019-02-26
#### Last Edit: 2019-02-26
#### Accepted: pending


### Maturity Indicator Identifier: Gen2_MI_F4 [https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F3](https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F4)

### Maturity Indicator Name:   Metadata indexed in a searchable resource

----

### To which principle does it apply?  
F4

### What is being measured?
The degree to which the digital resource can be found using web-based search engines.

### Why should we measure it?
Most people use a search engine to initiate a search for a particular digital resource of interest.
If the resource or its metadata are not indexed by web search engines,
then this would substantially diminish an individual’s ability to find and reuse it.
Thus, the ability to discover the resource should be tested using i) its identifier,
ii) other text-based metadata.


### What must be provided for the measurement?
The Metadata GUID.


### How is the measurement executed?
The provided GUID is resolved to its metadata (i.e. a document) and the address of that document
is captured (which may be distinct from the GUID itself)

The GUID is then used in a search.  The top 50 results of that search are compared to the
address of the metadata document.

Hash metadata is parsed for the keys "title", and "keywords", and those values are captured
and used in a search.  The top 50 results of that search are compared to the
address of the metadata document.

Graph metadata is queried for predicates containing "title" or "keyword", and those values are captured
and used in a search.  The top 50 results of that search are compared to the
address of the metadata document.


### What is/are considered valid result(s)?
Metadata document address is found in top 50 search results

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
