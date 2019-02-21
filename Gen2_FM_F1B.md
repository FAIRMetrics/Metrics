# TITLE:  FAIR Metric Gen2-FM-F1B

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2019


### Maturity Assessment Identifier: Gen2_FM-F1B [https://purl.org/fair-metrics/Gen2_FM_F1B](https://purl.org/fair-metrics/Gen2_FM_F1B)

### Maturity Assessment Name:   Identifier Persistence

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

If you want an additional identifier scheme added to this Metric, please let us know, and please register it with FAIRSharing.


### Why should we measure it?
The change to an identifier scheme will have widespread implications for resource lookup,
linking, and data sharing. Providers of digital resources must try to use GUID types that
are guaranteed, by stable third-parties, to be persistent.  This includes stable providers of
PURLs.

### What must be provided for the measurement?
The GUID.


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
