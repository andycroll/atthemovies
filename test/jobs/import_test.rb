require "test_helper"
require "minitest/mock"

class ImportTest < ActiveJob::TestCase
  test "Cineworld imports preserve edits and map future gem performances without duplicates" do
    venue = CineworldUk::Cinema.new(14)
    venue.define_singleton_method(:name) { "Brighton" }
    venue.define_singleton_method(:adr) { { street_address: "Marina", locality: "Brighton", postal_code: "BN2 5UF" } }
    venue.define_singleton_method(:latitude) { nil }
    venue.define_singleton_method(:longitude) { nil }
    starting_at = 2.days.from_now.change(usec: 0)
    distant_start = 210.days.from_now.change(usec: 0)
    dates = [ distant_start.to_date, starting_at.to_date, Time.zone.today ]
    performances = [
      CineworldUk::Performance.new(cinema_id: 14, cinema_name: "Brighton", film_name: "New Cineworld Release", film_year: 2026, starting_at: starting_at,
        dimension: "3d", variant: [ "imax", "audio_described" ], booking_url: "https://web.cineworld.co.uk/order/showtimes/014-123/seats"),
      CineworldUk::Performance.new(cinema_id: 14, cinema_name: "Brighton", film_name: "New Cineworld Release", starting_at: distant_start,
        dimension: "2d", variant: [], booking_url: "https://web.cineworld.co.uk/order/showtimes/014-456/seats"),
      CineworldUk::Performance.new(cinema_id: 14, cinema_name: "Brighton", film_name: "Elapsed Film", starting_at: 1.minute.ago, dimension: "2d", variant: [])
    ]
    client = Object.new
    client.define_singleton_method(:get) do |path, query|
      raise "Wrong site filter" unless path == "film-screening-dates" && query == { "siteIds" => "014" }
      { "filmScreeningDates" => dates.map { |date| { "businessDate" => date.iso8601 } } }
    end
    fetch = ->(id, from:, to:) do
      assert_equal "14", id
      assert_equal from, to
      performances.select { |performance| performance.starting_at.to_date == from }
    end
    Cinebase::Vista::Client.stub(:new, client) do
      CineworldUk.stub(:ensure_token!, nil) do
        CineworldUk::Cinema.stub(:all, [ venue ]) do
          CineworldUk::Performance.stub(:at, fetch) do
            perform_enqueued_jobs do
              assert_difference({ "Cinema.count" => 1, "Film.count" => 1, "Performance.count" => 2 }) do
                ImportChainJob.perform_now("cineworld")
              end
              cinema = ExternalIdentifier.find_by!(source: "cineworld_venue", value: "14").identifiable
              assert_equal "BN2 5UF", cinema.postal_code
              assert_equal "https://www.cineworld.co.uk/cinemas/14/information", cinema.screenings_url
              cinema.update!(name: "Edited venue", street_address: "Edited address")
              assert_no_difference [ "Cinema.count", "Film.count", "Performance.count" ] do
                ImportChainJob.perform_now("cineworld")
              end
              assert_equal "Edited venue", cinema.reload.name
              assert_equal "Edited address", cinema.street_address
              performance = cinema.performances.find_by!(starting_at: starting_at)
              assert_equal starting_at, performance.starting_at
              assert_equal "3d", performance.dimension
              assert_equal "audio_described, imax", performance.variant
              assert_equal performances.first.booking_url, performance.booking_url
              assert_equal 2026, performance.film.year
              distant = cinema.performances.find_by!(starting_at: distant_start)
              assert_equal "standard", distant.variant
              assert_equal "2d", distant.dimension
              assert_equal performances[1].booking_url, distant.booking_url
            end
          end
        end
      end
    end
  end

  test "repeat imports update variant without duplicating titles or performances" do
    cinema = cinemas(:brighton)
    attributes = { name: "New Release", starting_at: 1.day.from_now, dimension: "2D", variant: "standard" }
    job = ImportChainPerformancesJob.new
    assert_difference [ "Film.count", "Performance.count" ], 1 do
      2.times { job.import!(cinema, attributes) }
    end
    job.import!(cinema, attributes.merge(variant: "SUBTITLED"))
    performance = cinema.performances.last
    assert_equal "subtitled", performance.variant
    assert_equal 1, performance.film.reload.performances_count
    job.import!(cinema, attributes.merge(dimension: "3D"))
    assert_equal 2, performance.film.reload.performances_count
  end

  test "imports record the film year from the cinema" do
    ImportChainPerformancesJob.new.import!(cinemas(:brighton), name: "From Dusk Till Dawn", year: 1996,
      starting_at: 1.day.from_now, dimension: "2d", variant: "standard")
    assert_equal 1996, Film.find_by!(name: "From Dusk Till Dawn").year
  end

  test "Vue imports every advertised date in one request" do
    venue = VueUk::Cinema.new(10051)
    venue.define_singleton_method(:name) { "Accrington" }
    venue.define_singleton_method(:adr) { { street_address: "The Viaduct", locality: "Accrington", postal_code: "BB5 1QF" } }
    venue.define_singleton_method(:latitude) { nil }
    venue.define_singleton_method(:longitude) { nil }
    venue.define_singleton_method(:url) { "https://www.myvue.com/cinema/accrington" }
    starting_at = 300.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "10051", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ VueUk::Performance.new(cinema_id: id, cinema_name: "Accrington", film_name: "Vue Release", starting_at: starting_at, variant: [ "subtitled" ]) ]
    end
    VueUk::Cinema.stub(:all, [ venue ]) do
      VueUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("vue") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "vue_venue", value: "10051").identifiable
    assert_equal [ "Vue", "BB5 1QF" ], [ cinema.brand, cinema.postal_code ]
    assert_equal "subtitled", cinema.performances.find_by!(starting_at: starting_at).variant
  end

  test "chain coordinates fill cinemas without them and keep operator edits" do
    venue = PicturehouseUk::Cinema.new(19)
    venue.define_singleton_method(:name) { "Duke's at Komedia" }
    venue.define_singleton_method(:adr) { { locality: "Brighton" } }
    venue.define_singleton_method(:url) { "https://www.picturehouses.com/cinema/duke-s-at-komedia" }
    coordinates = nil
    venue.define_singleton_method(:latitude) { coordinates&.first }
    venue.define_singleton_method(:longitude) { coordinates&.last }
    PicturehouseUk.stub(:ensure_token!, nil) do
      PicturehouseUk::Cinema.stub(:all, [ venue ]) do
        ImportChainJob.perform_now("picturehouse")
        cinema = ExternalIdentifier.find_by!(source: "picturehouse_venue", value: "019").identifiable
        assert_nil cinema.latitude
        coordinates = [ 50.8248, -0.1394 ]
        ImportChainJob.perform_now("picturehouse")
        assert_equal [ 50.8248, -0.1394 ], [ cinema.reload.latitude, cinema.longitude ].map(&:to_f)
        cinema.update!(latitude: 50.8, longitude: -0.1)
        ImportChainJob.perform_now("picturehouse")
        assert_equal [ 50.8, -0.1 ], [ cinema.reload.latitude, cinema.longitude ].map(&:to_f)
      end
    end
  end

  test "Everyman imports every advertised date in one request" do
    venue = EverymanUk::Cinema.new("X0712")
    venue.define_singleton_method(:name) { "Baker Street" }
    venue.define_singleton_method(:adr) { { street_address: "96-98 Baker Street", locality: "London", postal_code: "W1U 6TJ" } }
    venue.define_singleton_method(:url) { "https://www.everymancinema.com/theaters/x0712-everyman-baker-street" }
    venue.define_singleton_method(:latitude) { 51.5205 }
    venue.define_singleton_method(:longitude) { -0.1567 }
    starting_at = 45.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "X0712", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ EverymanUk::Performance.new(cinema_id: id, cinema_name: "Baker Street", film_name: "Hocus Pocus", film_year: 1993,
        starting_at: starting_at, variant: [ "35mm", "senior" ], booking_url: "https://purchase.everymancinema.com/launch/ticketing/abc") ]
    end
    EverymanUk::Cinema.stub(:all, [ venue ]) do
      EverymanUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("everyman") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "everyman_venue", value: "X0712").identifiable
    assert_equal [ "Everyman", "W1U 6TJ" ], [ cinema.brand, cinema.postal_code ]
    assert_equal [ 51.5205, -0.1567 ], [ cinema.latitude, cinema.longitude ].map(&:to_f)
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "35mm, senior", 1993 ], [ performance.variant, performance.film.year ]
    assert_equal "https://purchase.everymancinema.com/launch/ticketing/abc", performance.booking_url
  end

  test "Showcase imports every advertised date in one request" do
    venue = ShowcaseUk::Cinema.new("X06JR")
    venue.define_singleton_method(:name) { "Bluewater" }
    venue.define_singleton_method(:adr) { { street_address: "Bluewater Plaza", locality: "Greenhithe", postal_code: "DA9 9SG" } }
    venue.define_singleton_method(:url) { "https://www.showcasecinemas.co.uk/theaters/x06jr-showcase-cinema-de-lux-bluewater" }
    venue.define_singleton_method(:latitude) { 51.4371 }
    venue.define_singleton_method(:longitude) { 0.2705 }
    starting_at = 200.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "X06JR", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ ShowcaseUk::Performance.new(cinema_id: id, cinema_name: "Bluewater", film_name: "Dune: Part Three", dimension: "3d",
        starting_at: starting_at, variant: [ "xplus", "subtitled" ], booking_url: "https://tickets.showcasecinemas.co.uk/launch/ticketing/abc") ]
    end
    ShowcaseUk::Cinema.stub(:all, [ venue ]) do
      ShowcaseUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("showcase") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "showcase_venue", value: "X06JR").identifiable
    assert_equal [ "Showcase", "DA9 9SG" ], [ cinema.brand, cinema.postal_code ]
    assert_equal [ 51.4371, 0.2705 ], [ cinema.latitude, cinema.longitude ].map(&:to_f)
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "subtitled, xplus", "3d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://tickets.showcasecinemas.co.uk/launch/ticketing/abc", performance.booking_url
  end

  test "Spektrix imports independent cinemas as Independent" do
    venue = SpektrixUk::Cinema.new("tyneside")
    venue.define_singleton_method(:name) { "Tyneside Cinema" }
    venue.define_singleton_method(:adr) { { street_address: "10 Pilgrim Street", locality: "Newcastle upon Tyne", postal_code: "NE1 6QG" } }
    venue.define_singleton_method(:url) { "https://tynesidecinema.co.uk" }
    venue.define_singleton_method(:latitude) { 54.9724 }
    venue.define_singleton_method(:longitude) { -1.6111 }
    starting_at = 150.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "tyneside", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ SpektrixUk::Performance.new(cinema_id: id, cinema_name: "Tyneside Cinema", film_name: "Nosferatu", film_year: 1922,
        starting_at: starting_at, variant: [ "35mm", "q&a" ], booking_url: "https://tynesidecinema.co.uk/book-online/123") ]
    end
    SpektrixUk::Cinema.stub(:all, [ venue ]) do
      SpektrixUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("spektrix") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "spektrix_venue", value: "tyneside").identifiable
    assert_equal [ "Independent", "Tyneside Cinema", "NE1 6QG" ], [ cinema.brand, cinema.name, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "35mm, q&a", 1922 ], [ performance.variant, performance.film.year ]
    assert_equal "https://tynesidecinema.co.uk/book-online/123", performance.booking_url
  end

  test "Arc imports every advertised date from the whatson page" do
    venue = ArcUk::Cinema.new("ARC_BEE")
    venue.define_singleton_method(:name) { "Beeston" }
    venue.define_singleton_method(:adr) { { street_address: "Styles Way", locality: "Beeston", postal_code: "NG9 2WJ" } }
    venue.define_singleton_method(:url) { "https://beeston.arccinema.co.uk" }
    venue.define_singleton_method(:latitude) { 52.9256 }
    venue.define_singleton_method(:longitude) { -1.2163 }
    starting_at = 170.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "ARC_BEE", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ ArcUk::Performance.new(cinema_id: id, cinema_name: "Beeston", film_name: "Swan Lake",
        starting_at: starting_at, variant: [ "arts" ], booking_url: "https://beeston.admit-one.co.uk/tickets/?perfCode=123") ]
    end
    ArcUk::Cinema.stub(:all, [ venue ]) do
      ArcUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("arc") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "arc_venue", value: "ARC_BEE").identifiable
    assert_equal [ "Arc", "NG9 2WJ" ], [ cinema.brand, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "arts", "2d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://beeston.admit-one.co.uk/tickets/?perfCode=123", performance.booking_url
  end

  test "Movie House imports every advertised date from the whatson page" do
    venue = MoviehouseUk::Cinema.new("MH_COLE")
    venue.define_singleton_method(:name) { "Coleraine" }
    venue.define_singleton_method(:adr) { { street_address: "1 Riverside Park South", locality: "Coleraine", postal_code: "BT51 3RT" } }
    venue.define_singleton_method(:url) { "https://www.moviehouse.co.uk/coleraine" }
    venue.define_singleton_method(:latitude) { 55.1199 }
    venue.define_singleton_method(:longitude) { -6.6781 }
    starting_at = 20.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "MH_COLE", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ MoviehouseUk::Performance.new(cinema_id: id, cinema_name: "Coleraine", film_name: "National Theatre Live: Hamlet",
        starting_at: starting_at, variant: [ "arts" ], booking_url: "https://moviehousecoleraine.admit-one.co.uk/tickets/?perfCode=123") ]
    end
    MoviehouseUk::Cinema.stub(:all, [ venue ]) do
      MoviehouseUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("moviehouse") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "moviehouse_venue", value: "MH_COLE").identifiable
    assert_equal [ "Movie House", "BT51 3RT" ], [ cinema.brand, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "arts", "2d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://moviehousecoleraine.admit-one.co.uk/tickets/?perfCode=123", performance.booking_url
  end

  test "Omniplex imports every advertised date" do
    venue = OmniplexUk::Cinema.new("OMP_SUND")
    venue.define_singleton_method(:name) { "Sunderland" }
    venue.define_singleton_method(:adr) { { street_address: "4 Lambton Street", locality: "Sunderland", postal_code: "SR1 1TP" } }
    venue.define_singleton_method(:url) { "https://www.omniplexcinemas.co.uk/cinema/showtimes?sitecode=OMP_SUND" }
    venue.define_singleton_method(:latitude) { 54.9082 }
    venue.define_singleton_method(:longitude) { -1.3800 }
    starting_at = 180.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "OMP_SUND", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ OmniplexUk::Performance.new(cinema_id: id, cinema_name: "Sunderland", film_name: "Avatar: Fire and Ash", dimension: "3d",
        starting_at: starting_at, variant: [ "maxx" ], booking_url: "https://www.omniplexcinemas.co.uk/booking/seats/sunderland/123") ]
    end
    OmniplexUk::Cinema.stub(:all, [ venue ]) do
      OmniplexUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("omniplex") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "omniplex_venue", value: "OMP_SUND").identifiable
    assert_equal [ "Omniplex", "SR1 1TP" ], [ cinema.brand, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "maxx", "3d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://www.omniplexcinemas.co.uk/booking/seats/sunderland/123", performance.booking_url
  end

  test "Reel imports cinemas from both of its websites" do
    venues = { "blackburn" => [ "BB2 1AS", "https://reel-cinemas.co.uk/blackburn/booknow/123/" ],
      "hull" => [ "HU2 8LN", "https://reelhull.admit-one.co.uk/tickets/?perfCode=456" ] }
    stubs = venues.map do |id, (postal_code, _)|
      venue = ReelUk::Cinema.new(id)
      venue.define_singleton_method(:name) { id.capitalize }
      venue.define_singleton_method(:adr) { { locality: id.capitalize, postal_code: postal_code } }
      venue.define_singleton_method(:url) { "https://reel-cinemas.co.uk/#{id}" }
      venue.define_singleton_method(:latitude) { 53.7 }
      venue.define_singleton_method(:longitude) { -1.5 }
      venue
    end
    starting_at = 30.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ ReelUk::Performance.new(cinema_id: id, cinema_name: id.capitalize, film_name: "Wicked: For Good",
        starting_at: starting_at, variant: [ "senior" ], booking_url: venues.fetch(id).last) ]
    end
    ReelUk::Cinema.stub(:all, stubs) do
      ReelUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("reel") }
      end
    end
    venues.each do |id, (postal_code, booking_url)|
      cinema = ExternalIdentifier.find_by!(source: "reel_venue", value: id).identifiable
      assert_equal [ "Reel", postal_code ], [ cinema.brand, cinema.postal_code ]
      performance = cinema.performances.find_by!(starting_at: starting_at)
      assert_equal [ "senior", booking_url ], [ performance.variant, performance.booking_url ]
    end
  end

  test "Scott imports every advertised date from its feed" do
    venue = ScottUk::Cinema.new("SCOEXM")
    venue.define_singleton_method(:name) { "Exmouth" }
    venue.define_singleton_method(:adr) { { street_address: "Strand Gardens", locality: "Exmouth", postal_code: "EX8 1HP" } }
    venue.define_singleton_method(:url) { "https://exmouth.scottcinemas.co.uk" }
    venue.define_singleton_method(:latitude) { 50.6198 }
    venue.define_singleton_method(:longitude) { -3.4133 }
    starting_at = 90.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "SCOEXM", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ ScottUk::Performance.new(cinema_id: id, cinema_name: "Exmouth", film_name: "Swan Lake",
        starting_at: starting_at, variant: [ "arts" ], booking_url: "https://exmouth.scottcinemas.co.uk/book-now/swan-lake/123") ]
    end
    ScottUk::Cinema.stub(:all, [ venue ]) do
      ScottUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("scott") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "scott_venue", value: "SCOEXM").identifiable
    assert_equal [ "Scott Cinemas", "EX8 1HP" ], [ cinema.brand, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "arts", "2d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://exmouth.scottcinemas.co.uk/book-now/swan-lake/123", performance.booking_url
  end

  test "Prince Charles Cinema imports as an independent" do
    venue = PrincecharlesUk::Cinema.new("PRILON")
    venue.define_singleton_method(:name) { "Prince Charles Cinema" }
    venue.define_singleton_method(:adr) { { street_address: "7 Leicester Place", locality: "London", postal_code: "WC2H 7BY" } }
    venue.define_singleton_method(:url) { "https://princecharlescinema.com" }
    venue.define_singleton_method(:latitude) { 51.5115 }
    venue.define_singleton_method(:longitude) { -0.1302 }
    starting_at = 200.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "PRILON", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ PrincecharlesUk::Performance.new(cinema_id: id, cinema_name: "Prince Charles Cinema", film_name: "The Sound of Music", film_year: 1965,
        starting_at: starting_at, variant: [ "sing_along", "70mm" ], booking_url: "https://princecharlescinema.com/prince-charles-cinema/booknow/123/") ]
    end
    PrincecharlesUk::Cinema.stub(:all, [ venue ]) do
      PrincecharlesUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("princecharles") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "princecharles_venue", value: "PRILON").identifiable
    assert_equal [ "Independent", "Prince Charles Cinema", "WC2H 7BY" ], [ cinema.brand, cinema.name, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "70mm, sing_along", 1965 ], [ performance.variant, performance.film.year ]
    assert_equal "https://princecharlescinema.com/prince-charles-cinema/booknow/123/", performance.booking_url
  end

  test "Depot imports as an independent" do
    venue = DepotUk::Cinema.new("deplew")
    venue.define_singleton_method(:name) { "Depot" }
    venue.define_singleton_method(:adr) { { street_address: "Pinwell Road", locality: "Lewes", postal_code: "BN7 2JS" } }
    venue.define_singleton_method(:url) { "https://lewesdepot.org" }
    venue.define_singleton_method(:latitude) { 50.8715 }
    venue.define_singleton_method(:longitude) { 0.0120 }
    starting_at = 60.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "deplew", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ DepotUk::Performance.new(cinema_id: id, cinema_name: "Depot", film_name: "Fjord",
        starting_at: starting_at, variant: [ "relaxed" ], booking_url: "https://lewesdepot.org/film/fjord/booknow/123") ]
    end
    DepotUk::Cinema.stub(:all, [ venue ]) do
      DepotUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("depot") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "depot_venue", value: "deplew").identifiable
    assert_equal [ "Independent", "Depot", "BN7 2JS" ], [ cinema.brand, cinema.name, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "relaxed", "2d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://lewesdepot.org/film/fjord/booknow/123", performance.booking_url
  end

  test "Merlin imports films from each cinema's home page" do
    venue = MerlinUk::Cinema.new("MER_FALM")
    venue.define_singleton_method(:name) { "Phoenix Cinema, Falmouth" }
    venue.define_singleton_method(:adr) { { street_address: "11 Berkeley Vale", locality: "Falmouth", postal_code: "TR11 3PL" } }
    venue.define_singleton_method(:url) { "https://falmouth.merlincinemas.co.uk" }
    venue.define_singleton_method(:latitude) { 50.1541 }
    venue.define_singleton_method(:longitude) { -5.0743 }
    starting_at = 45.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "MER_FALM", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ MerlinUk::Performance.new(cinema_id: id, cinema_name: "Phoenix Cinema, Falmouth", film_name: "Bugonia",
        starting_at: starting_at, variant: [ "subtitled" ], booking_url: "https://merlinfalmouth.admit-one.eu/?p=tickets&perfCode=123") ]
    end
    MerlinUk::Cinema.stub(:all, [ venue ]) do
      MerlinUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("merlin") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "merlin_venue", value: "MER_FALM").identifiable
    assert_equal [ "Merlin", "TR11 3PL" ], [ cinema.brand, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "subtitled", "2d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://merlinfalmouth.admit-one.eu/?p=tickets&perfCode=123", performance.booking_url
  end

  test "Watershed imports as an independent" do
    venue = WatershedUk::Cinema.new("watershed")
    venue.define_singleton_method(:name) { "Watershed" }
    venue.define_singleton_method(:adr) { { street_address: "1 Canons Road", locality: "Bristol", postal_code: "BS1 5TX" } }
    venue.define_singleton_method(:url) { "https://www.watershed.co.uk" }
    venue.define_singleton_method(:latitude) { 51.4518 }
    venue.define_singleton_method(:longitude) { -2.5981 }
    starting_at = 90.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "watershed", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ WatershedUk::Performance.new(cinema_id: id, cinema_name: "Watershed", film_name: "Hamnet",
        starting_at: starting_at, variant: [ "subtitled" ], booking_url: "https://watershed.ticketsolve.com/shows/1/events/2") ]
    end
    WatershedUk::Cinema.stub(:all, [ venue ]) do
      WatershedUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("watershed") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "watershed_venue", value: "watershed").identifiable
    assert_equal [ "Independent", "Watershed", "BS1 5TX" ], [ cinema.brand, cinema.name, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "subtitled", "2d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://watershed.ticketsolve.com/shows/1/events/2", performance.booking_url
  end

  test "Glasgow Film Theatre imports as an independent" do
    venue = GftUk::Cinema.new("103")
    venue.define_singleton_method(:name) { "Glasgow Film Theatre" }
    venue.define_singleton_method(:adr) { { street_address: "12 Rose Street", locality: "Glasgow", postal_code: "G3 6RB" } }
    venue.define_singleton_method(:url) { "https://www.glasgowfilm.org" }
    venue.define_singleton_method(:latitude) { 55.8657 }
    venue.define_singleton_method(:longitude) { -4.2613 }
    starting_at = 75.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "103", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ GftUk::Performance.new(cinema_id: id, cinema_name: "Glasgow Film Theatre", film_name: "Sentimental Value",
        starting_at: starting_at, variant: [ "subtitled" ], booking_url: "https://www.glasgowfilm.org/checkout/showing/sentimental-value/123/") ]
    end
    GftUk::Cinema.stub(:all, [ venue ]) do
      GftUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("gft") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "gft_venue", value: "103").identifiable
    assert_equal [ "Independent", "Glasgow Film Theatre", "G3 6RB" ], [ cinema.brand, cinema.name, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "subtitled", "2d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://www.glasgowfilm.org/checkout/showing/sentimental-value/123/", performance.booking_url
  end

  test "Rio imports as an independent" do
    venue = RioUk::Cinema.new("rio")
    venue.define_singleton_method(:name) { "Rio Cinema" }
    venue.define_singleton_method(:adr) { { street_address: "107 Kingsland High Street", locality: "London", postal_code: "E8 2PB" } }
    venue.define_singleton_method(:url) { "https://riocinema.org.uk" }
    venue.define_singleton_method(:latitude) { 51.5496 }
    venue.define_singleton_method(:longitude) { -0.0756 }
    starting_at = 30.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "rio", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ RioUk::Performance.new(cinema_id: id, cinema_name: "Rio Cinema", film_name: "Marty Supreme",
        starting_at: starting_at, variant: [ "relaxed" ], booking_url: "https://riocinema.org.uk/Rio.dll/Booking?Booking=TSelectItems.waSelectItemsPrompt.TcsPerformance_123") ]
    end
    RioUk::Cinema.stub(:all, [ venue ]) do
      RioUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("rio") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "rio_venue", value: "rio").identifiable
    assert_equal [ "Independent", "Rio Cinema", "E8 2PB" ], [ cinema.brand, cinema.name, cinema.postal_code ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "relaxed", "2d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://riocinema.org.uk/Rio.dll/Booking?Booking=TSelectItems.waSelectItemsPrompt.TcsPerformance_123", performance.booking_url
  end

  test "Light imports every advertised date without coordinates" do
    venue = LightUk::Cinema.new("7")
    venue.define_singleton_method(:name) { "Sheffield" }
    venue.define_singleton_method(:adr) { { street_address: "The Moor", locality: "Sheffield", postal_code: "S1 4PF" } }
    venue.define_singleton_method(:url) { "https://sheffield.thelight.co.uk" }
    venue.define_singleton_method(:latitude) { nil }
    venue.define_singleton_method(:longitude) { nil }
    starting_at = 100.days.from_now.change(usec: 0)
    fetch = ->(id, from:, to:) do
      assert_equal "7", id
      assert_equal [ Time.zone.today, Time.zone.today + 1.year ], [ from, to ]
      [ LightUk::Performance.new(cinema_id: id, cinema_name: "Sheffield", film_name: "Wicked: For Good",
        starting_at: starting_at, variant: [ "relaxed" ], booking_url: "https://sheffield.thelight.co.uk/#!book/cinema/123") ]
    end
    LightUk::Cinema.stub(:all, [ venue ]) do
      LightUk::Performance.stub(:at, fetch) do
        perform_enqueued_jobs { ImportChainJob.perform_now("light") }
      end
    end
    cinema = ExternalIdentifier.find_by!(source: "light_venue", value: "7").identifiable
    assert_equal [ "Light", "S1 4PF", nil ], [ cinema.brand, cinema.postal_code, cinema.latitude ]
    performance = cinema.performances.find_by!(starting_at: starting_at)
    assert_equal [ "relaxed", "2d" ], [ performance.variant, performance.dimension ]
    assert_equal "https://sheffield.thelight.co.uk/#!book/cinema/123", performance.booking_url
  end

  test "cinema provider identity survives operator renames and repeated imports" do
    venue = PicturehouseUk::Cinema.new(19)
    venue.define_singleton_method(:name) { "Duke's at Komedia" }
    venue.define_singleton_method(:adr) { { locality: "Brighton" } }
    venue.define_singleton_method(:latitude) { nil }
    venue.define_singleton_method(:longitude) { nil }
    venue.define_singleton_method(:url) { "https://www.picturehouses.com/cinema/duke-s-at-komedia" }
    PicturehouseUk.stub(:ensure_token!, nil) do
      PicturehouseUk::Cinema.stub(:all, [ venue ]) do
        assert_difference "Cinema.count", 1 do
          2.times { ImportChainJob.perform_now("picturehouse") }
        end
        cinema = ExternalIdentifier.find_by!(source: "picturehouse_venue", value: "019").identifiable
        cinema.update!(name: "My edited name")
        ImportChainJob.perform_now("picturehouse")
        assert_equal "My edited name", cinema.reload.name
        assert_equal 1, cinema.external_identifiers.count
      end
    end
  end
end
