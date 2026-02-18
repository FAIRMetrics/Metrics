# TITLE:  FAIR Maturity Indicator Gen2-MI-I3

## Authors: 
Mark D. Wilkinson, ORCID:0000-0001-6960-357X
Susanna-Assunta Sansone, ORCID:0000-0001-5306-5690
Erik Schultes, ORCID:0000-0001-8888-635X
Luiz Olavo Bonino da Silva Santos, ORCID:0000-0002-1164-1351
Michel Dumontier, ORCID:0000-0003-4727-9435

#### Publication Date: 2019-02-26
#### Last Edit: 2019-02-26
#### Accepted: pending


### Maturity Indicator Identifier: Gen2_MI_I3 [https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_I3](https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_I3)

### Maturity Indicator Name:   Qualified outward links

----

### To which principle does it apply?
I3

### What is being measured?
Does the linked data metadata contain links that are not from the same source (domain/host)

### Why should we measure it?
Data silos thwart interoperability. Thus, we should reasonably expect that some of the references/relations point outwards to other resources, owned by third-parties; this is one of the requirements for 5 star linked data.

### What must be provided for the measurement?
The Metadata GUID.


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
