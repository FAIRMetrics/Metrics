# TITLE:  FAIR Metric Gen2-FM-I3

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2019


### Maturity Assessment Identifier: Gen2_FM-I3 [https://purl.org/fair-metrics/Gen2_FM_I3](https://purl.org/fair-metrics/Gen2_FM_I3)

### Maturity Assessment Name:   Qualified outward links

----

### To which principle does it apply?  
I3

### What is being measured?
Does the linked data metadata contain links that are not from the same source (domain/host)

### Why should we measure it?
Data silos thwart interoperability. Thus, we should reasonably expect that some of the references/relations point outwards to other resources, owned by third-parties; this is one of the requirements for 5 star linked data.

### What must be provided for the measurement?
The GUID.


### How is the measurement executed?
The URI-representation of the priovided GUID is examined for its domain name.
Any Linked Data that can be found after resolution of the GUID is parsed
to determine the hostname of the object-resources.  A count is made of the number of objects
that have a different domain from that of the originating host.  This Maturity Indicator could be made quantitative
if a test wanted to be very strict.


### What is/are considered valid result(s)?
Discovery of third-party URIs as objets of triples

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
