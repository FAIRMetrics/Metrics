# TITLE:  FAIR Metric FM-F3

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2017


### Maturity Assessment Identifier: FM-F3 [https://purl.org/fair-metrics/FM_F3](https://purl.org/fair-metrics/FM_F3)

### Maturity Assessment Name:  Resource Identifier in Metadata
----

### To which principle does it apply?  
F3 - metadata clearly and explicitly include the identifier of the data it describes

### What is being measured?
Whether the metadata document contains the globally unique and persistent identifier for the digital resource.

### Why should we measure it?
The discovery of digital object should be possible from its metadata. For this to happen, the metadata must explicitly contain the identifier for the digital resource it describes, and this should be present in the form of a qualified reference, indicating some manner of "about" relationship, to distinguish this identifier from the numerous others that will be present in the metadata.

In addition, since many digital objects cannot be arbitrarily extended to include references to their metadata, in many cases the only means to discover the metadata related to a digital object will be to search based on the GUID of the digital object itself.

### What must be provided for the measurement?

The GUID of the metadata and the GUID of the digital resource it describes.


### How is the measurement executed?
Parsing the metadata for the given digital resource GUID.


### What is/are considered valid result(s)?
Present or absent

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
