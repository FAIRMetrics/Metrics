# TITLE:  FAIR Metric FM-F2

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2017


### Maturity Assessment Identifier: FM-F2 [https://purl.org/fair-metrics/FM_F2](https://purl.org/fair-metrics/FM_F2)

### Maturity Assessment Name:   Machine-readability of metadata
----

### To which principle does it apply?  
F2 - Data are described with rich metadata

### What is being measured?
The availability of machine-readable metadata that describes a digital resource.

### Why should we measure it?
This metric _does not_ attempt to measure (or even define) "Richness" - this will be defined in a future Metric.  This metric is intended to test the format of the metadata - machine readability of metadata makes it possible to optimize discovery. For instance, Web search engines suggest the use of particular structured metadata elements to optimize search. Thus, the machine-readability aspect can help people and machines find a digital resource of interest. 

### What must be provided for the measurement?
A URL to a document that contains machine-readable metadata for the digital resource. Furthermore, the file format must be specified.


### How is the measurement executed?
HTTP GET on the metadata URL. A response of [a 200,202,203 or 206 HTTP response after resolving all and any prior redirects. e.g. 301 -> 302 -> 200 OK] indicates that there is indeed a document. The second URL should resolve to the record of a registered file format (e.g. DCAT, DICOM, schema.org etc.) in a registry like FAIRsharing.  Future ehnancements to FAIRSharing may include tags that indicate whether or not a given file format is generally-agreed to be machine-readable \newline


### What is/are considered valid result(s)?
Machine-readable or Machine-not-readable

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
