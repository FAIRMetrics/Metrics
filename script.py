from rdflib import ConjunctiveGraph, URIRef
from rdflib.namespace import DCTERMS, RDFS, FOAF
from rdflib.namespace import Namespace

fairGraph = ConjunctiveGraph()
# fairGraph.parse('http://purl.org/fair-ontology#', format='trig')

g = ConjunctiveGraph()
g.parse('FM_A1.1', format='trig')
#for ctx in g.contexts():
#    print ctx.identifier, '----------'
#    for s,p,o in ctx:
#        print s,p,o
#    print '=================================='

FM = Namespace('https://purl.org/fair-metrics/terms/')


class FairMetricData():
    def __init__(self, id):
        self.base = 'https://purl.org/fair-metrics/'
        self.id = URIRef(id)
        print "TODO: really should parse g from ID"
        self.g = g
        self.assertion = URIRef(id+'#assertion')

    def getID(self):
        return self.id

    def getShortID(self):
        return self.id.replace(self.base, '')

    def getAuthors(self):
        return [o for o in self.g.objects(subject=self.assertion, predicate=DCTERMS.author)]

    def getTitle(self):
        return [o for o in self.g.objects(subject=self.assertion, predicate=RDFS.comment)]

    def getShortTitle(self):
        return [o for o in self.g.objects(subject=self.assertion, predicate=DCTERMS.title)]

    def getTopicDescription(self):
        descs = []
        for o in self.g.objects(subject=self.id, predicate=FOAF.primaryTopic):
            # o should be fair:A1.1
            for o2 in fairGraph.objects(subject=o, predicate=DCTERMS.description):
                descs.append(o2)
        return descs

    def getTopicTitle(self):
        descs = []
        for o in self.g.objects(subject=self.id, predicate=FOAF.primaryTopic):
            # o should be fair:A1.1
            for o2 in fairGraph.objects(subject=o, predicate=DCTERMS.title):
                descs.append(o2)
        return descs

    def getMeasuring(self):
        # return fm:measuring
        pred = FM.measuring
        return [o for o in self.g.objects(subject=self.assertion, predicate=pred)]

    def getReason(self):
        # return fm:reason
        pred = FM.reason
        return [o for o in self.g.objects(subject=self.assertion, predicate=pred)]

    def getRequirements(self):
        # return fm:requirements
        pred = FM.requirements
        return [o for o in self.g.objects(subject=self.assertion, predicate=pred)]

    def getProcedure(self):
        # return fm:procedure
        pred = FM.procedure
        return [o for o in self.g.objects(subject=self.assertion, predicate=pred)]

    def getValidation(self):
        # return fm:validation
        pred = FM.validation
        return [o for o in self.g.objects(subject=self.assertion, predicate=pred)]

    def getRelevance(self):
        # return fm:relevance
        pred = FM.relevance
        return [o for o in self.g.objects(subject=self.assertion, predicate=pred)]

    def getExamples(self):
        # return fm:examples
        pred = FM.examples
        return [o for o in self.g.objects(subject=self.assertion, predicate=pred)]

    def getComments(self):
        # return fm:comments
        pred = FM.comments
        return [o for o in self.g.objects(subject=self.assertion, predicate=pred)]


# The idea is that we could fill the table http://fairmetrics.org/fairmetricform.html
# from a given metric IRI
id = 'https://purl.org/fair-metrics/FM_A1.1'
fm = FairMetricData(id)
print fm.getShortID() + " - " + fm.getID()
print fm.getAuthors()
print fm.getTitle()
print fm.getShortTitle()
print fm.getTopicTitle()
print fm.getTopicDescription()
print fm.getMeasuring()
print fm.getReason()
print fm.getRequirements()
print fm.getProcedure()
print fm.getValidation()
print fm.getRelevance()
print fm.getExamples()
print fm.getComments()
