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

  test "a guest token is reused until it nears expiry" do
    acquired = 0
    acquire = -> { acquired += 1; CineworldUk.token = guest_token(expires_at: 12.hours.from_now) }
    CineworldUk.stub(:acquire_token!, acquire) do
      chain = Chain.new("cineworld")
      [ nil, "not a jwt", guest_token(expires_at: 30.minutes.from_now) ].each do |token|
        CineworldUk.token = token
        chain.authenticate!
      end
      assert_equal 3, acquired
      chain.authenticate!
      assert_equal 3, acquired
    end
  ensure
    CineworldUk.token = nil
  end

  test "a rejected guest token is dropped so the retry fetches a new one" do
    CineworldUk.token = guest_token(expires_at: 12.hours.from_now)
    assert_raises(Cinebase::Vista::AuthenticationError) do
      Chain.new("cineworld").authenticated { raise Cinebase::Vista::AuthenticationError }
    end
    assert_nil CineworldUk.token
  ensure
    CineworldUk.token = nil
  end

  private

  def guest_token(expires_at:)
    [ "header", Base64.urlsafe_encode64({ exp: expires_at.to_i }.to_json, padding: false), "signature" ].join(".")
  end
end
