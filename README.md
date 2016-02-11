# At The Movies (server)

[ ![Codeship Status for andycroll/atthemovies](https://codeship.com/projects/3d9227a0-6d2c-0132-aa1f-326df4eb838b/status?branch=master)](https://codeship.com/projects/54193)

# Scheduled tasks

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
