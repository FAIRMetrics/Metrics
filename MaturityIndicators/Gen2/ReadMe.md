# Generation 2 Maturity Indicators and Tests

These Maturity Indicators describe FAIRness features that can be automatically tested.  Each of these Maturity Indicators has at least one Maturity Indicator Test registered in [The FAIR Evaluator](https://terazus.github.io/FAIR-Maturity-FrontEnd/#!/]).

All tests begin by following a common path which attempts to extract metadata (both key/value-style, and Linked Data-style) through the following steps:

1) an HTTP resolution mechanism is found for the GUID <br/>
 a) Inchi: https://pubchem.ncbi.nlm.nih.gov/rest/rdf/inchikey/{GUID}<br/>
 b) DOI: https://doi.org/{GUID}<br/>
 c) Handle: http://hdl.handle.net/{GUID}<br/>
 d) URL:  URL :-)
 
2) The resulting URL is then called using the following Accept header:<br/>
     text/turtle, application/ld+json, application/rdf+xml, text/xhtml+xml, application/n3, application/rdf+n3, application/turtle, application/x-turtle, text/n3, text/turtle, text/rdf+n3, text/rdf+turtle, application/n-triples
     
3) If there is a valid response, the HTTP Response Headers are scanned for any Link type="meta" headers, and those are pursued by returning to Step 2 and following through to the end.  This goes only one layer deep (i.e. any meta headers in a response from a meta URL are ignored)

4) If there is no response, the URL is called again using Accept: */*, and the process cycles back to Step 3

5) The body of the Response is then examined for raw or embedded metadata.  Currently, we scan for:<br/>
    a) Linked Data (any "flavour", including RDFa)<br/>
    b) opengraph<br/>
    c) microdata<br/>
    d) microformat<br/>
    Where the annotations are embedded in HTML, we use both [Extruct](https://github.com/scrapinghub/extruct) and G. Kellogg's [RDF Distiller](http://rdf.greggkellogg.net/distiller?command=serialize) to extract them from the HTML.  When the response document is a non-textual format (e.g. a PDF), we use [Apache Tika](https://tika.apache.org/) to attempt to extract metadata from the file.
    
6) Linked data is separated from "hash-style" data, and both are passed back to the specific test that is being executed.  Each test will then explore the hash or linked data for whatever properties or features are being tested.
