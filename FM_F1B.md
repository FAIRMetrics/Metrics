# TITLE:  FAIR Metric FM-F1B

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2017


### Maturity Assessment Identifier: FM-F1B [https://purl.org/fair-metrics/FM_F1B](https://purl.org/fair-metrics/FM_F1B)

### Maturity Assessment Name:   Identifier persistence
----

### To which principle does it apply?  
F1

### What is being measured?
Whether there is a policy that describes what the provider will do in the event an identifier scheme becomes deprecated.


### Why should we measure it?
The change to an identifier scheme will have widespread implications for resource lookup, linking, and data sharing. Providers of digital resources must ensure that they have a policy to manage changes in their identifier scheme, with a specific emphasis on maintaining/redirecting previously generated identifiers.

### What must be provided for the measurement?
A URL that resolves to a document containing the relevant policy.

### How is the measurement executed?
Use an HTTP GET on URL provided. 

### What is/are considered valid result(s)?
Present (a 200,202,203 or 206 HTTP response after resolving all and any prior redirects. e.g. 301 -> 302 -> 200 OK) or Absent (any other HTTP code)


### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
