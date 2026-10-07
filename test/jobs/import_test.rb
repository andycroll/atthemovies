require "test_helper"
require "minitest/mock"

class ImportTest < ActiveJob::TestCase
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
