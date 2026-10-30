require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  def test_home_page_fixture_matches_shape
    assert_home_page_shape(home_html)
  end

  def test_page_data_fixture_matches_shape
    assert_page_data_shape(JSON.parse(page_data_index_json))
  end

  def test_theaters_fixture_matches_shape
    assert_theaters_shape(JSON.parse(theaters_json))
  end

  def test_schedule_fixture_matches_shape
    assert_schedule_shape(JSON.parse(schedule_json('X0712')), 'X0712')
  end

  def test_movies_fixture_matches_shape
    assert_movies_shape(JSON.parse(movies_json))
  end
end
