# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.0] - Unreleased

### Added
- `ShowcaseUk::Cinema.all` and `ShowcaseUk::Cinema.new(id)` for Showcase's open UK cinemas, read from the theatre list in the showcasecinemas.co.uk daily build, with addresses, postcodes and `latitude`/`longitude`.
- `ShowcaseUk::Performance.at(id, from:, to:)`, from one schedule request for the whole range plus one request per 50 films, with booking links, variants, languages, festivals and film years from titles.
- Showcase's own variants: `xplus`, `4k`, `hfr`, `infinity_vision`, `directors_hall`, and `arts` for event cinema.
- Built on `cinebase/boxoffice`, the client for Webedia "Movies Pro" websites that Everyman shares.
- Hand-written fixtures, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
