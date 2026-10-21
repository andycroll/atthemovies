require "test_helper"
require "minitest/mock"

class ImportTest < ActiveJob::TestCase
  test "Cineworld imports preserve edits and map future gem performances without duplicates" do
    venue = CineworldUk::Cinema.new(14)
    venue.define_singleton_method(:name) { "Brighton" }
    venue.define_singleton_method(:adr) { { street_address: "Marina", locality: "Brighton", postal_code: "BN2 5UF" } }
    starting_at = 2.days.from_now.change(usec: 0)
    distant_start = 210.days.from_now.change(usec: 0)
    performances = [
      CineworldUk::Performance.new(cinema_id: 14, cinema_name: "Brighton", film_name: "New Cineworld Release", starting_at: starting_at,
        dimension: "3d", variant: [ "imax", "audio_described" ], booking_url: "https://web.cineworld.co.uk/order/showtimes/014-123/seats"),
      CineworldUk::Performance.new(cinema_id: 14, cinema_name: "Brighton", film_name: "New Cineworld Release", starting_at: distant_start,
        dimension: "2d", variant: [], booking_url: "https://web.cineworld.co.uk/order/showtimes/014-456/seats"),
      CineworldUk::Performance.new(cinema_id: 14, cinema_name: "Brighton", film_name: "Elapsed Film", starting_at: 1.day.ago, dimension: "2d", variant: [])
    ]
    http = Object.new
    dates = [ distant_start.to_date, starting_at.to_date, 1.day.ago.to_date ]
    http.define_singleton_method(:request) do |url, headers:|
      raise "Wrong site filter" unless url.end_with?("?siteIds=014")
      { filmScreeningDates: dates.map { |date| { businessDate: date.iso8601 } } }.to_json
    end
    fetch = ->(id, from:, to:) do
      assert_equal "14", id
      assert_equal from, to
      performances.select { |performance| performance.starting_at.to_date == from }
    end
    HttpClient.stub(:new, http) do
      CineworldUk.stub(:acquire_token!, nil) do
        CineworldUk::Cinema.stub(:all, [ venue ]) do
          CineworldUk::Performance.stub(:at, fetch) do
            perform_enqueued_jobs do
              assert_difference({ "Cinema.count" => 1, "Film.count" => 1, "Performance.count" => 2 }) do
                ImportCineworldJob.perform_now
              end
              cinema = ExternalIdentifier.find_by!(source: "cineworld_venue", value: "14").identifiable
              assert_equal "BN2 5UF", cinema.postal_code
              assert_equal "https://www.cineworld.co.uk/cinemas/14/information", cinema.screenings_url
              cinema.update!(name: "Edited venue", street_address: "Edited address")
              assert_no_difference [ "Cinema.count", "Film.count", "Performance.count" ] do
                ImportCineworldJob.perform_now
              end
              assert_equal "Edited venue", cinema.reload.name
              assert_equal "Edited address", cinema.street_address
              performance = cinema.performances.find_by!(starting_at: starting_at)
              assert_equal starting_at, performance.starting_at
              assert_equal "3d", performance.dimension
              assert_equal "audio_described, imax", performance.variant
              assert_equal performances.first.booking_url, performance.booking_url
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
    job = ImportCinemaPerformancesJob.new
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

  test "cinema provider identity survives operator renames and repeated imports" do
    provider = Object.new
    provider.define_singleton_method(:cinemas) { [ { provider_id: "019", name: "Duke's", brand: "Picturehouse", locality: "Brighton" } ] }
    Providers::Picturehouse.stub(:new, provider) do
      assert_difference "Cinema.count", 1 do
        2.times { ImportPicturehouseJob.perform_now }
      end
      cinema = ExternalIdentifier.find_by!(source: "picturehouse_venue", value: "019").identifiable
      cinema.update!(name: "My edited name")
      ImportPicturehouseJob.perform_now
      assert_equal "My edited name", cinema.reload.name
      assert_equal 1, cinema.external_identifiers.count
    end
  end
end
