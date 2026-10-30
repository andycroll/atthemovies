require_relative '../../../test_helper'

class ShowcaseUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_removes_anniversary_restoration
    assert_sanitized 'Rocky', 'Rocky (50th Anniversary 4K Restoration)'
  end

  def test_removes_sensory_friendly_screening
    assert_sanitized 'Wildwood', 'Wildwood - Sensory Friendly Screening'
  end

  def test_removes_4k_and_anniversary
    assert_sanitized 'Donnie Darko', 'Donnie Darko 4K (25th Anniversary)'
  end

  def test_removes_dimension
    assert_sanitized "Guillermo del Toro's Pan's Labyrinth", "Guillermo del Toro's Pan's Labyrinth 3D"
  end

  def test_standardises_royal_ballet_and_opera_season
    assert_sanitized 'Royal Ballet and Opera: The Nutcracker', 'RBO Cinema Season 2026-27: The Nutcracker (2025)'
  end

  def test_keeps_titles_with_their_own_subtitles
    [
      'Avengers: Doomsday',
      'National Theatre Live: Golden Boy',
      'Secret Screening - 16th November',
      'Festive Fun with Peppa - Meet and Greet'
    ].each { |title| assert_sanitized title, title }
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, ShowcaseUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
