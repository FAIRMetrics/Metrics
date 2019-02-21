# TITLE:  FAIR Metric Gen2-FM-I2A

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2019


### Maturity Assessment Identifier: Gen2_FM-I2A [https://purl.org/fair-metrics/Gen2_FM_I2A](https://purl.org/fair-metrics/Gen2_FM_I2A)

### Maturity Assessment Name:   Uses FAIR Vocabularies (loose)

----

### To which principle does it apply?  
I2

### What is being measured?
If the (meta)data uses vocabularies that are, themselves, FAIR

### Why should we measure it?
It is not possible to unambiguously interpret metadata represented as simple keywords or other non-qualified symbols. For interoperability, it must be possible to identify data that can be integrated like-with-like. This requires that the data, and the provenance descriptors of the data, should (where reasonable) use vocabularies and terminologies that are, themselves, FAIR.

In this loose metric, we test only if the vocabulary terms resolve (e.g. to a human-readable page).  We do not test
if they resolve to machine-readable information.  A second Metric (Gen2-FM-I2B) is for that stricter test.


### What must be provided for the measurement?
The GUID.


### How is the measurement executed?
Any Linked Data that can be found is tested for the resolution of a subset of properties (predicates) present in it.
Some proportion of these should resolve (the creator of the associated Maturity Test will decide what that
proportion should be)


### What is/are considered valid result(s)?
Successful resolution of a proportion of predicates in Linked Data

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
