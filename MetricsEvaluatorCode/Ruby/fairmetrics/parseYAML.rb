require 'safe_yaml'
SafeYAML::OPTIONS[:default_mode] = :safe

y = <<'EOF'
swagger: '2.0'
info:
  version: '0.1'
  title: FAIR Metrics -Identifier Uniqueness
  description: >-
    Metric to test if the resource uses a recognized identifier scheme (e.g.
    doi, identifiers.org, etc.).  It consumes a URI as the value of the "spec"
    parameter.  This URI should be a registered identifier schema at
    fairsharing.org.
  contact:
    responsibleOrganization: CBGP UPM/INIA
    url: 'http://faidata.systems'
    responsibleDeveloper: Mark D Wilkinson
    email: markw@illuminae.com
host: fairdata.systems
basePath: /cgi-bin
schemes:
  - http
produces:
  - application/json
consumes:
  - application/json
paths:
  /fair_metrics/Metrics/metric_unique_identifier:
    post:
      parameters:
        - name: spec
          in: body
          description: >-
            The identifier schema specification you claim to follow, referenced
            by its URI (must be registered in FAIRsharing)
          required: true
          parameterType: InputParameter
          schema:
            $ref: '#/definitions/Spec'
      responses:
        '200':
          description: >-
            The response is a binary (1/0) indicating whether the schema you
            claim to follow is registered in the FAIRsharing repository
definitions:
  Spec:
    properties:
      spec:
        type: string
    type: object

EOF

puts y

x = YAML.load(y)

puts x
