# At The Movies

[![CI Status](https://travis-ci.org/andycroll/atthemovies.svg?branch=master)](https://travis-ci.org/andycroll/atthemovies)
[![Code Climate](https://codeclimate.com/github/andycroll/atthemovies/badges/gpa.svg)](https://codeclimate.com/github/andycroll/atthemovies)
[![Test Coverage](https://codeclimate.com/github/andycroll/atthemovies/badges/coverage.svg)](https://codeclimate.com/github/andycroll/atthemovies/coverage)
[![Dependency Status](https://dependencyci.com/github/andycroll/atthemovies/badge)](https://dependencyci.com/github/andycroll/atthemovies)

A Rails app that pulls cinema times from UK cinema chains, normalizes and then provides a sensible API.

## License

This app is open source, but not free for private commercial use.

For non-commercial use the license is A-GPL (broadly meaning you have to in turn open source your code that uses this app).

Commercial licensing under MIT can be arranged by contacting [andy@goodscary.com](mailto:andy@goodscary.com).


# Setup

Using postgres for main datastore and a little memcache for caching some external calls in views.

Relies on DelayedJob for asynchronous work (avoiding Redis dependency for now).


# Rake tasks

## Nightly

### Import cinemas

```
import:cinemas:cineworld
import:cinemas:odeon
import:cinemas:picturehouse
```

### Import Performances

```
import:performances:cineworld
import:performances:odeon
import:performances:picturehouse
```

### Get Potential Film Ids

```
import:films:external_ids
```

### Hydrate Films with Single external_id

```
import:films:external_information
```

## Every 10 minutes

```
cleanup:past_performances
```
