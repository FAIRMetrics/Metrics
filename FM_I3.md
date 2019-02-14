# TITLE:  FAIR Metric FM-I

## Authors: 
Mark D. Wilkinson, Susanna-Assunta Sansone, Erik Schultes, Peter Doorn,
Luiz Olavo Bonino da Silva Santos, Michel Dumontier

#### Date: 2017


### Maturity Assessment Identifier: FM-I3 [https://purl.org/fair-metrics/FM_I3](https://purl.org/fair-metrics/FM_I3)

### Maturity Assessment Name: Use Qualified References
----

### To which principle does it apply?  
I3 - (meta)data include qualified references to other (meta)data



### What is being measured?

Relationships within (meta)data, and between local and third-party data, have explicit and ‘useful’ semantic meaning



### Why should we measure it?

One of the reasons that HTML is not suitable for machine-readable knowledge representation is that the hyperlinks between one document and another do not explain the nature of the relationship - it is “unqualified”.  For Interoperability, the relationships within and between data must be more semantically rich than “is (somehow) related to”.\newline 
 
Numerous ontologies include richer relationships that can be used for this purpose, at various levels of domain-specificity.  For example, the use of skos for terminologies (e.g. exact matches), or the use of SIO for genomics (e.g. “has phenotype” for the relationship between a variant and its phenotypic consequences).  The semantics of the relationship do not need to be "strong" - for example, "objectX  wasFoundInTheSameBoxAs objectY" is an acceptable qualified reference\newline 

Similarly, dbxrefs must be predicated with a meaningful relationship  what is the nature of the cross-reference?\newline 

Finally, data silos thwart interoperability.  Thus, we should reasonably expect that some of the references/relations point outwards to other resources, owned by third-parties; this is one of the requirements for 5 star linked data. \newline 


### What must be provided for the measurement?

Linksets (in the formal sense) representing part or all of your resource


### How is the measurement executed?

The linksets must have qualified references

At least one of the links must be in a different Web domain (or the equivalent of a different namespace for non-URI identifiers)


### What is/are considered valid result(s)?

- References are qualified\newline
- Qualities are beyond “Xref” or “is related to”\newline
- One of the cross-references points outwards to a distinct namespace\newline



### For which digital resource(s) is this relevant? (or 'all')
All

### Examples of good practices (that would score well on this assessment)


### Comments
