require_relative '../../test_helper'

class EverymanUk::PerformanceTest < Minitest::Test
  DATE = Date.new(2026, 10, 24)

  def setup
    @api_response = FakeApiResponse.new
    EverymanUk::Cinema.instance_variable_set(:@theaters_hash, nil)
  end

  def test_at_returns_performances_in_time_order
    performances = performances_at('X0712')

    assert(performances.all? { |p| p.instance_of?(EverymanUk::Performance) })
    assert_equal 5, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_accepts_lowercase_id
    assert_equal 5, performances_at('x0712').count
  end

  def test_at_sets_cinema_details
    performances = performances_at('X0712')

    assert_equal ['X0712'], performances.map(&:cinema_id).uniq
    assert_equal ['Baker Street'], performances.map(&:cinema_name).uniq
  end

  def test_at_asks_once_for_the_whole_range
    with_fake_api { EverymanUk::Performance.at('X0712', from: DATE, to: DATE + 365) }

    assert_equal [{ theater_id: 'X0712', time_zone: 'Europe/London', from: DATE, to: DATE + 365 }],
                 @api_response.schedule_requests
    assert_equal [%w(1001 1002 1003 1004 1005)], @api_response.movie_requests
  end

  def test_at_parses_first_performance
    performance = performances_at('X0712').first

    assert_equal 'The Example Film', performance.film_name
    assert_nil performance.film_year
    assert_equal Time.utc(2026, 10, 24, 13, 0), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_nil performance.language
    assert_equal %w(subtitled), performance.variant
    assert performance.subtitled?
    assert_equal 'https://purchase.everymancinema.com/launch/ticketing/00000000-0000-0000-0000-000000000001',
                 performance.booking_url
  end

  def test_at_reads_year_from_title_only
    performance = find('Imaginary Picture')

    assert_equal 1985, performance.film_year
    assert_equal %w(35mm), performance.variant
  end

  def test_at_strips_members_preview
    performance = find('Made Up Movie')

    assert_equal '3d', performance.dimension
    assert_equal %w(members), performance.variant
    assert_equal Time.utc(2026, 10, 25, 11, 0), performance.starting_at
  end

  def test_at_moves_festival_and_language_from_title
    performance = find('Mystery Matinee')

    assert_equal Cinebase::Festival.new(name: 'CFF', year: 2026), performance.festival
    assert_equal 'Tamil', performance.language
    assert_equal %w(baby), performance.variant
  end

  def test_at_keeps_late_shows_on_the_next_utc_day
    performance = performances_at('X0712').find { |p| p.variant == %w(senior) }

    assert_equal Time.utc(2026, 10, 24, 22, 45), performance.starting_at
  end

  def test_at_skips_showtimes_without_a_film
    refute_includes performances_at('X0712').map(&:starting_at), Time.utc(2026, 10, 25, 20, 0)
  end

  def test_at_rejects_range_ending_before_start
    assert_raises(ArgumentError) { EverymanUk::Performance.at('X0712', from: DATE, to: DATE - 1) }
  end

  def test_new_sets_defaults
    performance = EverymanUk::Performance.new(
      film_name: 'Carol', cinema_id: 'X0712', cinema_name: 'Baker Street',
      starting_at: Time.utc(2013, 9, 12, 11, 0)
    )

    assert_nil performance.booking_url
    assert_equal '2d', performance.dimension
    assert_nil performance.festival
    assert_nil performance.film_year
    assert_nil performance.language
    refute performance.subtitled?
    assert_equal [], performance.variant
  end

  private

  def find(film_name)
    performances_at('X0712').find { |performance| performance.film_name == film_name }
  end

  def performances_at(cinema_id)
    with_fake_api { EverymanUk::Performance.at(cinema_id, from: DATE, to: DATE + 1) }
  end

  def with_fake_api(&block)
    EverymanUk::Internal::ApiResponse.stub(:new, @api_response, &block)
  end
end
