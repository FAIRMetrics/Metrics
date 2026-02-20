# TITLE:  FAIR Maturity Indicator Champ-MI-F3

## Authors: 
Mark D. Wilkinson, ORCID:0000-0001-6960-357X


#### Publication Date: 2026-02-20
#### Last Edit: 2026-02-20

### Maturity Indicator Identifier:[Champ_MI_F3](https://w3id.org/fair-metrics/general/champ-mi-f3.ttl)

### Maturity Indicator Name:   Use of GUIDs in metadata

----

### To which principle does it apply?  
F3

### Applicable Research Domain
[Subject Agnostic]("http://www.fairsharing.org/ontology/subject/SRAO_0000401")

### Applicable Datatype
[Dataset] ("https://schema.org/Dataset")


### What is being measured?
Whether the metadata document contains both its own GUID (which may be different from its address),
and whether it also explicitly contains the GUID for the data resource it describes.

### Why should we measure it?
The discovery of digital object should be possible from its metadata. For this to happen,
the metadata must explicitly contain the identifier for the digital resource it describes,
and this should be present in the form of a qualified reference, indicating some manner of
"about" relationship, to distinguish this identifier from the numerous others that will
be present in the metadata.

In addition, since many digital objects cannot be arbitrarily extended to
include references to their metadata, in many cases the only means to
discover the metadata related to a digital object will be to search based
on the GUID of the digital object itself.



### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
A future iteration of this MI will require the use of specific predicates such as schema:identifier to
point to the GUID of the Metadata document itself.
