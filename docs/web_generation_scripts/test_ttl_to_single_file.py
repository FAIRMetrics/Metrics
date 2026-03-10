'''
script to create a single ttl files with all test info.

'''
import os
import markdown
from rdflib import Graph, Namespace, RDF, RDFS, Literal

# Folder containing Turtle files
input_folder = "../test/"
output_file = "test_catalog.ttl"

def escape_properties_value(value: str) -> str:
    if not value:
        return ""

    # Escape backslashes, colons, equals signs, and replace line breaks with \n
    escaped = (
        value.strip()
             .replace("\\", "\\\\")
             .replace(":", "\\:")
             .replace("=", "\\=")
             .replace("\n", "\\n")
    )
    return escaped

# Create a single RDFLib graph to hold all data
merged_graph = Graph()

for root, _, files in os.walk(input_folder):
    for file in files:
        if file.endswith(".ttl"):
            file_path = os.path.join(root, file)
            print(f"Reading: {file_path}")
            try:
                merged_graph.parse(file_path, format="turtle")
            except Exception as e:
                print(f"Failed to parse {file_path}: {e}")


# Serialize the merged graph to a Turtle file
merged_graph.serialize(destination=output_file, format="turtle")

query = """
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX vivo:    <http://vivoweb.org/ontology/core#>

SELECT distinct ?ab ?name ?description
WHERE {
  ?test a <https://w3id.org/ftr#Test> .
  ?test dcterms:title ?name .
  ?test vivo:abbreviation ?ab . 
  ?test dcterms:description ?description 
}
"""

# ---- Extract Test Info ----
results = merged_graph.query(query)

output_properties = "testCatalogue.properties"
with open(output_properties, "w", encoding="utf-8") as f:
    for i, row in enumerate(results, start=1):
        test_id = row.get("ab", Literal("")).value.replace("-T","")
        name = escape_properties_value(row.get("name", Literal("")).value)
        desc = escape_properties_value(markdown.markdown(row.get("description", Literal("")).value))
        f.write(f"{test_id}.name={name}\n")
        f.write(f"{test_id}.description={desc}\n\n")

print(f"\n Properties file saved to: {output_properties}")
