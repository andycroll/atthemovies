# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.0] - Unreleased

### Added
- `EverymanUk::Cinema.all` and `EverymanUk::Cinema.new(id)` for Everyman's open UK cinemas, read from the theatre list in the everymancinema.com daily build, with addresses, postcodes and `latitude`/`longitude`.
- `EverymanUk::Performance.at(id, from:, to:)`, from one schedule request for the whole range plus one request per 50 films, with booking links, variants, languages, festivals and film years from titles, following cinebase 5.5.
- A Boxoffice client for Webedia "Movies Pro" websites that takes the website as a parameter, ready to share with other chains on the same platform.
- Hand-written fixtures, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
