require "test_helper"

class FilmTest < ActiveSupport::TestCase
  test "normalised aliases resolve but different titles do not" do
    film = Film.resolve_title!("Alien: The Director's Cut")
    film.film_aliases.create!(name: "Alien (1979)")
    assert_equal film, Film.resolve_title!(" ALIEN—1979 ")
    assert_equal film, Film.resolve_title!("Alien - The Director’s Cut")
    refute_equal film, Film.resolve_title!("Aliens")
  end

  test "merge moves distinct performances, removes collisions and preserves aliases and counts" do
    source = films(:arrival)
    target = films(:alien)
    time = 1.day.from_now
    [ source, target ].each { |film| Performance.create!(film: film, cinema: cinemas(:brighton), starting_at: time) }
    Performance.create!(film: source, cinema: cinemas(:london), starting_at: time + 1.hour)
    source.film_aliases.create!(name: "Story of Your Life")
    source.merge_into!(target)
    assert_not Film.exists?(source.id)
    assert_equal 2, target.reload.performances_count
    assert_equal 2, target.performances.count
    assert_equal target, Film.resolve_title!("Arrival")
    assert_equal target, Film.resolve_title!("Story of Your Life")
    assert_raises(ArgumentError) { target.merge_into!(target) }
  end

  test "a failed merge rolls back performance moves" do
    source = films(:arrival)
    target = films(:alien)
    performance = Performance.create!(film: source, cinema: cinemas(:brighton), starting_at: 1.day.from_now)
    third = Film.create!(name: "Conflicting film")
    third.film_aliases.create!(name: "Arrival")
    assert_raises(ActiveRecord::RecordNotUnique) { source.merge_into!(target) }
    assert_equal source.id, performance.reload.film_id
    assert_equal 1, source.reload.performances_count
    assert_equal 0, target.reload.performances_count
  end
end
