require_relative '../../test_helper'

class ShowcaseUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil ShowcaseUk::VERSION
  end
end
