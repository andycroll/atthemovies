# ShowcaseUk

A simple gem to pull cinemas and performances from the [Showcase Cinemas UK website](https://www.showcasecinemas.co.uk) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'showcase_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install showcase_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing anniversary
and restoration markers, "Sensory Friendly Screening" suffixes, language
versions, years and festival prefixes.

No token or setup is needed. The website runs on Webedia's "Movies Pro"
platform and sells tickets through Boxoffice. Listings come from the
website's own `/api/gatsby-source-boxofficeapi/` routes. The theatre list
is in the website's static build, whose path changes every day, so the gem
finds the current build from the home page first. The client and most of
the cinema and performance logic live in cinebase's `Cinebase::Boxoffice`,
shared with other chains on the same platform.

### Cinema

Only open UK cinemas are returned. The theatre list is cached for an hour.

``` ruby
ShowcaseUk::Cinema.all
#=> [<ShowcaseUk::Cinema ...>, <ShowcaseUk::Cinema ...>, ...]

cinema = ShowcaseUk::Cinema.new('X06JR')
#=> <ShowcaseUk::Cinema ...>

cinema.adr
#=> {
  street_address:   'Bluewater Plaza',
  extended_address: nil,
  locality:         'Greenhithe',
  region:           nil,
  postal_code:      'DA9 9SG',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Showcase'

cinema.full_name
#=> 'Showcase Bluewater'

cinema.id
#=> 'X06JR'

cinema.latitude
#=> 51.4371

cinema.longitude
#=> 0.2705

cinema.url
#=> 'https://www.showcasecinemas.co.uk/theaters/x06jr-showcase-cinema-de-lux-bluewater'
```

### Performances

`Performance.at` returns performances for an inclusive range of listings
days, defaulting to today in London and the following 13 days. A listings day
runs from 3am to 3am, as on the website. It makes one schedule request for the
whole range and one request per 50 films, so a year ahead costs the same as a
day.

``` ruby
ShowcaseUk::Performance.at('X06JR', from: Date.today, to: Date.today + 365)
#=> [<ShowcaseUk::Performance ...>, <ShowcaseUk::Performance ...>, ...]

performance = ShowcaseUk::Performance.at('X06JR').first
#=> <ShowcaseUk::Performance ...>

performance.film_name
#=> 'Hocus Pocus'

performance.language
#=> nil # e.g. 'Hindi' from the showtime's tags or '(Hindi)' in the title

performance.film_year
#=> nil # from the title only

performance.dimension
#=> '2d'

performance.variant
#=> ['subtitled', 'xplus']

performance.subtitled?
#=> true

performance.festival
#=> nil

performance.starting_at
#=> 2026-10-31 11:10:00 UTC

performance.booking_url
#=> 'https://tickets.showcasecinemas.co.uk/launch/ticketing/a1fe9520-bfb1-5b51-a278-58286ca0978a'

performance.cinema_name
#=> 'Bluewater'

performance.cinema_id
#=> 'X06JR'
```

Film release dates in the API are UK release dates, so re-releases would get
the wrong year. `film_year` only comes from a year in the title.

The booking URL is Showcase's own ticketing page. The website also lists a
`relay` provider for each showtime, used only when the Showcase link is
missing.

Variants are `35mm`, `4k`, `arts` (event cinema, live and encore
broadcasts), `audio_described`, `baby`, `directors_hall`, `hfr`,
`infinity_vision`, `kids`, `members`, `q&a`, `relaxed`, `senior`,
`subtitled` and `xplus`.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live showcasecinemas.co.uk
```

Fixtures in `test/fixtures` are hand-written: invented films and addresses in
the shape of Showcase's responses, never recorded output.
`test/support/api_shapes.rb` describes the fields the gem reads. The unit
suite checks the fixtures against it and the live suite checks real
responses, held only in memory. When the API changes, update the shape first,
then the fixtures.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
