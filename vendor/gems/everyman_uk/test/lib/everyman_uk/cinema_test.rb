require_relative '../../test_helper'

class EverymanUk::CinemaTest < Minitest::Test
  def setup
    @client = FakeClient.new
    EverymanUk::Cinema.instance_variable_set(:@theaters_hash, nil)
  end

  def test_reads_everymancinema_com
    assert_equal 'https://www.everymancinema.com', EverymanUk::Cinema.client.base_url
  end

  def test_new_stores_upcase_string_id
    assert_equal 'X0712', EverymanUk::Cinema.new('x0712').id
  end

  def test_all_returns_open_uk_cinemas
    with_fake_api do
      cinemas = EverymanUk::Cinema.all

      assert(cinemas.all? { |cinema| cinema.instance_of?(EverymanUk::Cinema) })
      assert_equal %w(X0712 G01RL), cinemas.map(&:id)
    end
  end

  def test_name_and_full_name
    with_fake_api do
      assert_equal 'Baker Street', EverymanUk::Cinema.new('X0712').name
      assert_equal 'Everyman Marlow', EverymanUk::Cinema.new('G01RL').full_name
    end
  end

  def test_brand
    assert_equal 'Everyman', EverymanUk::Cinema.new('X0712').brand
  end

  def test_slug
    with_fake_api do
      assert_equal 'everyman-baker-street', EverymanUk::Cinema.new('X0712').slug
    end
  end

  def test_url
    with_fake_api do
      assert_equal 'https://www.everymancinema.com/theaters/x0712-everyman-baker-street', EverymanUk::Cinema.new('X0712').url
    end
  end

  def test_adr
    expected = {
      street_address:   '1 Example Street',
      extended_address: nil,
      locality:         'London',
      region:           nil,
      postal_code:      'W1U 0ZZ',
      country_name:     'United Kingdom'
    }

    with_fake_api do
      assert_equal expected, EverymanUk::Cinema.new('X0712').adr
    end
  end

  def test_postal_code_is_tidied
    with_fake_api do
      assert_equal 'SL7 0ZZ', EverymanUk::Cinema.new('G01RL').postal_code
    end
  end

  def test_coordinates
    with_fake_api do
      assert_equal [51.5, -0.15], [EverymanUk::Cinema.new('X0712').latitude, EverymanUk::Cinema.new('X0712').longitude]
      assert_nil EverymanUk::Cinema.new('G01RL').latitude
    end
  end

  def test_time_zone
    with_fake_api do
      assert_equal 'Europe/London', EverymanUk::Cinema.new('X0712').time_zone
    end
  end

  def test_refetches_theaters_after_an_hour
    calls = 0
    api = FakeClient.new
    counting = Object.new
    counting.define_singleton_method(:theaters) do
      calls += 1
      api.theaters
    end

    EverymanUk::Cinema.stub(:client, counting) do
      2.times { EverymanUk::Cinema.all }
      EverymanUk::Cinema.instance_variable_set(:@fetched_at, -EverymanUk::Cinema::CACHE_SECONDS * 2)
      EverymanUk::Cinema.all
    end

    assert_equal 2, calls
  end

  private

  def with_fake_api(&block)
    EverymanUk::Cinema.stub(:client, @client, &block)
  end
end
