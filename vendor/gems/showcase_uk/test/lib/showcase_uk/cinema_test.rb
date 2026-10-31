require_relative '../../test_helper'

class ShowcaseUk::CinemaTest < Minitest::Test
  def setup
    @client = FakeClient.new
    ShowcaseUk::Cinema.instance_variable_set(:@theaters_hash, nil)
  end

  def test_reads_showcasecinemas_co_uk
    assert_equal 'https://www.showcasecinemas.co.uk', ShowcaseUk::Cinema.client.base_url
  end

  def test_new_stores_upcase_string_id
    assert_equal 'X06JR', ShowcaseUk::Cinema.new('x06jr').id
  end

  def test_all_returns_open_uk_cinemas
    with_fake_api do
      cinemas = ShowcaseUk::Cinema.all

      assert(cinemas.all? { |cinema| cinema.instance_of?(ShowcaseUk::Cinema) })
      assert_equal %w(X06JR X06KC), cinemas.map(&:id)
    end
  end

  def test_name_and_full_name
    with_fake_api do
      assert_equal 'Bluewater', ShowcaseUk::Cinema.new('X06JR').name
      assert_equal 'Showcase Glasgow Paisley', ShowcaseUk::Cinema.new('X06KC').full_name
    end
  end

  def test_brand
    assert_equal 'Showcase', ShowcaseUk::Cinema.new('X06JR').brand
  end

  def test_slug
    with_fake_api do
      assert_equal 'showcase-bluewater', ShowcaseUk::Cinema.new('X06JR').slug
    end
  end

  def test_url
    with_fake_api do
      assert_equal 'https://www.showcasecinemas.co.uk/theaters/x06jr-showcase-cinema-de-lux-bluewater',
                   ShowcaseUk::Cinema.new('X06JR').url
    end
  end

  def test_adr
    expected = {
      street_address:   '1 Example Plaza',
      extended_address: nil,
      locality:         'Greenhithe',
      region:           nil,
      postal_code:      'DA9 0ZZ',
      country_name:     'United Kingdom'
    }

    with_fake_api do
      assert_equal expected, ShowcaseUk::Cinema.new('X06JR').adr
    end
  end

  def test_postal_code_is_tidied
    with_fake_api do
      assert_equal 'PA1 0ZZ', ShowcaseUk::Cinema.new('X06KC').postal_code
    end
  end

  def test_coordinates
    with_fake_api do
      assert_equal [51.4, 0.27], [ShowcaseUk::Cinema.new('X06JR').latitude, ShowcaseUk::Cinema.new('X06JR').longitude]
      assert_nil ShowcaseUk::Cinema.new('X06KC').latitude
    end
  end

  def test_time_zone
    with_fake_api do
      assert_equal 'Europe/London', ShowcaseUk::Cinema.new('X06JR').time_zone
    end
  end

  private

  def with_fake_api(&block)
    ShowcaseUk::Cinema.stub(:client, @client, &block)
  end
end
