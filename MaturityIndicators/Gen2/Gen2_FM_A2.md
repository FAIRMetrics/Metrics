# TITLE:  FAIR Metric Gen2-FM-A2

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2019


### Maturity Assessment Identifier: Gen2_FM-A2 [https://purl.org/fair-metrics/Gen2_FM_A2](https://purl.org/fair-metrics/Gen2_FM_A2)

### Maturity Assessment Name:   Metadata persistence

----

### To which principle does it apply?  
A2

### What is being measured?
If there is a policy for metadata persistence

### Why should we measure it?
Cross-references to data from third-party’s FAIR data and metadata will naturally degrade over time, and become “stale links”. In such cases, it is important for FAIR providers to continue to provide descriptors of what the data was to assist in the continued interpretation of those third-party data. As per FAIR Principle F3, this metadata remains discoverable, even in the absence of the data, because it contains an explicit reference to the IRI of the data.



### What must be provided for the measurement?
The GUID.


### How is the measurement executed?
The GUID is resolved.  Any hash-style metadata (e.g. JSON or microformat) is queried for a 'persistencePolicy' key.
If that key exists, the test passes.  Any Linked Data is queried for the http://www.w3.org/2000/10/swap/pim/doc#persistencePolicy
predicate.  The range of that predicate is required to be a URI, and this URI is tested to ensure it resolves to somthing.



### What is/are considered valid result(s)?
The presence of a persistencePolicy key, or a http://www.w3.org/2000/10/swap/pim/doc#persistencePolicy triple that
has a resolvable object resource.

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
