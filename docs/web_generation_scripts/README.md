# foops_documentation_scripts

Repository used to generate the JSON-LD and HTML catalogs for FOOPS!

First, the following repository must be downloaded to work on the different documents. Then, configure the config.ini file with the paths where all the material has been downloaded. This way, we avoid working directly with the GitHub API, which is more cumbersome and would require permissions and credentials to launch the registration process.

https://github.com/oeg-upm/fair_ontologies

The process begins from the terminal, specifying the path where the test.ttl files are located, which are essential to start the process, as well as a destination path where the folder and file structure will be saved. Both parameters are mandatory.
This process create a catalog of all the documents.

The folder structure is usually as follows:

doc
catalog.html

    - test
        test1
            test1.ttl
            test1.html
            test1.jsonld
        test2
        .....
    - metric
        metric1

        metric2
        ....
    - benchmark

Execution:
python ttl_transformations.py -i "/path/source/" -o "/path_destination/"

    -i: input (source path). Must be contain the doc folder with the test/test1/test1.ttl
    -o: output (destination path)

The process iterates recursively within the root, and if it finds a TTL file, it creates an equivalent file with the same name but with HTML and JSON-LD extensions.

The Mustache template is necessary to create the HTML file, and if any design modifications to the HTML are deemed necessary, they should be made in that template.

The script requires the rdflib and pystache libraries for proper operation. Both are included in the Bin folder.

The main page created from ttl_catalogue.py goes through all test folders and retrieves information to create a catalog item whenever it finds a ttl file in the folder.

By using Markdown within the TTL file, we can customize the formatting of descriptions for all document types (tests, metrics, and benchmarks), resulting in a more user-friendly HTML presentation.

After generating the documents and creating the catalog with them, it is possible to register them on Ostrails (https://tools.ostrails.eu) using the following script. The only requirement is to specify the folder where the test.ttl files created in the previous process are located. This is typically located at path/doc/test/.

Execution:
python test_register.py -i "/path/doc/test"

It is necessary to configure the registration web service, which is currently:

```
path_url_register = "https://tools.ostrails.eu/fdp-index-proxy/proxy"
```

The script will register all the TTL files located in the configured path. If the test already exists in the registry, it will be modified.

### Generating a full ttl catalog and a .properties file for java descriptions
The script `test_ttl_to_single_file.py` transforms all the tests into a single turtel format (in case you want to query tests).
It also generates a `.properties` file for the main FOOPS! Java program to read test descriptions. If any description is updated, this script should be run.
