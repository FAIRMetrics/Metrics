# TITLE:  FAIR Metric FM-A1.2

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2017


### Maturity Assessment Identifier: FM-A1.2 [https://purl.org/fair-metrics/FM_A1.2](https://purl.org/fair-metrics/FM_A1.2)

### Maturity Assessment Name:  Access authorization

----

### To which principle does it apply?  
A1.2 - the protocol allows for an authentication and authorization procedure, where necessary

### What is being measured?
Specification of a protocol to access restricted content.

### Why should we measure it?
Not all content can be made available without restriction. For instance, access and distribution of personal health data may be restricted by law or by organizational policy. In such cases, it is important that the protocol by which such content can be accessed is fully specified. Ideally, electronic content can be obtained first by applying for access. Once the requester is formally authorized to access the content, they may receive it in some electronic means, for instance by obtaining an download URL, or through a more sophisticated transaction mechanism (e.g. authenticate, authorize), or by any other means. The goal should be to reduce the time it takes for valid requests to be fulfilled. 


### What must be provided for the measurement?

i) true/false concerning whether authorization is needed\newline 
ii) a URL that resolves to a description of the process to obtain access to restricted content.\newline 



### How is the measurement executed?

computational validation of the data provided


### What is/are considered valid result(s)?

a valid answer contains a true or false for the first question. if true, an HTTP GET on the URL provided should return a 200, 202, 203, or 206 HTTP Response after resolving all redirects.


### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
