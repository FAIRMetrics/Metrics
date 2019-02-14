# TITLE:  FAIR Metric FM-R1.2

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2017


### Maturity Assessment Identifier: FM-R1.2 [https://purl.org/fair-metrics/FM_R1.2](https://purl.org/fair-metrics/FM_R1.2)

### Maturity Assessment Name: Detailed Provenance
----

### To which principle does it apply?  

R1.2 - (meta)data are associated with detailed provenance



### What is being measured?


That there is provenance information associated with the data, covering at least two primary types of provenance information:\newline 

- Who/what/When produced the data (i.e. for citation)\newline 
- Why/How was the data produced (i.e. to understand context and relevance of the data)



### Why should we measure it?

Reusability is not only a technical issue; data can be discovered, retrieved, and even be machine-readable, but still not be reusable in any rational way.  Reusability goes beyond “can I reuse this data?” to other important questions such as “may I reuse this data?”, “should I reuse this data”, and “who should I credit if I decide to use it?”



### What must be provided for the measurement?

Several IRIs -  at least one of these points to one of the vocabularies used to describe citational provenance (e.g. dublin core).  At least one points to one of the vocabularies (likely domain-specific) that is used to describe contextual provenance (e.g. EDAM)


### How is the measurement executed?


We resolve the IRI according to their associated protocols.  



### What is/are considered valid result(s)?


IRI 1 should resolve to a recognized citation provenance standard such as Dublin Core.\newline 

IRI 2 should resolve to some vocabulary that itself passes basic tests of FAIRness\newline


### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments

In the future, we may be able to cross-reference these with FAIRSharing to confirm that they are "standard", and perhaps even distinguish citation vs. domain specific.
