# EverymanUk

A simple gem to pull cinemas and performances from the [Everyman cinemas website](https://www.everymancinema.com) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'everyman_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install everyman_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing members'
preview prefixes, language versions, years and festival prefixes.

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
EverymanUk::Cinema.all
#=> [<EverymanUk::Cinema ...>, <EverymanUk::Cinema ...>, ...]

cinema = EverymanUk::Cinema.new('X0712')
#=> <EverymanUk::Cinema ...>

cinema.adr
#=> {
  street_address:   '96-98 Baker Street',
  extended_address: nil,
  locality:         'London',
  region:           nil,
  postal_code:      'W1U 6TJ',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Everyman'

cinema.full_name
#=> 'Everyman Baker Street'

cinema.id
#=> 'X0712'

cinema.latitude
#=> 51.5205

cinema.longitude
#=> -0.1567

cinema.url
#=> 'https://www.everymancinema.com/theaters/x0712-everyman-baker-street'
```

### Performances

`Performance.at` returns performances for an inclusive range of listings
days, defaulting to today in London and the following 13 days. A listings day
runs from 3am to 3am, as on the website. It makes one schedule request for the
whole range and one request per 50 films.

``` ruby
EverymanUk::Performance.at('X0712', from: Date.today, to: Date.today + 2)
#=> [<EverymanUk::Performance ...>, <EverymanUk::Performance ...>, ...]

performance = EverymanUk::Performance.at('X0712').first
#=> <EverymanUk::Performance ...>

performance.film_name
#=> 'Wicker'

performance.language
#=> nil # e.g. 'Korean' from the showtime's tags or '(Korean)' in the title

performance.film_year
#=> nil # from the title only, e.g. 1993 for 'Hocus Pocus (1993)'

performance.dimension
#=> '2d'

performance.variant
#=> ['senior', 'subtitled']

performance.subtitled?
#=> true

performance.festival
#=> nil # e.g. #<data Cinebase::Festival name="CFF", year=2026>

performance.starting_at
#=> 2026-10-31 14:00:00 UTC

performance.booking_url
#=> 'https://purchase.everymancinema.com/launch/ticketing/1c68e671-f217-5a68-8955-894683b56712'

performance.cinema_name
#=> 'Baker Street'

performance.cinema_id
#=> 'X0712'
```

Film release dates in the API are UK release dates, so re-releases would get
the wrong year. `film_year` only comes from a year in the title.

Variants are `35mm`, `arts`, `audio_described`, `baby`, `kids`, `members`,
`q&a`, `relaxed`, `senior` and `subtitled`.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live everymancinema.com
```

Fixtures in `test/fixtures` are hand-written: invented films and addresses in
the shape of Everyman's responses, never recorded output.
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
