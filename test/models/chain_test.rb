require "test_helper"
require "minitest/mock"

class ChainTest < ActiveSupport::TestCase
  test "Vista screening dates pad numeric site ids and keep coded ones" do
    requested = []
    client = Object.new
    client.define_singleton_method(:get) do |_path, query|
      requested << query.fetch("siteIds")
      { "filmScreeningDates" => [] }
    end
    Cinebase::Vista::Client.stub(:new, client) do
      Chain.new("cineworld").performances(14)
      Chain.new("curzon").performances("SOH1")
    end
    assert_equal [ "014", "SOH1" ], requested
  end
end
