# TITLE:  FAIR Maturity Indicator Gen2-MI-A1.2

## Authors: 
Mark D. Wilkinson, ORCID:0000-0001-6960-357X
Susanna-Assunta Sansone, ORCID:0000-0001-5306-5690
Erik Schultes, ORCID:0000-0001-8888-635X
Luiz Olavo Bonino da Silva Santos, ORCID:0000-0002-1164-1351
Michel Dumontier, ORCID:0000-0003-4727-9435

#### Publication Date: 2019-02-26
#### Last Edit: 2019-02-26
#### Accepted: pending



### Maturity Indicator Identifier: Gen2_MI_A1.2 [https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_A1.2](https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_A1.2)

### Maturity Indicator Name:   Protocol supports authentication/authorization

----

### To which principle does it apply?  
A1.2

### What is being measured?
If the resolution protocol supports authentication and authorization for access to restricted content

### Why should we measure it?
Not all content can be made available without restriction. For instance, access and distribution of personal health data may be restricted by law or by organizational policy. In such cases, it is important that the protocol by which such content can be accessed is fully specified. Ideally, electronic content can be obtained first by applying for access. Once the requester is formally authorized to access the content, they may receive it in some electronic means, for instance by obtaining an download URL, or through a more sophisticated transaction mechanism (e.g. authenticate, authorize), or by any other means. The goal should be to reduce the time it takes for valid requests to be fulfilled.



### What must be provided for the measurement?
The Metadata GUID.


### How is the measurement executed?
The GUID (either data or metadata) is mapped to a resolution protocol.  The FAIRSharing registry is asked
if that protocol supports authentication/authorization.  In addition, if a link using the Dublin Core "accessRights"
property is found in the metadata, this is acceptable.


### What is/are considered valid result(s)?
FAIRSharing registry says the protocol supports authentication/authorization, or the metadata contains a dc:accessRights property with a value (either string or link)

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
