# Changelog

All notable changes to the Ruby web generation scripts will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-05-25

### Added
- `ACKNOWLEDGEMENTS_HTML` constant in `TTLConverter`: renders a full-width dark-blue footer with the OSTrails logo, the Horizon Europe "Funded by the EU" emblem, and the required grant acknowledgement text (grant No. 101130187).
- `acknowledgements_html` key injected into every template data hash — both via `build_data` (metric/test/benchmark pages) and the two `result_with_hash` calls in `generate_catalog_and_index` (subfolder and top-level index pages).

### Changed
- All four ERB templates (`template_metric.erb`, `template_test.erb`, `template_benchmark.erb`, `template_index.erb`) now render `<%= acknowledgements_html %>` in place of their previous minimal footers, so every generated HTML page carries the OSTrails/EU branding.

## [1.1.0] - 2026-05-25

### Added
- `template_index.erb`: ERB template for index pages with Bootstrap 3.3.5 styling, breadcrumb navigation, item listing with descriptions, and a back-link for subfolder pages.
- Index generation in `generate_catalog_and_index`: after processing all TTL files, an `index.html` is now written into each subfolder of `landingpages/` (e.g. `general/index.html`, `erdera/index.html`) and a top-level `landingpages/index.html` linking to all subfolders.
- `plain_text_excerpt` helper: strips HTML tags from descriptions and truncates to 200 characters for use in index pages.

### Changed
- `ttl_to_html` now returns the data hash on success (`nil` on error) so index metadata can be collected without re-parsing each TTL file.
- `process_type` now accumulates index entries (name, description excerpt, href) per subfolder into `@index_entries` as HTML files are generated.
- `initialize` now sets up `@index_entries = {}`.

## [1.0.0] - 2025-01-01

### Added
- Initial Ruby port of the TTL-to-HTML/JSON-LD conversion pipeline (`convert_ttl.rb`).
- ERB templates for metrics, tests, and benchmarks.
- SPARQL queries for `ftr:Metric`, `ftr:Test`, and `ftr:Benchmark`.
- Contact point extraction supporting vCard email, name, and ORCID.
