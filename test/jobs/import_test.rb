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
