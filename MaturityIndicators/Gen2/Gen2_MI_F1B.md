# TITLE:  FAIR Maturity Indicator Gen2-MI-F1B

## Authors: 
Mark D. Wilkinson, ORCID:0000-0001-6960-357X
Susanna-Assunta Sansone, ORCID:0000-0001-5306-5690
Erik Schultes, ORCID:0000-0001-8888-635X
Luiz Olavo Bonino da Silva Santos, ORCID:0000-0002-1164-1351
Michel Dumontier, ORCID:0000-0003-4727-9435

#### Publication Date: 2019-02-26
#### Last Edit: 2019-02-26
#### Accepted: pending


### Maturity Indicator Identifier: Gen2_MI_F1B [https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F1B](https://w3id.org/fair/maturity_indicator/terms/Gen2/Gen2_MI_F1B)

### Maturity Indicator Name:   Identifier Persistence

----

### To which principle does it apply?  
F1

### What is being measured?
Whether the GUID matches (regexp) a GUID scheme recognized as being persistent.
This includes identifiers in the FAIRSharing registry that are known to be persistent:
 * InChI Keys
 * DOIs
 * Handles

For URLs, we test widely-used PURLs, currently:
 * purl
 * oclc
 * fdlp
 * purlz
 * w3id
 * ark

If you want an additional identifier scheme added to this Maturity Indicator, please let us know, and please register it with FAIRSharing.


### Why should we measure it?
The change to an identifier scheme will have widespread implications for resource lookup,
linking, and data sharing. Providers of digital resources must try to use GUID types that
are guaranteed, by stable third-parties, to be persistent.  This includes stable providers of
PURLs.

### What must be provided for the measurement?
The Metadata GUID.


### How is the measurement executed?
Identifier scheme of the GUID is determined by pattern-match for Handle, DOI, InChI.  For URLs
 we do further pattern-matches to determine if it matches the pattern for:
 * purl
 * oclc
 * fdlp
 * purlz
 * w3id
 * ark


### What is/are considered valid result(s)?
match successful

### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
