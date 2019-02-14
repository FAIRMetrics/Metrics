# TITLE:  FAIR Metric FM-F4

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2017


### Maturity Assessment Identifier: FM-F4 [https://purl.org/fair-metrics/FM_F4](https://purl.org/fair-metrics/FM_F4)

### Maturity Assessment Name:  Indexed in a searchable resource
----

### To which principle does it apply?  
F4 - (meta)data are registered or indexed in a searchable resource

### What is being measured?
The degree to which the digital resource can be found using web-based search engines.


### Why should we measure it?
Most people use a search engine to initiate a search for a particular digital resource of interest. If the resource or its metadata are not indexed by web search engines, then this would substantially diminish an individual’s ability to find and reuse it. Thus, the ability to discover the resource should be tested using i) its identifier, ii) other text-based metadata. 


### What must be provided for the measurement?

The persistent identifier of the resource and one or more URLs that give search results of different search engines.


### How is the measurement executed?
We perform an HTTP GET on the URLs provided and attempt to to find the persistent identifier in the page that is returned. A second step might include following each of the top XX hits and examine the resulting documents for presence of the identifier. 


### What is/are considered valid result(s)?
Present or absent in the result set 


### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
 should set a "top 50" or something
