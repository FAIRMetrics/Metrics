# TITLE:  FAIR Metric FM-A1.1

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2017


### Maturity Assessment Identifier: FM-A1.1 [https://purl.org/fair-metrics/FM_A1.1](https://purl.org/fair-metrics/FM_A1.1)

### Maturity Assessment Name:  Access Protocol

----

### To which principle does it apply?  
A1.1 - the protocol is open, free, and universally implementable

### What is being measured?
The nature and use limitations of the access protocol.

### Why should we measure it?
Access to a resource may be limited by the specified communication protocol. In particular, we are worried about access to technical specifications and any costs associated with implementing the protocol. Protocols that are closed source or that have royalties associated with them could prevent users from being able to obtain the resource.


### What must be provided for the measurement?

i) A URL to the description of the protocol
ii) true/false as to whether the protocol is open source
iii) true/false as to whether the protocol is (royalty) free



### How is the measurement executed?
Do an HTTP get on the URL to see if it returns a valid document. Ideally, we would have a universal database of communication protocols from which we can check this URL (this is now being created in FAIRSharing). We also check whether questions 2 and 3 are true or false.  


### What is/are considered valid result(s)?
The HTTP GET on the URL should return a 200,202,203 or 206 HTTP response after resolving all and any prior redirects. e.g. 301 - 302 - 200 OK. The other two should return true/false ("true" is success)


### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
