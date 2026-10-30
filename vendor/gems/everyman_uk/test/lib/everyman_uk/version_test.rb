require_relative '../../test_helper'

class EverymanUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil EverymanUk::VERSION
  end
end
