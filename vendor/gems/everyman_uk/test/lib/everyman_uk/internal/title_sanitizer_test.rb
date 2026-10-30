require_relative '../../../test_helper'

class EverymanUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_removes_members_preview
    assert_sanitized 'Wild Horse Nine', "Members' Preview: Wild Horse Nine"
  end

  def test_removes_presenting_partner
    assert_sanitized "Ken Russell's The Devils", "Ken Russell's The Devils presented by Example Film Club"
  end

  def test_removes_film_year
    assert_sanitized 'Hocus Pocus', 'Hocus Pocus (1993)'
  end

  def test_removes_language_version
    assert_sanitized 'Jailer 2', 'Jailer 2 (Tamil)'
  end

  def test_standardises_met_opera
    assert_sanitized 'Met Opera: Tosca', 'Met Opera 2026-27: Tosca'
  end

  def test_keeps_titles_with_their_own_subtitles
    [
      'Avengers: Doomsday',
      'National Theatre Live: Golden Boy',
      'The Hunger Games: Sunrise on the Reaping',
      'Blade Runner 2049'
    ].each { |title| assert_sanitized title, title }
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, EverymanUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
