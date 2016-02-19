# At The Movies

[ ![Codeship Status for andycroll/atthemovies](https://codeship.com/projects/3d9227a0-6d2c-0132-aa1f-326df4eb838b/status?branch=master)](https://codeship.com/projects/54193)

A Rails app that pulls cinema times from UK cinema chains, normalizes and then provides a sensible API.


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
