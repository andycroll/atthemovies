require "test_helper"

class PerformanceTest < ActiveSupport::TestCase
  test "today excludes elapsed shows and cleanup maintains counts without deleting boundary shows" do
    travel_to Time.zone.local(2026, 10, 7, 12) do
      film = films(:alien)
      past = Performance.create!(film: film, cinema: cinemas(:brighton), starting_at: 1.second.ago)
      now = Performance.create!(film: film, cinema: cinemas(:brighton), starting_at: Time.current)
      assert_equal [ now.id ], Performance.on(Date.current).pluck(:id)
      CleanupPerformancesJob.perform_now
      assert_not Performance.exists?(past.id)
      assert_equal 1, film.reload.performances_count
      now.destroy!
      assert_not_includes Film.showing, film
    end
  end

  test "London calendar days span both sides of the BST transitions" do
    travel_to Time.zone.local(2026, 1, 1) do
      [ [ Date.new(2026, 3, 29), 23 ], [ Date.new(2026, 10, 25), 25 ] ].each do |date, hours|
        first = date.in_time_zone
        assert_equal hours.hours, date.tomorrow.in_time_zone - first
        before = Performance.create!(film: films(:alien), cinema: cinemas(:brighton), starting_at: first - 1.second)
        inside = Performance.create!(film: films(:alien), cinema: cinemas(:brighton), starting_at: date.tomorrow.in_time_zone - 1.second)
        after = Performance.create!(film: films(:alien), cinema: cinemas(:brighton), starting_at: date.tomorrow.in_time_zone)
        assert_equal [ inside.id ], Performance.on(date).pluck(:id)
        refute_includes Performance.on(date), before
        refute_includes Performance.on(date), after
      end
    end
  end

  test "database enforces identity and foreign keys" do
    attributes = { film: films(:alien), cinema: cinemas(:brighton), starting_at: 1.day.from_now, dimension: "3D", variant: "IMAX" }
    showing = Performance.create!(attributes)
    assert_equal "3d", showing.dimension
    assert_equal "imax", showing.variant
    assert_raises(ActiveRecord::RecordNotUnique) { Performance.create!(attributes) }
    assert_raises(ActiveRecord::InvalidForeignKey) { showing.update_columns(cinema_id: -1) }
  end
end
