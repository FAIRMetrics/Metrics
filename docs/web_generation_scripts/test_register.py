'''
script to upload test to https://tools.ostrails.eu/fdp-index

'''
import os
import configparser
import time
import argparse
import requests
from rdflib import Graph


QUERY = """
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ftr: <https://w3id.org/ftr#>
PREFIX dcat: <http://www.w3.org/ns/dcat#> 

SELECT DISTINCT ?s ?title ?label ?version ?keywords ?license ?license_label
WHERE {
    ?s a ftr:Test .
    ?s dcterms:title ?title .
    ?s rdfs:label ?label .
    ?s dcat:version ?version .
    ?s dcat:keyword ?keywords .
    ?s dcterms:license ?license .
}
"""


def fetch_github_files(base_url):
    '''
        In construcction. Has been discarted because better features of local methods 
        than working directly with api of github
        iterate repo github with test ttl
    '''
    config = configparser.ConfigParser()
    config.read('config.ini')

    url_register = config.get('Paths', 'path_url_register').strip('"')

    response = requests.get(base_url, timeout=60)

    if response.status_code == 200:

        items = response.json()
        for item in items:

            if item["type"] == "dir":
                print(f"Folder: {item['name']}")
                fetch_github_files(item["url"])
            elif item["type"] == "file" and item["name"].endswith(".ttl"):
                client_url = {"clientUrl": item['download_url']}
                headers = {"Content-Type": "application/json"}

                try:
                    response = requests.post(
                        url_register, json=client_url, headers=headers, timeout=60)
                    # Imprimir detalles
                    print(f"File found: {client_url}")
                    print(f"Response Status Code: {response.status_code}")

                except requests.exceptions.RequestException as e:
                    print(
                        f"Error processing the file {item['download_url']}: {e}")
    else:
        print(f"Error get content: {response.status_code}")


def ttl_to_item_catalogue(path_ttl, pquery):
    '''
        add items to catalogue
    '''
    g = Graph()
    g.parse(path_ttl, format="turtle")
    # Ejecutar la consulta
    results = g.query(pquery)

    data = {}
    keywords = []

    for row in results:

        data = {
            'identifier': row.s,
            'title': row.title,
            'name': row.label,
            'version': row.version,
            'license': row.license
        }
        # transform uri license in label license more readable
        label_license = ""

        if row.license and row.license.strip() != "":
            parts_uri = row.license.strip('/').split('/')
            if "creativecommons" in row.license.lower():
                label_license = ('CC-' + '-'.join(parts_uri[-2:])).upper()
            else:
                label_license = ('-'.join(parts_uri[-2:])).upper()

        data['license_label'] = label_license

        if str(row.keywords) not in keywords:
            keywords.append(str(row.keywords))

    all_keywords = ", ".join(keywords)
    data['keywords'] = all_keywords

    return data


def item_to_list(path, plist, pquery):
    '''
        add items to test array
    '''
    for root, _, files in os.walk(path):
        for file in files:
            if file.endswith(".ttl"):
                # si encontramos el archivo ttl podemos llamar a las funciones de transformacion
                path_ttl = os.path.join(root, file)
                plist.append(ttl_to_item_catalogue(path_ttl, pquery))


def items_to_register(test):
    '''
        iterate test array and register every item in ostrails
    '''
    config = configparser.ConfigParser()
    config.read('config.ini')

    url_register = config.get('Paths', 'path_url_register').strip('"')
    print(f"URL: {url_register}")

    for item in test:

        client_url = {"clientUrl": str(item['identifier'])}
        headers = {"Content-Type": "application/json"}

        # print(client_url)
        try:
            response = requests.post(
                url_register, json=client_url, headers=headers, timeout=60)
            # Imprimir detalles
            print(f"File found: {client_url}")
            print(f"Response Status Code: {response.status_code}")
            # print(f"Response Body: {response.text}\n")
            if response.status_code == 200:
                print(f"Test: {str(item['identifier'])} registered OK")
            else:
                print(
                    f"Error registering {str(item['identifier'])}: {response.reason}")

            time.sleep(1)

        except requests.exceptions.RequestException as e:
            print(
                f"Error processing the file {str(item['identifier'])}: {e}")


def main():
    ''' 
        init register process
    '''

    parser = argparse.ArgumentParser(description="Script managed files .ttl")
    parser.add_argument(
        '-i', help="Source folder where the TTL files for the tests are located. Use to be ../doc/test/", required=True)

    args = parser.parse_args()
    path_source = args.i

    tests = []

    print("----- START of the process ------")
    item_to_list(path_source, tests, QUERY)
    items_to_register(tests)
    # fetch_github_files(github_api_url)

    print("----- END of the process ------")


if __name__ == "__main__":
    main()
