import os
import sys
import jinja2

from rdflib import ConjunctiveGraph, URIRef
from rdflib.namespace import DCTERMS, RDFS, FOAF
from rdflib.namespace import Namespace

args = sys.argv
if len(args)!=2:
    raise Exception('Expected metric IRI as input')

FM = Namespace('https://purl.org/fair-metrics/terms/')

fairGraph = ConjunctiveGraph()
fairGraph.parse('http://purl.org/fair-ontology#', format='trig')

fairTermGraph = ConjunctiveGraph()
fairTermGraph.parse('terms', format='n3')

class FairMetricData():
    def __init__(self, id):
        self.base = 'https://purl.org/fair-metrics/'
        self.id = URIRef(id)
        self.assertion = URIRef(id+'#assertion')

        id = id.replace(self.base, '')  # HACK -- remove this line before merging commit
        self.g = ConjunctiveGraph()
        self.g.parse(id, format='trig')

    def getID(self):
        return self.id

    def getShortID(self):
        return self.id.replace(self.base, '')

    def getAuthors(self):
        authors = [o.toPython() for o in self.g.objects(subject=self.assertion, predicate=DCTERMS.author)]
        authors.sort()
        return ' \\\\ '.join(authors)

    def getTitle(self):
        return ', '.join([o.toPython() for o in self.g.objects(subject=self.assertion, predicate=RDFS.comment)])

    def getShortTitle(self):
        return ', '.join([o.toPython() for o in self.g.objects(subject=self.assertion, predicate=DCTERMS.title)])

    def getTopicDescription(self):
        descs = []
        for o in self.g.objects(subject=self.id, predicate=FOAF.primaryTopic):
            # o should be fair:A1.1
            for o2 in fairGraph.objects(subject=o, predicate=DCTERMS.description):
                descs.append(o2.toPython())
        return ' '.join(descs)

    def getTopicTitle(self):
        descs = []
        for o in self.g.objects(subject=self.id, predicate=FOAF.primaryTopic):
            # o should be fair:A1.1
            for o2 in fairGraph.objects(subject=o, predicate=DCTERMS.title):
                descs.append(o2.toPython())
        return ' '.join(descs)

    def getMeasuring(self):
        # return fm:measuring
        return self.getFMPropertyValue(FM.measuring)

    def getReason(self):
        # return fm:reason
        return self.getFMPropertyValue(FM.reason)

    def getRequirements(self):
        # return fm:requirements
        return self.getFMPropertyValue(FM.requirements)

    def getProcedure(self):
        # return fm:procedure
        return self.getFMPropertyValue(FM.procedure)

    def getValidation(self):
        # return fm:validation
        return self.getFMPropertyValue(FM.validation)

    def getRelevance(self):
        # return fm:relevance
        return self.getFMPropertyValue(FM.relevance)

    def getExamples(self):
        # return fm:examples
        return self.getFMPropertyValue(FM.examples)

    def getComments(self):
        # return fm:comments
        return self.getFMPropertyValue(FM.comments)

    def getFMPropertyLabel(self, property):
        return ', '.join([ o.toPython() for o in fairTermGraph.objects(subject=FM[property], predicate=RDFS['label'])])

    def getFMPropertyValue(self, property):
        return ', '.join([o.toPython() for o in self.g.objects(subject=self.assertion, predicate=property)])


# The idea is that we could fill the table http://fairmetrics.org/fairmetricform.html
# from a given metric IRI
# id = 'https://purl.org/fair-metrics/FM_A1.1'
metricFile = args[1]
id = 'https://purl.org/fair-metrics/' + metricFile

fm = FairMetricData(id)

latex_jinja_env = jinja2.Environment(
	variable_start_string = '\VAR{',
	variable_end_string = '}',
	trim_blocks = True,
	autoescape = False,
	loader = jinja2.FileSystemLoader(os.path.abspath('.'))
)
template = latex_jinja_env.get_template('template.tex')


title=fm.getTitle()
authors=fm.getAuthors()
metricId=fm.getShortID().replace('_','-')   # Avoid _ in latex template
metricIdVerb=fm.getID()
shortTitle=fm.getShortTitle()
topicTitle=fm.getTopicTitle()
topicDesription=fm.getTopicDescription()
measuring=fm.getMeasuring()
reason=fm.getReason()
requirements=fm.getRequirements().replace('\n','\\newline\n')
procedure=fm.getProcedure()
validation=fm.getValidation()
relevance=fm.getRelevance()
examples=fm.getExamples()
comments=fm.getComments()
measuringLabel=fm.getFMPropertyLabel('measuring')
reasonLabel=fm.getFMPropertyLabel('reason')
requirementsLabel=fm.getFMPropertyLabel('requirements')
procedureLabel=fm.getFMPropertyLabel('procedure')
validationLabel=fm.getFMPropertyLabel('validation')
relevanceLabel=fm.getFMPropertyLabel('relevance')
examplesLabel=fm.getFMPropertyLabel('examples')
commentsLabel=fm.getFMPropertyLabel('comments')


print(template.render(
    title=title,
    authors=authors,
    metricId=metricId,
    metricIdVerb=metricIdVerb,
    shortTitle=shortTitle,
    topicTitle=topicTitle,
    topicDesription=topicDesription,
    measuring=measuring,
    reason=reason,
    requirements=requirements,
    procedure=procedure,
    validation=validation,
    relevance=relevance,
    examples=examples,
    comments=comments,
    measuringLabel=measuringLabel,
    reasonLabel=reasonLabel,
    requirementsLabel=requirementsLabel,
    procedureLabel=procedureLabel,
    validationLabel=validationLabel,
    relevanceLabel=relevanceLabel,
    examplesLabel=examplesLabel,
    commentsLabel=commentsLabel,
))
