require_relative '../../test_helper'

class ShowcaseUk::PerformanceTest < Minitest::Test
  DATE = Date.new(2026, 10, 24)

  def setup
    @client = FakeClient.new
    ShowcaseUk::Cinema.instance_variable_set(:@theaters_hash, nil)
  end

  def test_at_returns_performances_in_time_order
    performances = performances_at('X06JR')

    assert(performances.all? { |p| p.instance_of?(ShowcaseUk::Performance) })
    assert_equal 6, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_accepts_lowercase_id
    assert_equal 6, performances_at('x06jr').count
  end

  def test_at_sets_cinema_details
    performances = performances_at('X06JR')

    assert_equal ['X06JR'], performances.map(&:cinema_id).uniq
    assert_equal ['Bluewater'], performances.map(&:cinema_name).uniq
  end

  def test_at_asks_once_for_a_year
    with_fake_api { ShowcaseUk::Performance.at('X06JR', from: DATE, to: DATE + 365) }

    assert_equal [{ theater_id: 'X06JR', time_zone: 'Europe/London', from: DATE, to: DATE + 365 }],
                 @client.schedule_requests
    assert_equal [%w(2001 2002 2003 2004 2005 2006)], @client.movie_requests
  end

  def test_at_parses_an_xplus_performance
    performance = performances_at('X06JR').first

    assert_equal 'The Example Film', performance.film_name
    assert_nil performance.film_year
    assert_equal Time.utc(2026, 10, 24, 13, 0), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_nil performance.language
    assert_equal %w(subtitled xplus), performance.variant
    assert_equal 'https://tickets.showcasecinemas.co.uk/launch/ticketing/00000000-0000-0000-0000-000000000001',
                 performance.booking_url
  end

  def test_at_reads_4k_and_strips_restoration
    performance = find('Imaginary Picture')

    assert_equal %w(4k), performance.variant
  end

  def test_at_reads_reald_3d_in_xplus
    performance = find('Made Up Movie')

    assert_equal '3d', performance.dimension
    assert_equal %w(xplus), performance.variant
    assert_equal Time.utc(2026, 10, 25, 11, 0), performance.starting_at
  end

  def test_at_reads_sensory_friendly_and_language
    performance = find('Pretend Picture')

    assert_equal %w(relaxed), performance.variant
    assert_equal 'Hindi', performance.language
  end

  def test_at_reads_event_cinema_and_falls_back_to_relay_booking
    performance = find('Met Opera: Invented Opera')

    assert_equal %w(arts), performance.variant
    assert_equal 'https://relay.example.com/ticketing/dbz?code_theater=X06JR&perfd=20261025&perft=19:00',
                 performance.booking_url
  end

  def test_at_keeps_late_shows_on_the_next_utc_day
    performance = performances_at('X06JR').find { |p| p.variant == %w(senior) }

    assert_equal Time.utc(2026, 10, 24, 22, 45), performance.starting_at
  end

  def test_at_skips_showtimes_without_a_film
    refute_includes performances_at('X06JR').map(&:starting_at), Time.utc(2026, 10, 25, 20, 0)
  end

  def test_at_rejects_range_ending_before_start
    assert_raises(ArgumentError) { ShowcaseUk::Performance.at('X06JR', from: DATE, to: DATE - 1) }
  end

  def test_new_sets_defaults
    performance = ShowcaseUk::Performance.new(
      film_name: 'Carol', cinema_id: 'X06JR', cinema_name: 'Bluewater',
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
    performances_at('X06JR').find { |performance| performance.film_name == film_name }
  end

  def performances_at(cinema_id)
    with_fake_api { ShowcaseUk::Performance.at(cinema_id, from: DATE, to: DATE + 1) }
  end

  def with_fake_api(&block)
    ShowcaseUk::Cinema.stub(:client, @client, &block)
  end
end
