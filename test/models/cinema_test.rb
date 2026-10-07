require "test_helper"

class CinemaTest < ActiveSupport::TestCase
  test "public tokens survive renames and locality is not repeated" do
    cinema = cinemas(:brighton)
    token = cinema.public_id
    cinema.update!(name: "Brighton Picturehouse")
    assert_equal token, cinema.public_id
    assert_equal "brighton-picturehouse", cinema.suffix
    assert_raises(ActiveRecord::ReadonlyAttributeError) { cinema.public_id = "replacement" }
    assert_raises(ActiveRecord::RecordNotUnique) { Cinema.create!(name: "Duplicate", brand: "Test", public_id: token) }
  end

  test "distance distinguishes nearby and distant venues" do
    assert_in_delta 0, cinemas(:brighton).distance_from(50.825, -0.139), 0.01
    assert_in_delta 73, cinemas(:london).distance_from(50.825, -0.139), 2
    assert_equal Float::INFINITY, Cinema.new.distance_from(50, 0)
  end
end
