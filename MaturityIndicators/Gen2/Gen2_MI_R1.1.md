# TITLE:  FAIR Maturity Indicator Gen2-MI-R1.1

## Authors: 
Mark D. Wilkinson, ORCID:0000-0001-6960-357X
Susanna-Assunta Sansone, ORCID:0000-0001-5306-5690
Erik Schultes, ORCID:0000-0001-8888-635X
Luiz Olavo Bonino da Silva Santos, ORCID:0000-0002-1164-1351
Michel Dumontier, ORCID:0000-0003-4727-9435

#### Publication Date: 2019-02-26
#### Last Edit: 2019-02-26
#### Accepted: pending


### Maturity Indicator Identifier: Gen2_MI_R1.1 [https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_R1.1](https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_R1.1)

### Maturity Indicator Name:   Metadata contains link to license

----

### To which principle does it apply?  
R1.1

### What is being measured?
A pointer in the metadata to the data license

### Why should we measure it?
Data that does not have a license cannot (legitimately) be reused, since the conditions of that reuse are not known.



### What must be provided for the measurement?
The Metadata GUID.


### How is the measurement executed?
In hash-style (key/value) metadata, search for a "license" key.  The value may be a link or a string
In Linked-data style metadata, search for one of the following predicates:
http://www.w3.org/1999/xhtml/vocab#license https://www.w3.org/1999/xhtml/vocab#license>
http://purl.org/ontology/dvia#hasLicense https://purl.org/ontology/dvia#hasLicense>
http://purl.org/dc/terms/license https://purl.org/dc/terms/license>
http://creativecommons.org/ns#license https://creativecommons.org/ns#license>
http://reference.data.gov.au/def/ont/dataset#hasLicense https://reference.data.gov.au/def/ont/dataset#hasLicense>

Test the value of that predicate to ensure it resolves (all of these have a range that is a Resource)


### What is/are considered valid result(s)?
"License" key exists, or one of the above predicates exists, and has a resolvable URI as its value


### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
