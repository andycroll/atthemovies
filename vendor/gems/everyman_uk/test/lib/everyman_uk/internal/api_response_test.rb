require_relative '../../../test_helper'

class EverymanUk::Internal::ApiResponseTest < Minitest::Test
  include FixturesHelper

  def test_reads_listings_from_everymancinema_com
    stub_request(:get, 'https://www.everymancinema.com/api/gatsby-source-boxofficeapi/movies?ids=1001')
      .with(headers: { 'Accept' => 'application/json' })
      .to_return(status: 200, body: movies_json)

    assert_equal 'The Example Film', EverymanUk::Internal::ApiResponse.new.movies(['1001']).first['title']
  end
end
