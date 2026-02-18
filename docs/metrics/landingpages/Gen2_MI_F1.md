# TITLE:  FAIR Maturity Indicator Gen2-MI-F1A

## Authors: 
Mark D. Wilkinson, ORCID:0000-0001-6960-357X
Susanna-Assunta Sansone, ORCID:0000-0001-5306-5690
Erik Schultes, ORCID:0000-0001-8888-635X
Luiz Olavo Bonino da Silva Santos, ORCID:0000-0002-1164-1351
Michel Dumontier, ORCID:0000-0003-4727-9435

#### Publication Date: 2019-02-26
#### Last Edit: 2019-02-26
#### Accepted: pending



### Maturity Indicator Identifier: Gen2_MI_F1A [https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F1A](https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F1A)

### Maturity Indicator Name:   Identifier Uniqueness

----

### To which principle does it apply?  
F1

### What is being measured?
Whether the GUID matches (regexp) a GUID scheme recognized as being globally unique in the FAIRSharing registry.

Currently, we test:
 * InChI Keys
 * DOIs
 * Handles
 * URLs

If you want an additional identifier scheme added to this Maturity Indicator, please let us know, and please register it with FAIRSharing.


### Why should we measure it?
The uniqueness of an identifier is a necessary condition to unambiguously refer that resource, and that resource alone. Otherwise, an identifier shared by multiple resources will confound efforts to describe that resource, or to use the identifier to retrieve it. Examples of identifier schemes include, but are not limited to URN, IRI, DOI, Handle, trustyURI, LSID, etc. For an in-depth understanding of the issues around identifiers, please see http://dx.plos.org/10.1371/journal.pbio.2001414

### What must be provided for the measurement?
The Metadata GUID.


### How is the measurement executed?
An identifier scheme is valid if and only if it
 * can be recognized by a machine (regular expression)
 * follows a GUID pattern registered in FAIRSharing
 * The FAIRSharing registration acknowledges that the scheme guarantees global uniqueness


### What is/are considered valid result(s)?
Matches the regular expression for a GUID type registered with FAIRSharing that is flagged as guaranteeing global uniqueness

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
